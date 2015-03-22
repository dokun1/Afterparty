//
//  APConnectionManager.h
//  Afterparty
//
//  Created by David Okun on 6/12/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "APComment.h"
#import "APEvent.h"
#import <Social/Social.h>

typedef void (^APSuccessBooleanBlock)(BOOL succeeded);
typedef void (^APSuccessBooleanPlusObjectBlock)(BOOL succeeded, id object);
typedef void (^APSuccessArrayBlock)(NSArray *objects);
typedef void (^APSuccessDataBlock)(NSData *data);
typedef void (^APSuccessPFUserBlock)(PFUser *user);
typedef void (^APSuccessStringBlock)(NSString *string);
typedef void (^APSuccessDictionaryBlock)(NSDictionary *dictionary);
typedef void (^APSuccessNumberBlock)(NSNumber *number);
typedef void (^APSuccessVoidBlock)(void);

typedef void (^APFailureErrorBlock)(NSError *error);

typedef void (^APProgressBlock)(int percentDone);

@interface APConnectionManager : NSObject


/*!
 *  Thread-safe singleton instance of the connection manager needed for all calls.
 *
 *  @return instancetype singleton
 *
 *  @since 0.5.0
 */

+(instancetype)sharedManager;

/*!
 *  Updates the installed version number associated with a user. This is used purely for debugging purposes, and likely won't be in version 1.0
 *
 *  @param user         PFUser object retrieved by [PFUser currentUser]
 *  @param successBlock Returns YES as BOOL
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)updateInstallVersionForUser:(PFUser*)user
                           success:(APSuccessBooleanBlock)successBlock
                           failure:(APFailureErrorBlock)failureBlock;

/*!
 *  This is a call to the Foursquare API to get nearby venues to your current location.
 *
 *  @param location     CLLocation retrieved from getting current location
 *  @param successBlock Returns NSArray of FSVenue objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)getNearbyVenuesForLocation:(CLLocation *)location
                          success:(APSuccessArrayBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock;

/*!
 *  This is a call to the Foursquare API to search by location and a name query. This will use the Foursquare search engine to narrow places down, and no logic is done app-side
 *
 *  @param name         NSString of search query entered by user
 *  @param location     CLLocation retrieved from getting current location
 *  @param successBlock Returns NSArray of FSVenue objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)searchVenuesByName:(NSString *)name
               atLocation:(CLLocation *)location
                  success:(APSuccessArrayBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock;

/*!
 *  This is a call to the Parse API to search for APEvents with the name entered as the only search query
 *
 *  @param name         NSString of search query entered by user
 *  @param successBlock Returns NSArray of APEvent objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)searchEventsByName:(NSString *)name
                  success:(APSuccessArrayBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock;

/*!
 *  This is a call to lookup an event in the nearby events field by a particular event ID. This is for clicking on a link to a party that you have been texted.
 *
 *  @param eventID      NSString of eventID to search for
 *  @param successBlock Returns NSArray of APEvent object
 *  @param failureBlock Returns NSError
 *
 *  @since 0.8.0
 */

-(void)searchEventsByID:(NSString*)eventID
                success:(APSuccessArrayBlock)successBlock
                failure:(APFailureErrorBlock)failureBlock;
/*!
 *  This is the call that runs by default when a user goes to nearby events. After capturing the user's location, it will search in a rect of two coordinate points that contain both the long and lat given by the user
 *
 *  @param location     CLLocation retrieved from getting current location
 *  @param successBlock Returns NSArray of APEvent objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)getNearbyEventsForLocation:(CLLocation *)location
                          success:(APSuccessArrayBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Saves an event to Parse that the user has created.
 *
 *  @param event        APEvent that is ready to be saved to Parse
 *  @param successBlock Returns YES as BOOL
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)saveEvent:(APEvent *)event
         success:(APSuccessBooleanBlock)successBlock
         failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Updates list of event attendees to include your PFUser objectID
 *
 *  @param event        APEvent object to query using objectID
 *  @param successBlock Returns void on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.10
 */
- (void)updateEventForNewAttendee:(APEvent *)event
                          success:(APSuccessVoidBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock;

/*!
 *  When you join an event, this adds the eventID to an array on the server under your username so that you always know which events you are actively participating in.
 *
 *  @param eventID      NSString for the eventID that you are joining
 *  @param successBlock Returns void
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.9
 */
- (void)joinEvent:(NSString*)eventID
          success:(APSuccessVoidBlock)successBlock
          failure:(APFailureErrorBlock)failureBlock;

/*!
 *  @brief  This is to get a specific event as called for by its object ID on the web services
 *
 *  @param eventID      NSString with the eventID
 *  @param successBlock Returns APEvent for the event called for
 *  @param failureBlock Returns NSError
 */
- (void)getEventForId:(NSString *)eventID success:(void (^)(APEvent *event))successBlock failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Gets event that user has just created to see if the user wants to save it right away. Probably should deprecate, but it is a reliable way to ensure that the event previously created truly exists.
 *
 *  @param name         NSString of event name
 *  @param user         PFUser retrieved from [PFUser currentUser]
 *  @param successBlock Returns NSArray of APEvent object (should only return 1)
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */
- (void)lookupEventByName:(NSString *)name
                    user:(PFUser *)user
                 success:(APSuccessArrayBlock)successBlock
                 failure:(APFailureErrorBlock)failureBlock;

/*!
 *  This is a foursquare API call to get venue details for a given venue. Not using this anywhere yet, but could be useful for other kind of analytics in the app
 *
 *  @param venueID      NSString that identifies foursquare venue
 *  @param successBlock Returns YES as BOOL and NSDictionary with JSON representation of venue details
 *  @param failureBlock Returns NSError
 *
 *  @since 0.5.0
 */

-(void)getVenueDetails:(NSString *)venueID
               success:(APSuccessBooleanPlusObjectBlock)successBlock
               failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Uploads image to Parse after it has been taken and confirmed.
 *
 *  @param image         UIImage being uploaded, full resolution. Thumbnail gets created on server automatically.
 *  @param eventID       NSString for eventID for which the photo is being uploaded
 *  @param successBlock  Returns YES as BOOL
 *  @param failureBlock  Returns NSError
 *
 *  @since 0.6.0
 */
- (void)uploadImage:(UIImage*)image forEventID:(NSString*)eventID success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Downloads an image given its reference ID. The ref ID can be obtained from the metadata sheet downloaded at the beginning of every event open. This can be used to load thumbnails in the event collage, or the full-res photo in the photo viewer.
 *
 *  @param refID        NSString for reference ID of photo to be downloaded
 *  @param successBlock Returns NSData of image to be displayed
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)downloadImageForRefID:(NSString *)refID
                     success:(APSuccessDataBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Gets url for a referenced imageID. This URL can be plugged into the UIImageView+AFNetworking class for auto caching and proper dequeuing.
 *
 *  @param refID        NSString for reference ID of photo to be downloaded
 *  @param successBlock Returns NSString containing URL of image
 *  @param failureBlock Reutrns NSError
 *
 *  @since 0.9.0
 */
-(void)getURLForImageRefID:(NSString *)refID
                   success:(APSuccessStringBlock)successBlock
                   failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Informs the server that the specified image needs to be reported for inappropriate content
 *
 *  @param refID        NSString with the reference ID for the image being reported
 *  @param successBlock Returns BOOL if the photo has been reported three times or more, meaning it needs to be deleted from the feed
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.11
 */
- (void)reportImageForImageRefID:(NSString *)refID
                         success:(APSuccessBooleanBlock)successBlock
                         failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Gets sheet of metadata containing information for each image that comprises an event. This must be called upon opening and refreshing current event screen
 *
 *  @param eventID      NSString for eventID to load metadata
 *  @param successBlock Returns NSArray of APPhotoInfo objects to comprise metadata sheet
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */
-(void)downloadImageMetadataForEventID:(NSString *)eventID
                               success:(APSuccessArrayBlock)successBlock
                               failure:(APFailureErrorBlock)failureBlock;

/*!
 *  When you take a photo of yourself for your user avatar, this will save it and associate it with your user profile
 *
 *  @param image        UIImage to be saved as the avatar
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.9
 */
- (void)saveImageForUserAvatar:(UIImage *)image
                   withSuccess:(APSuccessVoidBlock)successBlock
                       failure:(APFailureErrorBlock)failureBlock;

- (void)getImageForCurrentUserWithSuccess:(APSuccessStringBlock)successBlock
                                  failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Logs in a user. This is only for Parse credentials
 *
 *  @param username     <#username description#>
 *  @param password     <#password description#>
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 *
 *  @since 0.9.0
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(APSuccessPFUserBlock)successBlock failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Links facebook  with user account that already exists.
 *
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.1
 */
-(void)linkFacebookWithSuccess:(APSuccessVoidBlock)successBlock
                       failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Unlinks facebook with user account that already exists
 *
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.9
 */
- (void)unlinkFacebookWithSuccess:(APSuccessVoidBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Delegates to twitter to link account with current user
 *
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.1
 */
- (void)linkTwitterWithSuccess:(APSuccessVoidBlock)successBlock
                       failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Unlinks twitter with user account that already exists
 *
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.9
 */
- (void)unlinkTwitterWithSuccess:(APSuccessVoidBlock)successBlock
                         failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Logs into parse using facebook credentials and permissions
 *
 *  @param permissions  <#permissions description#>
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 */
- (void)loginWithFacebookUsingPermissions:(NSArray*)permissions
                                  success:(APSuccessPFUserBlock)successBlock
                                  failure:(APFailureErrorBlock)failureBlock;


/*!
 *  Gets facebook user details after a user has logged in using facebook
 *
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 */
- (void)getFacebookUserDetailsWithSuccessBlock:(APSuccessDictionaryBlock)successBlock
                                       failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Logs into parse using twitter credentials
 *
 *  @param account      <#account description#>
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 */
- (void)loginWithTwitterAccount:(ACAccount*)account
                        success:(APSuccessPFUserBlock)successBlock
                        failure:(APFailureErrorBlock)failureBlock;


/*!
 *  Gets twitter user details after a user has logged in using facebook
 *
 *  @param successBlock <#successBlock description#>
 *  @param failureBlock <#failureBlock description#>
 */

- (void)getTwitterUserDetailsForUsername:(NSString*)username
                                 success:(APSuccessDictionaryBlock)successBlock
                                 failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Checks to see if username or email is already used during registration
 *
 *  @param credentials  NSDictionary of credentials containing desired username and email address
 *  @param successBlock Returns NSArray of PFUser objects if user exists, no duplicates exist if [array count] = 0
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)checkIfUserExists:(NSDictionary *)credentials
                 success:(APSuccessArrayBlock)successBlock
                 failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Creates account for user on Parse. This should only be called if there are no duplicates of user account.
 *
 *  @param username     <#username description#>
 *  @param password     <#password description#>
 *  @param email        <#email description#>
 *  @param successBlock Returns YES as BOOL
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.0
 */
- (void)signUpUser:(NSString*)username
          password:(NSString*)password
             email:(NSString*)email
           success:(APSuccessBooleanBlock)successBlock
           failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Parse call to reset password given an email address. Not implemented yet but should work, need to figure out workaround for facebook and twitter linked accounts
 *
 *  @param email        NSString of email address to reset
 *  @param successBlock Returns YES as BOOL
 *  @param failureBlock Returns NSError
 *
 *  @since 0.8.0
 */

-(void)resetPasswordForEmail:(NSString*)email
                     success:(APSuccessBooleanBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Adds photo comment to photo given an event.
 *
 *  @param comment      APComment object as added by user
 *  @param objectID     NSString for imageID being appended with commment
 *  @param eventID      NSString for eventID in which photo appears
 *  @param successBlock Returns YES as BOOL and updated comment array
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.0
 */

-(void)addPhotoComment:(APComment *)comment
   toPhotoObjectWithID:(NSString *)objectID
             inEventID:(NSString *)eventID
               success:(APSuccessBooleanPlusObjectBlock)successBlock
               failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Updates an APEvent with a new foursquare venue
 *
 *  @param eventID      NSString for the eventID that needs to be referenced and updated
 *  @param newVenue     FSVenue object for new foursquare venue
 *  @param successBlock Returns YES as BOOL
 *  @param failureBlock Returns NSError
 *
 *  @since 0.7.0
 */

-(void)updateEventForEventID:(NSString*)eventID
                withNewVenue:(APVenue*)newVenue
                     success:(APSuccessBooleanBlock)successBlock
                     failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Updates the blurb property on a user object. Initially blank for all users
 *
 *  @param blurb        NSString that represents user blurb
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.1
 */
- (void)saveUserBlurb:(NSString*)blurb
              success:(APSuccessVoidBlock)successBlock
              failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Updates the email property on a user object
 *
 *  @param email        NSString that represents email address of user
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.1
 */
- (void)saveUserEmail:(NSString*)email
              success:(APSuccessVoidBlock)successBlock
              failure:(APFailureErrorBlock)failureBlock;


/*!
 *  Attempts to delete photos for a particular event. It calls a server function that tries to delete 10 photos at a time for a given event on the server. This is to try and sneak around the rate limit!
 *
 *  @param eventID      NSString for eventID that we are trying to delete
 *  @param successBlock Returns number of photos left for that event
 *  @param failureBlock Returns NSError
 *
 *  @since 0.9.12
 */
- (void)attemptEventDeleteForPhotoCleanupForEventID:(NSString *)eventID
                                            success:(APSuccessNumberBlock)successBlock
                                            failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Deletes an event on the server given an eventID
 *
 *  @param eventID      NSString for eventID that we are going to delete
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSerror
 *
 *  @since 1.0.0
 */
- (void)deleteEventForEventID:(NSString *)eventID success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Adds a location to the Foursquare API for when a location doesnt exist and a user wants to create one to associate with their event
 *
 *  @param venue        APVenue object, Name and coordinates are required
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 1.1.0
 */
- (void)addVenueToLocationSearch:(APVenue *)venue success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock;

/*!
 *  Changes the properties of an event after the owner of the party has edited it
 *
 *  @param event        APEvent that has been updated by the user
 *  @param successBlock Returns void block on success
 *  @param failureBlock Returns NSError
 *
 *  @since 1.1.0
 */
- (void)updateEventAfterEdit:(APEvent *)event success:(APSuccessVoidBlock)successBlock failure:(APFailureErrorBlock)failureBlock;


@end
