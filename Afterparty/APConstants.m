//
//  APConstants.m
//  Afterparty
//
//  Created by David Okun on 7/7/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APConstants.h"

@implementation APConstants

// Segue Constants

NSString *const kMyEventSelectedSegue = @"EventSelectedSegue";
NSString *const kNearbyEventDetailSegue = @"EventDetailSegue";
NSString *const kNearbyEventGoToSegue = @"EventDetailsGoToEventSegue";
NSString *const kCreateEventSegue = @"createEventSegue";
NSString *const kSettingsProfileSegue = @"settingsProfileSegue";
NSString *const kSettingsEventSegue = @"settingsEventSegue";
NSString *const kSettingsSocialNetworkingSegue = @"settingsSocialNetworkingSegue";
NSString *const kLoginSegue = @"LoginSegue";
NSString *const kCheckCurrentUser = @"checkCurrentUser";

// API

NSString *const kTwitterConsumerKey = @"lrrwwaMcOMZ2ZYyUSWWSfxCOF";
NSString *const kTwitterConsumerSecret = @"k8nG6Ib3dVu4MBtIRyrCyqoqi0FZVsbD4JPIxvRc37jRCN7qqh";
NSString *const kParseApplicationID = @"CvhkqubpxeRFVm6j4HiMf237NWRjaYdPR1PC9vUE";
NSString *const kParseClientKey = @"ds9CT52n1L0cK704AcesYLyZWX2VUNleGarg3jWK";
NSString *const kFoursquareClientID = @"A3QWFSMMPWEKZLXY434YWY3CRIMA53PU50IB4BPEMRFVHLEG";
NSString *const kFoursquareSecret = @"FE0YBODXUDB235LSKPN3I1YPPDZCAVULCST4PDYMI0IMDEQM";
NSString *const kCrashlyticsAPIKey = @"2562e5594f3c583624c29c6db146c9e585d7d2f2";
NSString *const kFacebookAppID = @"1377327292516803";
NSString *const kFacebookAppIDWithPrefix = @"fb1377327292516803";
NSString *const kPasswordSalt = @"099uvyO)VY))G*GV*)go8ghovg8go8gvogv8gvog*VG*V";
NSString *const kEventSearchParseClass = @"EventSearch";
NSString *const kPhotosParseClass = @"Photos";
NSString *const kUserParseClass = @"_User";

// NSNotification Names

NSString *const kSearchSpecificEventNotification = @"searchSpecificEvent";
NSString *const kQueueIsUploading = @"photoQueueUploading";
NSString *const kQueueIsDoneUploading = @"photoQueueDoneUploading";

// UI

NSString *const kRegularFont = @"SofiaProLight";
NSString *const kBoldFont = @"SofiaProBold";

// PFUser Keys

NSString *const kPFUserProfilePhotoURLKey = @"profilePhotoURL";
NSString *const kPFUserBlurbKey = @"blurb";
NSString *const kPFUserDataTrackingKey = @"dataTracking";

@end
