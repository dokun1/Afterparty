//
//  APConstants.h
//  Afterparty
//
//  Created by David Okun on 7/7/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APConstants : NSObject

// Segue Constants

extern NSString *const kMyEventSelectedSegue;
extern NSString *const kNearbyEventDetailSegue;
extern NSString *const kNearbyEventGoToSegue;
extern NSString *const kCreateEventSegue;
extern NSString *const kSettingsProfileSegue;
extern NSString *const kSettingsEventSegue;
extern NSString *const kSettingsSocialNetworkingSegue;
extern NSString *const kLoginSegue;

// API

extern NSString *const kTwitterConsumerKey;
extern NSString *const kTwitterConsumerSecret;
extern NSString *const kPasswordSalt;
extern NSString *const kEventSearchParseClass;
extern NSString *const kPhotosParseClass;
extern NSString *const kUserParseClass;

// NSNotification Names

extern NSString *const kSearchSpecificEventNotification;
extern NSString *const kQueueIsUploading;
extern NSString *const kQueueIsDoneUploading;

// UI

extern NSString *const kRegularFont;
extern NSString *const kBoldFont;

@end
