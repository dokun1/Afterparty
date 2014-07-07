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

// API

NSString *const kTwitterConsumerKey = @"lrrwwaMcOMZ2ZYyUSWWSfxCOF";
NSString *const kTwitterConsumerSecret = @"k8nG6Ib3dVu4MBtIRyrCyqoqi0FZVsbD4JPIxvRc37jRCN7qqh";
NSString *const kPasswordSalt = @"099uvyO)VY))G*GV*)go8ghovg8go8gvogv8gvog*VG*V";

// NSNotification Names

NSString *const kSearchSpecificEventNotification = @"searchSpecificEvent";
NSString *const kQueueIsUploading = @"photoQueueUploading";
NSString *const kQueueIsDoneUploading = @"photoQueueDoneUploading";

// UI

NSString *const kRegularFont = @"SofiaProLight";
NSString *const kBoldFont = @"SofiaProBold";

@end
