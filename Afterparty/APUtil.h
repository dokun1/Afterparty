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
+ (CGSize) getAppSize;
+ (CGSize) getViewSize:(UIViewController *)controller;
+ (CGRect) getViewFrame:(UIViewController *)controller;
+ (UIImage *) imageWithColor:(UIColor *)color;
+ (UIImage *) imageWithColor:(UIColor *)color withSize:(CGSize)newSize;
+ (BOOL)validateEmailWithString:(NSString*)email;
+ (void)saveImage:(UIImage*)image forPath:(NSString*)path;
+ (void)saveFile:(NSObject*)file forPath:(NSString*)path;
+ (void)saveDictionary:(NSDictionary*)dictionary forPath:(NSString*)path;
+ (void)saveArray:(NSArray*)array forPath:(NSString*)path;
+ (NSArray*)loadArrayForPath:(NSString*)path;
+ (NSObject*)getFileForPath:(NSString*)path;
+ (BOOL)loggedIn;
+ (void)getMyEventsArrayWithSuccess:(void (^)(NSMutableArray *events))successBlock;
+ (void)saveEventToMyEvents:(APEvent*)event;
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

@end
