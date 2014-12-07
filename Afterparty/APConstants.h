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
extern NSString *const kParseApplicationIDProduction;
extern NSString *const kParseClientKeyProduction;
extern NSString *const kParseApplicationIDDev;
extern NSString *const kParseClientKeyDev;
extern NSString *const kFoursquareClientID;
extern NSString *const kFoursquareSecret;
extern NSString *const kCrashlyticsAPIKey;
extern NSString *const kFacebookAppID;
extern NSString *const kFacebookAppIDWithPrefix;
extern NSString *const kPasswordSalt;
extern NSString *const kEventSearchParseClass;
extern NSString *const kPhotosParseClass;
extern NSString *const kUserParseClass;
extern NSString *const kUserAvatarParseClass;


// NSNotification Names

extern NSString *const kSearchSpecificEventNotification;
extern NSString *const kQueueIsUploading;
extern NSString *const kQueueIsDoneUploading;
extern NSString *const kCheckCurrentUser;

// UI

extern NSString *const kRegularFont;
extern NSString *const kBoldFont;
extern CGFloat const kIPhone5Width;
extern CGFloat const kIPhone6Width;
extern CGFloat const kIPhone6PlusWidth;

// PFUser Keys

extern NSString *const kPFUserProfilePhotoURLKey;
extern NSString *const kPFUserBlurbKey;
extern NSString *const kPFUserEventsJoinedKey;

@end
