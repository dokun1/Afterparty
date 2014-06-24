//
//  VitalsHealthUtilities.m
//  VitalsHealth
//
//  Created by David Okun on 10/2/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APUtil.h"

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

+ (CTTelephonyNetworkInfo *)getCurrentConnection {
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
//    [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
//                                                    object:nil
//                                                     queue:nil
//                                                usingBlock:^(NSNotification *note)
//    {
//        NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
//    }];
    
    return telephonyInfo;
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


+(UIImage*)getImageForPath:(NSString *)path {
    path = [[self documentDirectory] stringByAppendingPathComponent:path];
    return [UIImage imageWithContentsOfFile:path];
}

+ (BOOL)loggedIn{
    return NO;
}

+ (NSMutableArray*)getMyEventsArray {
    NSArray *eventsArray = [self loadArrayForPath:@"myEventsArray"];
    NSMutableArray *myEventsArray = [eventsArray mutableCopy];
    [eventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
        NSDictionary *eventInfo = [eventDict allValues].firstObject;
        NSDate *deleteDate = [eventInfo objectForKey:@"deleteDate"];
        NSComparisonResult result = [deleteDate compare:[NSDate date]];
        if (result == NSOrderedAscending)
            [myEventsArray removeObject:eventDict];
    }];
    [self saveArray:[NSArray arrayWithArray:myEventsArray] forPath:@"myEventsArray"];
    return myEventsArray;
}

+ (void)saveEventToMyEvents:(APEvent*)event{
    NSMutableArray *myEventsArray = [[self getMyEventsArray] mutableCopy];
    NSDictionary *eventInfo = @{@"deleteDate": [event deleteDate],
                                @"endDate" : [event endDate],
                                @"startDate" : [event startDate],
                                @"eventName": [event eventName],
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
    if (!containsEvent)
        [myEventsArray addObject:eventDict];
    [self saveArray:myEventsArray forPath:@"myEventsArray"];
}

+ (void)updateEventVenue:(FSVenue*)newVenue forEventID:(NSString*)eventID {
    NSMutableArray *myEventsArray = [[self getMyEventsArray] mutableCopy];
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
    [self saveArray:myEventsArray forPath:@"myEventsArray"];
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
    
    NSLog(@"\nCurrent Version: %@\nServer Version: %@", [self getVersion], webVersion);
    
    if ([self string:webVersion isGreaterThanString:[self getVersion]]) {
        return YES;
    }
    return NO;
}

+(BOOL)string:(NSString*)str1 isGreaterThanString:(NSString*)str2
{
    NSArray *a1 = [str1 componentsSeparatedByString:@"."];
    NSArray *a2 = [str2 componentsSeparatedByString:@"."];
    
    NSInteger totalCount = ([a1 count] < [a2 count]) ? [a1 count] : [a2 count];
    NSInteger checkCount = 0;
    
    while (checkCount < totalCount) {
        if([a1[checkCount] integerValue] < [a2[checkCount] integerValue])
            return NO;
        else if([a1[checkCount] integerValue] > [a2[checkCount] integerValue])
            return YES;
        else
            checkCount++;
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


@end
