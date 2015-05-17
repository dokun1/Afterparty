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
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "APEventNotification.h"
#import "APEvent.h"

@import AssetsLibrary;

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
        NSDate *deleteDate = eventInfo[@"deleteDate"];
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
    NSDictionary *eventInfo = @{@"deleteDate": [event deleteDate] ?: [event deleteDate],
                                @"endDate" : [event endDate] ?: [event endDate],
                                @"startDate" : [event startDate] ?: [event startDate],
                                @"eventName": [event eventName] ?: [event eventName],
                                @"eventLatitude": @([event location].latitude),
                                @"eventLongitude": @([event location].longitude),
                                @"createdByUsername": [event createdByUsername],
                                @"eventImageData": [event eventImageData],
                                @"eventPassword": [event password] ?: [event password]};
    NSDictionary *eventDict = @{[event objectID]: eventInfo};
    [self private_saveEventDictionaryToMyEvents:eventDict eventObject:event];
}

+ (void)private_saveEventDictionaryToMyEvents:(NSDictionary *)newEvent eventObject:(APEvent *)eventObject {
    [self setNotificationsForEvent:eventObject];
    dispatch_async([self getBackgroundQueue], ^{
        [[self cacheLock] lock];
        NSMutableArray *myEventsArray = [[self loadSavedEvents] mutableCopy];
        __block BOOL containsEvent = NO;
        [myEventsArray enumerateObjectsUsingBlock:^(NSDictionary *iterateEventDict, NSUInteger idx, BOOL *stop) {
            if ([[[iterateEventDict allKeys] firstObject] isEqualToString:newEvent.allKeys.firstObject]) {
                containsEvent = YES;
                [myEventsArray replaceObjectAtIndex:idx withObject:newEvent];
                *stop = YES;
            }
        }];
        if (!containsEvent) {
            [myEventsArray addObject:newEvent];
            [[APConnectionManager sharedManager] joinEvent:newEvent.allKeys.firstObject success:^{
                
            } failure:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Event Error" message:@"For some reason, we couldn't register your name with the event. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
        [self saveArray:myEventsArray forPath:kMyEventsKey];
        [[self cacheLock] unlock];
    });
}

+ (void)updateEventFromPushNotification:(NSDictionary *)userInfo {
    NSDictionary *eventDict = userInfo[@"eventObject"];
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        eventInfo[@"eventImageData"] = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventDict[@"eventImage"][@"url"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            eventInfo[@"deleteDate"] = [self formatPushNotificationStringToDate:eventDict[@"deleteDate"][@"iso"]];
            eventInfo[@"startDate"] = [self formatPushNotificationStringToDate:eventDict[@"startDate"][@"iso"]];
            eventInfo[@"endDate"] = [self formatPushNotificationStringToDate:eventDict[@"endDate"][@"iso"]];
            eventInfo[@"eventName"] = eventDict[@"eventName"];
            eventInfo[@"eventLatitude"] = eventDict[@"latitude"];
            eventInfo[@"eventLongitude"] = eventDict[@"longitude"];
            eventInfo[@"createdByUsername"] = eventDict[@"createdByUsername"];
            eventInfo[@"password"] = eventDict[@"password"] ?: eventDict[@"password"];
            NSDictionary *updatedEventDict = @{eventDict[@"objectId"]:eventInfo};
            APEvent *newEvent = [[APEvent alloc] initWithName:eventDict[@"eventName"] venue:nil password:eventInfo[@"password"] startDate:eventInfo[@"startDate"] endDate:eventInfo[@"endDate"] deleteDate:eventInfo[@"deleteDate"] createdByUsername:eventInfo[@"createdByUsername"] atLocation:CLLocationCoordinate2DMake([eventInfo[@"eventLatitude"] floatValue], [eventInfo[@"eventLongitude"] floatValue]) coverPhotoID:nil eventDescription:nil eventAddress:nil eventImage:nil eventUserPhotoURL:nil eventUserBlurb:nil];
            newEvent.objectID = eventDict[@"objectId"];
            [self private_saveEventDictionaryToMyEvents:updatedEventDict eventObject:newEvent];
        });
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

+ (NSString*)formatDateForEventDetailScreen:(NSDate*)date {
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

+ (NSDate *)formatPushNotificationStringToDate:(NSString *)dateString {
    static ISO8601DateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[ISO8601DateFormatter alloc] init];
    });

    NSDate *date = [df dateFromString:dateString];
    return date;
}

+ (NSString *)formatDateForEventCreationScreen:(NSDate*)date {
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"M/d h:mma"];
    });

    NSString *dateString = [df stringFromDate:date];
    return dateString;
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

#pragma mark - event notification methods
+ (NSLock*) cacheLock {
    // because we have the ability add and remove notifications in an asynchronous environment, we have to lock the thread we are on whenever we are mutating the array saved to disk, so that we can't
    // delete and add something at the same time and do a poor job of preserving state. the process is:
    // 1) lock the thread
    // 2) mutate the array
    // 3) save it again
    // 4) unlock the thread
    // locking the main thread creates a major performance issue, so it is important to dispatch array mutation to a background thread - which I have specified below for safe keeping
    static NSLock *__lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __lock = [[NSLock alloc] init];
    });
    return __lock;
}

+ (dispatch_queue_t)getBackgroundQueueForNotifications {
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("com.afterparty.notificationMutationQueue", NULL);
    });
    return sharedQueue;
}

+ (NSArray *)getNotificationsForEventID:(NSString *)eventID {
    NSMutableArray *notificationsToReturn = [NSMutableArray array];
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    [scheduledNotifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfo = notification.userInfo;
        if ([userInfo[@"eventID"] isEqualToString:eventID]) {
            APEventNotification *eventNotification = [[APEventNotification alloc] init];
            eventNotification.eventID = eventID;
            
            NSString *type = userInfo[@"type"];
            if ([type isEqualToString:@"eventEnded"]) {
                eventNotification.notificationType = EventNotificationTypeEventEnded;
            } else if ([type isEqualToString:@"eventAboutToEnd"]) {
                eventNotification.notificationType = EventNotificationTypeEventOneHourFromDelete;
            } else if ([type isEqualToString:@"eventDeleted"]) {
                eventNotification.notificationType = EventNotificationTypeEventDeleted;
            } else {
                eventNotification.notificationType = EventNotificationTypeOther;
            }
            [notificationsToReturn addObject:eventNotification];
        }
    }];
    
    return notificationsToReturn;
}

+ (void)setNotificationsForEvent:(APEvent *)event {
    dispatch_async([self getBackgroundQueueForNotifications], ^{
        [[self cacheLock] lock];
        [self removeNotificationsForEventID:event.objectID];
        
        UILocalNotification *eventEndedNotification = [[UILocalNotification alloc] init];
        UILocalNotification *eventAboutToEndNotification = [[UILocalNotification alloc] init];
        UILocalNotification *eventDeletedNotification = [[UILocalNotification alloc] init];
        
        eventEndedNotification.fireDate = event.endDate;
        eventEndedNotification.alertBody = [NSString stringWithFormat:@"%@ just ended! Go check out all the photos everyone took!", event.eventName];
        eventEndedNotification.timeZone = [NSTimeZone systemTimeZone];
        eventEndedNotification.userInfo = @{@"eventID":event.objectID, @"type":@"eventEnded"};
        [[UIApplication sharedApplication] scheduleLocalNotification:eventEndedNotification];
        
        eventAboutToEndNotification.fireDate = [NSDate dateWithTimeInterval:-3600 sinceDate:event.deleteDate];
        eventAboutToEndNotification.alertBody = [NSString stringWithFormat:@"%@ is going to disappear in an hour...get in there and get a good last look!", event.eventName];
        eventAboutToEndNotification.timeZone = [NSTimeZone systemTimeZone];
        eventAboutToEndNotification.userInfo = @{@"eventID":event.objectID, @"type":@"eventAboutToEnd"};
        [[UIApplication sharedApplication] scheduleLocalNotification:eventAboutToEndNotification];
        
        eventDeletedNotification.fireDate = event.deleteDate;
        eventDeletedNotification.alertBody = [NSString stringWithFormat:@"%@ just disappeared! Why not get another party started?", event.eventName];
        eventDeletedNotification.timeZone = [NSTimeZone systemTimeZone];
        eventDeletedNotification.userInfo = @{@"eventID":event.objectID, @"type":@"eventDeleted"};
        [[UIApplication sharedApplication] scheduleLocalNotification:eventDeletedNotification];
        [[self cacheLock] unlock];
    });

}

+ (void)removeNotificationsForEventID:(NSString *)eventID {
    dispatch_async([self getBackgroundQueueForNotifications], ^{
        NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        NSMutableArray *newLocalNotifications = [NSMutableArray array];
        [localNotifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
            NSDictionary *userInfo = notification.userInfo;
            if (![userInfo[@"eventID"] isEqualToString:eventID]) {
                [newLocalNotifications addObject:notification];
            }
        }];
        [[UIApplication sharedApplication] setScheduledLocalNotifications:newLocalNotifications];
    });
}

+ (void)saveImageToCameraRoll:(UIImage *)image {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *albumName = @"Afterparty";
    __block ALAssetsGroup* folder;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSNumber *hasFolder = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasFolder"];
        if (![hasFolder boolValue]) {
            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                folder = group;
            } failureBlock:^(NSError *error) {
            }];
            hasFolder = [NSNumber numberWithBool:YES];
            [[NSUserDefaults standardUserDefaults] setValue:hasFolder forKey:@"hasFolder"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                folder = group;
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                folder = group;
            } failureBlock:^(NSError *error) {
            }];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *imageData = UIImagePNGRepresentation(image);
            [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error.code == 0) {
                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [folder addAsset:asset];
                    } failureBlock:^(NSError *error) {
                    }];
                }
            }];
        });
    });
}

@end
