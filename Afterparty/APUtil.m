//
//  VitalsHealthUtilities.m
//  VitalsHealth
//
//  Created by David Okun on 10/2/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APUtil.h"
#import "APConnectionManager.h"
#import "APConstants.h"

static NSString *kExpiredEventsKey = @"expiredEvents";
static NSString *kMyEventsKey = @"myEventsArray";

@implementation APUtil

+(void)setNetworkActivityIndicator:(BOOL)status {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = status;
}

+ (CGSize) getAppSize {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
        size = CGSizeMake(size.height, size.width);
    
    if (!application.statusBarHidden)
        size.height -= MIN(application.statusBarFrame.size.width,
                           application.statusBarFrame.size.height);
    return size;
}

+ (CGSize) getViewSize:(UIViewController *)controller {
    CGRect bounds = [UIScreen mainScreen].applicationFrame;
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    UIInterfaceOrientation orientation = controller.interfaceOrientation;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        width = bounds.size.height;
        height = bounds.size.width;
    }
    
    return CGSizeMake(width, height);
}

+ (CGRect) getViewFrame:(UIViewController *)controller {
    //Calculate Screensize
    BOOL statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden ];
    BOOL navigationBarHidden = [controller.navigationController isNavigationBarHidden];
    BOOL tabBarHidden = [controller.tabBarController.tabBar isHidden];
    BOOL toolBarHidden = [controller.navigationController isToolbarHidden];
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    
    //check if you should rotate the view, e.g. change width and height of the frame
    BOOL rotate = NO;
    if ( UIInterfaceOrientationIsLandscape( [UIApplication sharedApplication].statusBarOrientation ) ) {
        if (frame.size.width < frame.size.height) {
            rotate = YES;
        }
    }
    
    if ( UIInterfaceOrientationIsPortrait( [UIApplication sharedApplication].statusBarOrientation ) ) {
        if (frame.size.width > frame.size.height) {
            rotate = YES;
        }
    }
    
    if (rotate) {
        CGFloat tmp = frame.size.height;
        frame.size.height = frame.size.width;
        frame.size.width = tmp;
    }
    
    if (statusBarHidden) {
        frame.size.height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    if (!navigationBarHidden) {
        frame.size.height -= controller.navigationController.navigationBar.frame.size.height;
    }
    if (!tabBarHidden) {
        frame.size.height -= controller.tabBarController.tabBar.frame.size.height;
    }
    if (!toolBarHidden) {
        frame.size.height -= controller.navigationController.toolbar.frame.size.height;
    }
    return frame;
}

+ (UIImage *) imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *) imageWithColor:(UIColor *)color withSize:(CGSize)newSize {
    CGRect rect = CGRectMake(0.0f, 0.0f, newSize.width, newSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (NSObject*)getFileForPath:(NSString*)path {
    NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return obj;
}

+ (NSString*) documentDirectory {
    static NSString* directory = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    });
    return directory;
}

+ (BOOL)validateEmailWithString:(NSString*)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(void)saveImage:(UIImage*)image forPath:(NSString *)path {
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.9);
    [imgData writeToFile:path atomically:YES];
}

+(void)saveFile:(NSObject *)file forPath:(NSString *)path {
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    [NSKeyedArchiver archiveRootObject:file toFile:path];
}

+(void)saveDictionary:(NSDictionary*)dictionary forPath:(NSString*)path{
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    [dictionary writeToFile:path atomically:YES];
}

+(void)saveArray:(NSArray*)array forPath:(NSString*)path {
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    [array writeToFile:path atomically:YES];
}

+(NSArray*)loadArrayForPath:(NSString*)path {
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    return [NSArray arrayWithContentsOfFile:path];
}

+ (BOOL)loggedIn{
    return NO;
}

+ (void)getMyEventsArrayWithSuccess:(void (^)(NSMutableArray *events))successBlock {
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:kPFUserEventsJoinedKey] boolValue]) {
        [self loadMyEventsOnLoginWithCompletion:^{
            successBlock([self loadSavedEvents]);
        }];
    } else {
        successBlock([self loadSavedEvents]);
    }
}

+ (NSMutableArray*)loadSavedEvents {
    NSArray *eventsArray = [self loadArrayForPath:kMyEventsKey];
    if (!eventsArray) {
        eventsArray = @[];
    }
    NSMutableArray *myEventsArray = [eventsArray mutableCopy];
    NSMutableArray *expiredEvents = [NSMutableArray array];
    [eventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
        NSDictionary *eventInfo = [eventDict allValues].firstObject;
        NSDate *deleteDate = [eventInfo objectForKey:@"deleteDate"];
        NSComparisonResult result = [deleteDate compare:[NSDate date]];
        if (result == NSOrderedAscending) {
            [myEventsArray removeObject:eventDict];
            [expiredEvents addObject:eventDict];
        }
    }];
    [self saveArray:[NSArray arrayWithArray:myEventsArray] forPath:kMyEventsKey];
    [self attemptExpiredEventDestructionWithNewEvents:expiredEvents];
    return myEventsArray;
}

+ (void)eraseAllEventsFromMyEvents {
    [self saveArray:@[] forPath:kMyEventsKey];
}

+ (void)attemptExpiredEventDestructionWithNewEvents:(NSArray *)newEvents {
    NSArray *expiredEvents = [self loadArrayForPath:kExpiredEventsKey];
    if (!expiredEvents) {
        expiredEvents = @[];
    }
    NSMutableArray *newExpiredEvents = [expiredEvents mutableCopy];
    if (newEvents.count > 0) {
        [newExpiredEvents addObjectsFromArray:newEvents];
    }
    [self saveArray:[NSArray arrayWithArray:newExpiredEvents] forPath:kExpiredEventsKey];
    if (newExpiredEvents.count > 0) {
        NSDictionary *attemptDict = (NSDictionary *)newExpiredEvents.firstObject;
        NSString *eventID = attemptDict.allKeys.firstObject;
        [[APConnectionManager sharedManager] attemptEventDeleteForPhotoCleanupForEventID:eventID success:^(NSNumber *number) {
            if ([number doubleValue] == 0) {
                [[APConnectionManager sharedManager] deleteEventForEventID:eventID success:^{
                    [newExpiredEvents removeObject:attemptDict];
                    [self saveArray:[NSArray arrayWithArray:newExpiredEvents] forPath:kExpiredEventsKey];
                } failure:^(NSError *error) {
                }];
            }
        } failure:^(NSError *error) {
        }];
    }
}

+ (void)loadMyEventsOnLoginWithCompletion:(void (^)())completionBlock {
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:kPFUserEventsJoinedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *eventsJoined = [PFUser currentUser][kPFUserEventsJoinedKey];
    NSInteger counter = 0;
    for (NSString *eventID in eventsJoined) {
        counter++;
        [[APConnectionManager sharedManager] searchEventsByID:eventID success:^(NSArray *objects) {
            if (objects.count > 0) {
                APEvent *event = objects.firstObject;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    PFFile *imageFile = (PFFile*)[event eventImage];
                    NSData *imageData = [imageFile getData];
                    [event setEventImageData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveEventToMyEvents:event];
                        if (counter == eventsJoined.count) {
                            completionBlock();
                        }
                    });
                });
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

+ (void)saveEventToMyEvents:(APEvent*)event{
    dispatch_async([self getBackgroundQueue], ^{
        [[self cacheLock] lock];
        NSMutableArray *myEventsArray = [[self loadSavedEvents] mutableCopy];
        NSDictionary *eventInfo = @{@"deleteDate": [event deleteDate] ?: [event deleteDate],
                                    @"endDate" : [event endDate] ?: [event endDate],
                                    @"startDate" : [event startDate] ?: [event startDate],
                                    @"eventName": [event eventName] ?: [event eventName],
                                    @"eventLatitude": @([event location].latitude),
                                    @"eventLongitude": @([event location].longitude),
                                    @"createdByUsername": [event createdByUsername],
                                    @"eventImageData": [event eventImageData]};
        NSDictionary *eventDict = @{[event objectID]: eventInfo};
        __block BOOL containsEvent = NO;
        [myEventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
            if ([[[eventDict allKeys] firstObject] isEqualToString:[event objectID]]) {
                containsEvent = YES;
                *stop = YES;
            }
        }];
        if (!containsEvent) {
            [myEventsArray addObject:eventDict];
            [[APConnectionManager sharedManager] joinEvent:event.objectID success:^{
                
            } failure:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Event Error" message:@"For some reason, we couldn't register your name with the event. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
        [self saveArray:myEventsArray forPath:kMyEventsKey];
        [[self cacheLock] unlock];
    });
}

+ (void)updateEventVenue:(APVenue*)newVenue forEventID:(NSString*)eventID {
    [APUtil getMyEventsArrayWithSuccess:^(NSMutableArray *myEventsArray) {
        [myEventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
            if ([[[eventDict allKeys] firstObject] isEqualToString:eventID]) {
                NSMutableDictionary *eventInfo = [[[eventDict allValues] firstObject] mutableCopy];
                eventInfo[@"eventLatitude"] = @(newVenue.location.coordinate.latitude);
                eventInfo[@"eventLongitude"] = @(newVenue.location.coordinate.longitude);
                [myEventsArray removeObjectAtIndex:idx];
                NSDictionary *newEventDict = @{[[eventDict allKeys] firstObject] : eventInfo};
                [myEventsArray addObject:newEventDict];
                *stop = YES;
            }
        }];
        [self saveArray:myEventsArray forPath:kMyEventsKey];
    }];
}

+ (NSString*)getVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

}

+(BOOL)shouldDownloadNewVersion { // should only call on background thread
    if ([NSThread isMainThread])
        return NO;
    
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://afterparty.parseapp.com/Afterparty.plist"]];
    if (!plist)
        return NO;
    
    NSArray *items = [plist allValues].firstObject;
    NSDictionary *metadata = [items.firstObject objectForKey:@"metadata"];
    NSString *webVersion = [metadata objectForKey:@"bundle-version"];
  
  if ([[self getVersion] compare:webVersion options:NSNumericSearch] == NSOrderedAscending) { //checks to see if current version is less than web version
    return YES;
  }
  return NO;
}

+(NSString *) genRandIdString {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:8];
    
    for (int i=0; i<8; i++) {
        [randomString appendFormat: @"%C", [@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" characterAtIndex: arc4random() % [@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" length]]];
    }
    
    return randomString;
}

+(NSString*)formatDateForEventDetailScreen:(NSDate*)date {
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        //FEB 21, 2014 at 8PM
        [df setDateFormat:@"MMM dd, y, h:mma"];
    });
    
    NSString *dateString = [df stringFromDate:date];
    return dateString;
}

+ (NSString *)formatDateForEventCreationScreen:(NSDate*)date {
  static NSDateFormatter *df = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    df = [[NSDateFormatter alloc] init];
    //FEB 21, 2014 at 8PM
    //6/29 at 8PM
    [df setDateFormat:@"M/d h:mma"];
  });
  
  NSString *dateString = [df stringFromDate:date];
  return dateString;
}

+ (NSLock*) cacheLock {
    static NSLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSLock alloc] init];
    });
    return lock;
}

+ (dispatch_queue_t)getBackgroundQueue {
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("com.afterparty.eventSaveQueue", NULL);
    });
    return sharedQueue;
    
}

+ (NSArray *)getReportedPhotoIDs {
    NSArray *photoIDArray = [self loadArrayForPath:@"reportedPhotos"];
    if (!photoIDArray) {
        photoIDArray = @[];
    }
    return photoIDArray;
}

+ (void)saveReportedPhotoID:(NSString *)photoID {
    NSMutableArray *reportedPhotos = [[self getReportedPhotoIDs] mutableCopy];
    if (![reportedPhotos containsObject:photoID]) {
        [reportedPhotos addObject:photoID];
    }
    [self saveArray:reportedPhotos forPath:@"reportedPhotos"];
}


@end
