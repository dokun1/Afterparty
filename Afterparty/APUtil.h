//
//  VitalsHealthUtilities.h
//  VitalsHealth
//
//  Created by David Okun on 10/2/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "APEvent.h"
#import "APPhotoInfo.h"

@interface APUtil : NSObject

+ (void)setNetworkActivityIndicator:(BOOL)status;

+ (BOOL)validateEmailWithString:(NSString*)email;

+ (void)saveArray:(NSArray*)array forPath:(NSString*)path;

+ (NSArray*)loadArrayForPath:(NSString*)path;

+ (void)getMyEventsArrayWithSuccess:(void (^)(NSMutableArray *events))successBlock;

+ (void)saveEventToMyEvents:(APEvent*)event;

+ (void)updateEventFromPushNotification:(NSDictionary *)userInfo;

+ (void)eraseAllEventsFromMyEvents;

+ (void)updateEventVenue:(APVenue*)newVenue forEventID:(NSString*)eventID;

+ (NSString*)getVersion;

+ (BOOL)shouldDownloadNewVersion;

+ (NSString *) genRandIdString;

+ (NSString *)formatDateForEventDetailScreen:(NSDate*)date;

+ (NSString *)formatDateForEventCreationScreen:(NSDate*)date;

+ (NSLock *)cacheLock;

+ (NSArray *)getReportedPhotoIDs;

+ (void)saveReportedPhotoID:(NSString *)photoID;

#pragma mark - event notification methods

+ (NSArray *)getNotificationsForEventID:(NSString *)eventID;

+ (void)setNotificationsForEvent:(APEvent *)event;

+ (void)removeNotificationsForEventID:(NSString *)eventID;

@end
