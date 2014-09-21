//
//  APConnectionManager.m
//  Afterparty
//
//  Created by David Okun on 6/12/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APConnectionManager.h"
#import <Parse/Parse.h>
#import <CommonCrypto/CommonDigest.h>
#import "APUtil.h"
#import <Foursquare-API-v2/Foursquare2.h>
#import "FSConverter.h"
#import "APConstants.h"

@implementation APConnectionManager

+ (instancetype)sharedManager {
  static APConnectionManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}


-(void)updateInstallVersionForUser:(PFUser *)user
                           success:(APSuccessBooleanBlock)successBlock
                           failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kUserParseClass];
  [query whereKey:@"username" equalTo:user.username];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      PFUser *foundUser = objects.firstObject;
      foundUser[@"installedVersion"] = [APUtil getVersion];
      [foundUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        (error == nil) ? successBlock(succeeded) : failureBlock(error);
      }];
    }
  }];
}

-(void)getNearbyVenuesForLocation:(CLLocation *)location
                          success:(APSuccessArrayBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock {
  [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                               longitude:@(location.coordinate.longitude)
                                   query:nil
                                   limit:nil
                                  intent:intentCheckin
                                  radius:@(3000)
                              categoryId:nil callback:^(BOOL success, id result) {
                                if (success) {
                                  NSDictionary *dic = result;
                                  NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                  FSConverter *converter = [[FSConverter alloc] init];
                                  NSArray *nearbyVenues = [converter convertToObjects:venues];
                                  successBlock(nearbyVenues);
                                }else{
                                  NSError *error = [[NSError alloc] initWithDomain:@"com.dmos.afterparty" code:404 userInfo:@{@"Couldn't get venues" : NSLocalizedFailureReasonErrorKey}];
                                  failureBlock(error);
                                }
                              }];
}

-(void)searchVenuesByName:(NSString *)name
               atLocation:(CLLocation *)location
                  success:(APSuccessArrayBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock {
  [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                               longitude:@(location.coordinate.longitude)
                                   query:name
                                   limit:nil
                                  intent:intentBrowse
                                  radius:@(10000)
                              categoryId:nil callback:^(BOOL success, id result) {
                                if (success) {
                                  NSDictionary *dic = result;
                                  NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                  FSConverter *converter = [[FSConverter alloc] init];
                                  NSArray *nearbyVenues = [converter convertToObjects:venues];
                                  successBlock(nearbyVenues);
                                }else{
                                  NSError *error = [[NSError alloc] initWithDomain:@"com.dmos.afterparty" code:404 userInfo:@{@"Couldn't get venues" : NSLocalizedFailureReasonErrorKey}];
                                  failureBlock(error);
                                }
                              }];
}

-(void)getNearbyEventsForLocation:(CLLocation *)location
                          success:(APSuccessArrayBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kEventSearchParseClass];
    
  NSNumber *latUp = @(location.coordinate.latitude + 0.07);
  NSNumber *latDown = @(location.coordinate.latitude - 0.07);
  NSNumber *longUp = @(location.coordinate.longitude + 0.07);
  NSNumber *longDown = @(location.coordinate.longitude - 0.07);
  
  NSLog(@"Searching for coord range (%@, %@), (%@, %@)", latDown, latUp, longDown, longUp);
  
  [query whereKey:@"latitude" greaterThan:latDown];
  [query whereKey:@"latitude" lessThan:latUp];
  [query whereKey:@"longitude" greaterThan:longDown];
  [query whereKey:@"longitude" lessThan:longUp];
  [query whereKey:@"deleteDate" greaterThan:[NSDate date]];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      failureBlock(error);
    }
    NSMutableArray *events = [NSMutableArray array];
    [objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger idx, BOOL *stop) {
      APEvent *event = [[APEvent alloc] initWithParseObject:object];
      [events addObject:event];
    }];
    successBlock(events);
  }];
}

-(void)saveEvent:(APEvent *)event
         success:(APSuccessBooleanBlock)successBlock
         failure:(APFailureErrorBlock)failureBlock {
  
  UIImage *eventImage = [event eventImage];
  NSData *imageData = UIImageJPEGRepresentation(eventImage, 0.8);
  PFFile *imageFile = [PFFile fileWithName:@"eventImage.jpg" data:imageData];
  [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    PFObject *savedEvent = [PFObject objectWithClassName:kEventSearchParseClass];
    savedEvent[@"eventName"]              = [event eventName];
    savedEvent[@"eventVenueID"]           = [event eventVenue].venueId;
    savedEvent[@"eventVenueName"]         = [event eventVenue].name;
    savedEvent[@"password"]               = event.password ? [event password] : @"";
    savedEvent[@"startDate"]              = [event startDate];
    savedEvent[@"endDate"]                = [event endDate];
    savedEvent[@"deleteDate"]             = [event deleteDate];
    savedEvent[@"createdByUsername"]      = [event createdByUsername];
    savedEvent[@"latitude"]               = @([event location].latitude);
    savedEvent[@"longitude"]              = @([event location].longitude);
    savedEvent[@"eventDescription"]       = [event eventDescription];
    savedEvent[@"eventAddress"]           = [event eventAddress];
    savedEvent[@"eventImage"]             = imageFile;
    savedEvent[kPFUserProfilePhotoURLKey] = [event eventUserPhotoURL];
    savedEvent[kPFUserBlurbKey]           = [event eventUserBlurb];
    [savedEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock(succeeded) : failureBlock(error);
    }];
  }];
  
}

-(void)lookupEventByName:(NSString *)name
                    user:(PFUser *)user
                 success:(APSuccessArrayBlock)successBlock
                 failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kEventSearchParseClass];
  [query whereKey:@"eventName" equalTo:name];
  [query whereKey:@"createdByUsername" equalTo:[user username]];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    (error == nil) ? successBlock(objects) : failureBlock(error);
  }];
}

-(void)searchEventsByName:(NSString *)name
                  success:(APSuccessArrayBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kEventSearchParseClass];
  [query whereKey:@"eventName" containsString:name];
  [query whereKey:@"deleteDate" greaterThan:[NSDate date]];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      failureBlock(error);
    }
    NSMutableArray *events = [NSMutableArray array];
    [objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger idx, BOOL *stop) {
      APEvent *event = [[APEvent alloc] initWithParseObject:object];
      [events addObject:event];
    }];
    successBlock(events);
  }];
}

-(void)searchEventsByID:(NSString *)eventID
                success:(APSuccessArrayBlock)successBlock
                failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kEventSearchParseClass];
  [query getObjectInBackgroundWithId:eventID block:^(PFObject *object, NSError *error) {
    if (error) {
      failureBlock(error);
    }
    if (object == nil) {
      failureBlock(nil);
    } else {
      APEvent *event = [[APEvent alloc] initWithParseObject:object];
      successBlock(@[event]);
    }
  }];
}

-(void)getVenueDetails:(NSString *)venueID
               success:(APSuccessBooleanPlusObjectBlock)successBlock
               failure:(APFailureErrorBlock)failureBlock {
  [Foursquare2 venueGetDetail:venueID callback:^(BOOL success, id result) {
    (result != nil) ? successBlock(success, result) : failureBlock([[NSError alloc] initWithDomain:@"com.dmos.afterparty" code:404 userInfo:@{@"Couldn't get venues" : NSLocalizedFailureReasonErrorKey}]);
  }];
}

- (void)uploadImage:(UIImage*)image forEventID:(NSString*)eventID success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    NSString *refID     = [NSString stringWithFormat:@"%@%@", eventID, [APUtil genRandIdString]];
    PFObject *photoData = [PFObject objectWithClassName:kPhotosParseClass];
    
    photoData[@"eventID"] = eventID;
    photoData[@"timestamp"] = [NSDate date];
    photoData[@"user"] = [[PFUser currentUser] username];
    photoData[@"comments"] = @[];
    photoData[@"refID"] = refID;
    photoData[@"thumbID"] = [NSString stringWithFormat:@"THUMB%@", refID];
    photoData[@"width"] = @(image.size.width);
    photoData[@"height"] = @(image.size.height);
    photoData[@"imageFile"] = imageFile;
    [photoData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        (succeeded) ? successBlock() : failureBlock(error);
    }];
}

-(void)uploadImage:(UIImage *)image
     withThumbnail:(UIImage *)thumbnail
        forEventID:(NSString *)eventID
           success:(APSuccessBooleanBlock)successBlock
           failure:(APFailureErrorBlock)failureBlock
          progress:(APProgressBlock)progressBlock {
  
  NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
  NSData *thumbData = UIImageJPEGRepresentation(thumbnail, 0.6);
  PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
  PFFile *thumbFile = [PFFile fileWithName:@"thumb.jpg" data:thumbData];
  NSString *refID     = [NSString stringWithFormat:@"%@%@", eventID, [APUtil genRandIdString]];
  PFObject *photoData = [PFObject objectWithClassName:kPhotosParseClass];
  
  photoData[@"eventID"] = eventID;
  photoData[@"timestamp"] = [NSDate date];
  photoData[@"user"] = [[PFUser currentUser] username];
  photoData[@"comments"] = @[];
  photoData[@"refID"] = refID;
  photoData[@"thumbID"] = [NSString stringWithFormat:@"THUMB%@", refID];
  photoData[@"width"] = @(image.size.width);
  photoData[@"height"] = @(image.size.height);
  photoData[@"imageFile"] = imageFile;
  photoData[@"thumbFile"] = thumbFile;
  [photoData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    (succeeded) ? successBlock(YES) : failureBlock(error);
  }];
}

-(void)downloadImageMetadataForEventID:(NSString *)eventID
                               success:(APSuccessArrayBlock)successBlock
                               failure:(APFailureErrorBlock)failureBlock {
  if (!eventID) return;
  PFQuery *query = [PFQuery queryWithClassName:kPhotosParseClass];
  [query whereKey:@"eventID" equalTo:eventID];
  [query orderByDescending:@"createdAt"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    (error == nil) ? successBlock(objects) : failureBlock(error);
  }];
}

-(void)getURLForImageRefID:(NSString *)refID
                   success:(APSuccessStringBlock)successBlock
                   failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kPhotosParseClass];
  [query whereKey:@"refID" equalTo:refID];
  query.cachePolicy = kPFCachePolicyCacheElseNetwork;
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      failureBlock(error);
    }else{
      PFObject *object = [objects firstObject];
      PFFile *imageFile = object[@"imageFile"];
      successBlock(imageFile.url);
    }
  }];
}

-(void)downloadImageForRefID:(NSString *)refID
                     success:(APSuccessDataBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kPhotosParseClass];
  [query whereKey:@"refID" equalTo:refID];
  query.cachePolicy = kPFCachePolicyCacheElseNetwork;
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      failureBlock(error);
    }else{
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = nil;
        PFObject *object = [objects firstObject];
        
        PFFile *imageFile = object[@"imageFile"];
        imageData = [imageFile getData];
        successBlock(imageData);
      });
    }
  }];
}

-(void)addPhotoComment:(APComment *)comment
   toPhotoObjectWithID:(NSString *)objectID
             inEventID:(NSString *)eventID
               success:(APSuccessBooleanPlusObjectBlock)successBlock
               failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kPhotosParseClass];
  [query whereKey:@"objectId" equalTo:objectID];
  [query whereKey:@"eventID" equalTo:eventID];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error != nil) {
      failureBlock(error);
    }else{
      PFObject *object = objects.firstObject;
      NSMutableArray *comments = [[object valueForKey:@"comments"] mutableCopy];
      NSDictionary *addedComment = [comment convertToDictionary];
      [comments addObject:addedComment];
      object[@"comments"] = comments;
      [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        successBlock(succeeded, object);
      }];
    }
  }];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(APSuccessPFUserBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock {
  NSString *saltedPassword = [NSString stringWithFormat:@"%@%@", password, kPasswordSalt];
  NSString *hashedPassword = nil;
  unsigned char hashedPasswordData[CC_SHA1_DIGEST_LENGTH];
  NSData *data = [saltedPassword dataUsingEncoding:NSUTF8StringEncoding];
  if (CC_SHA1([data bytes], (uint)[data length], hashedPasswordData)) {
    hashedPassword = [[NSString alloc] initWithBytes:hashedPasswordData length:sizeof(hashedPasswordData) encoding:NSASCIIStringEncoding];
  }
  [PFUser logInWithUsernameInBackground:username password:hashedPassword block:^(PFUser *user, NSError *error) {
    (error == nil) ? successBlock(user) : failureBlock(error);
  }];
}

-(void)linkFacebookWithSuccess:(APSuccessVoidBlock)successBlock
                       failure:(APFailureErrorBlock)failureBlock {
  [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"public_profile", @"email", @"user_friends"] block:^(BOOL succeeded, NSError *error) {
    (error == nil) ? successBlock() : failureBlock(error);
  }];
}

- (void)linkTwitterWithSuccess:(APSuccessVoidBlock)successBlock
                       failure:(APFailureErrorBlock)failureBlock {
  if ([PFUser currentUser]) {
    [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock() : failureBlock(error);
    }];
  }
}

- (void)loginWithFacebookUsingPermissions:(NSArray *)permissions
                                  success:(APSuccessPFUserBlock)successBlock
                                  failure:(APFailureErrorBlock)failureBlock {
  [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
    if (!user) {
      if (!error) {
        NSError *fauxError = [[NSError alloc] initWithDomain:@"com.afterparty" code:1004 userInfo:nil];
        failureBlock(fauxError);
      }else {
        failureBlock(error);
      }
      
    } if (user.isNew) {
      successBlock(user);
    } else if (user) {
      successBlock(user);
    }
  }];
}

- (void)getFacebookUserDetailsWithSuccessBlock:(APSuccessDictionaryBlock)successBlock
                                       failure:(APFailureErrorBlock)failureBlock {
  FBRequest *request = [FBRequest requestForMe];
  
  [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (error) {
      failureBlock(error);
    }
    NSDictionary *userData = (NSDictionary*)result;
    PFUser *user = [PFUser currentUser];
    user.username = userData[@"name"];
    user.email = userData[@"email"];
    user[kPFUserDataTrackingKey] = @(YES);
    [user setValue:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=300&height=300", userData[@"id"]] forKey:kPFUserProfilePhotoURLKey];
    [user saveInBackground];
    successBlock(userData);
  }];
}

- (void)loginWithTwitterAccount:(ACAccount *)account
                        success:(APSuccessPFUserBlock)successBlock
                        failure:(APFailureErrorBlock)failureBlock {
  [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
    (error == nil) ? successBlock(user) : failureBlock(error);
  }];
}

- (void)getTwitterUserDetailsForUsername:(NSString*)username
                                 success:(APSuccessDictionaryBlock)successBlock
                                 failure:(APFailureErrorBlock)failureBlock {
  NSString *twitterUsername = username;
  NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", twitterUsername];
  NSURL *verify = [NSURL URLWithString:requestString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
  [[PFTwitterUtils twitter] signRequest:request];
  
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    if (connectionError) failureBlock(connectionError);
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    (error == nil) ? successBlock(result) : failureBlock(error);
    if (result) {
      PFUser *user = [PFUser currentUser];
      user.username = result[@"screen_name"];
      user[kPFUserDataTrackingKey] = @(YES);
      [user setValue:result[@"profile_image_url"] forKey:kPFUserProfilePhotoURLKey];
      [user saveInBackground];
    }
  }];
}

-(void)checkIfUserExists:(NSDictionary *)credentials
                 success:(APSuccessArrayBlock)successBlock
                 failure:(APFailureErrorBlock)failureBlock {
  PFQuery *usernameQuery = [PFQuery queryWithClassName:kUserParseClass];
  [usernameQuery whereKey:@"username" equalTo:credentials[@"username"]];
  
  PFQuery *emailQuery = [PFQuery queryWithClassName:kUserParseClass];
  [emailQuery whereKey:@"email" equalTo:credentials[@"email"]];
  
  PFQuery *query = [PFQuery orQueryWithSubqueries:@[usernameQuery, emailQuery]];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    (error == nil) ? successBlock(objects) : failureBlock(error);
  }];
}

-(void)resetPasswordForEmail:(NSString*)email
                     success:(APSuccessBooleanBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock{
  [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
    (error == nil) ? successBlock(succeeded) : failureBlock(error);
  }];
}

- (void)signUpUser:(NSString*)username
          password:(NSString*)password
             email:(NSString*)email
           success:(APSuccessBooleanBlock)successBlock
           failure:(APFailureErrorBlock)failureBlock {
  PFUser *user = [PFUser user];
  user.username = username;
  NSString *saltedPassword = [NSString stringWithFormat:@"%@%@", password, kPasswordSalt];
  NSString *hashedPassword = nil;
  unsigned char hashedPasswordData[CC_SHA1_DIGEST_LENGTH];
  NSData *data = [saltedPassword dataUsingEncoding:NSUTF8StringEncoding];
  if (CC_SHA1([data bytes], (uint)[data length], hashedPasswordData)) {
    hashedPassword = [[NSString alloc] initWithBytes:hashedPasswordData length:sizeof(hashedPasswordData) encoding:NSASCIIStringEncoding];
  }
  user.password = hashedPassword;
  user.email = email;
  user[kPFUserDataTrackingKey] = @(YES);
  [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    (error == nil) ? successBlock(succeeded) : failureBlock(error);
  }];
}

-(void)updateEventForEventID:(NSString*)eventID
                withNewVenue:(FSVenue*)newVenue
                     success:(APSuccessBooleanBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock {
  PFQuery *query = [PFQuery queryWithClassName:kEventSearchParseClass];
  [query getObjectInBackgroundWithId:eventID block:^(PFObject *object, NSError *error) {
    if (error) {
      failureBlock(error);
    }
    object[@"eventAddress"] = (newVenue.location.address) ? newVenue.location.address : @"";
    object[@"latitude"] = @(newVenue.location.coordinate.latitude);
    object[@"longitude"] = @(newVenue.location.coordinate.longitude);
    object[@"eventVenueName"] = newVenue.name;
    object[@"eventVenueID"] = newVenue.venueId;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock(succeeded) : failureBlock(error);
    }];
  }];
}

- (void)saveUserTrackingParameter:(BOOL)isTrackingData success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
  PFUser *currentUser = [PFUser currentUser];
  if (currentUser) {
    currentUser[kPFUserDataTrackingKey] = @(isTrackingData);
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock() : failureBlock(error);
    }];
  }
}

- (void)saveUserBlurb:(NSString*)blurb
              success:(APSuccessVoidBlock)successBlock
              failure:(APFailureErrorBlock)failureBlock {
  PFUser *currentUser = [PFUser currentUser];
  if (currentUser) {
    currentUser[kPFUserBlurbKey] = blurb;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock() : failureBlock(error);
    }];
  }
}

- (void)saveUserEmail:(NSString*)email
              success:(APSuccessVoidBlock)successBlock
              failure:(APFailureErrorBlock)failureBlock {
  if (![APUtil validateEmailWithString:email]) {
    failureBlock(nil);
    return;
  }
  PFUser *currentUser = [PFUser currentUser];
  if (currentUser) {
    currentUser.email = email;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      (error == nil) ? successBlock() : failureBlock(error);
    }];
  }
}

- (void)joinEvent:(NSString *)eventID
          success:(APSuccessVoidBlock)successBlock
          failure:(APFailureErrorBlock)failureBlock {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *eventsJoinedArray = currentUser[kPFUserEventsJoinedKey];
    if (!eventsJoinedArray) {
        eventsJoinedArray = [@[] mutableCopy];
    }
    if (![eventsJoinedArray containsObject:eventID]) {
        [eventsJoinedArray addObject:eventID];
        currentUser[kPFUserEventsJoinedKey] = eventsJoinedArray;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            succeeded?successBlock():failureBlock(nil);
        }];
    }
}


@end
