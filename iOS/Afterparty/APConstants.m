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

NSString *const kTwitterConsumerKey = @"tcRC6tnCRjcePUjdKFwqYPuYH";
NSString *const kTwitterConsumerSecret = @"qqVeqAp2MWhKzdVmJ3LR2S1LIfnlbRIwzdSFcEjXfWC6rWp99T";
NSString *const kParseApplicationIDProduction = @"CvhkqubpxeRFVm6j4HiMf237NWRjaYdPR1PC9vUE";
NSString *const kParseClientKeyProduction = @"ds9CT52n1L0cK704AcesYLyZWX2VUNleGarg3jWK";
NSString *const kParseApplicationIDDev = @"g7uceRQOuK3aRgsGZhjqdG9fIV0EoaTjbvPwbKTN";
NSString *const kParseClientKeyDev = @"Hb8yBE0IlYGdZBrCy6bkAcNqyu3HafrBzbOto0oA";
NSString *const kFoursquareClientID = @"A3QWFSMMPWEKZLXY434YWY3CRIMA53PU50IB4BPEMRFVHLEG";
NSString *const kFoursquareSecret = @"FE0YBODXUDB235LSKPN3I1YPPDZCAVULCST4PDYMI0IMDEQM";
NSString *const kCrashlyticsAPIKey = @"2562e5594f3c583624c29c6db146c9e585d7d2f2";
NSString *const kFacebookAppID = @"1377327292516803";
NSString *const kFacebookAppIDWithPrefix = @"fb1377327292516803";
NSString *const kPasswordSalt = @"099uvyO)VY))G*GV*)go8ghovg8go8gvogv8gvog*VG*V";
NSString *const kEventSearchParseClass = @"EventSearch";
NSString *const kPhotosParseClass = @"Photos";
NSString *const kUserParseClass = @"_User";
NSString *const kUserAvatarParseClass = @"UserAvatars";
NSString *const kParseApplicationIDLocal = @"nXzCDFuTYLWqdbe1zLMJKu4r1wDOWAM1mm678zgZ";
NSString *const kParseMasterKey = @"T8EhXqKtN0FCT9NfXOIabyU7GiRdgHIf0zh6i5qU";

// NSNotification Names

NSString *const kSearchSpecificEventNotification = @"searchSpecificEvent";
NSString *const kQueueIsUploading = @"photoQueueUploading";
NSString *const kQueueIsDoneUploading = @"photoQueueDoneUploading";

// UI

NSString *const kRegularFont = @"AvenirNext-Regular";
NSString *const kBoldFont = @"AvenirNext-Bold";
//NSString *const kRegularFont = @"Mostardesign-SofiaProLight";
//NSString *const kBoldFont = @"Mostardesign-SofiaProBold";

CGFloat const kIPhone5Width = 320.f;
CGFloat const kIPhone6Width = 375.f;
CGFloat const kIPhone6PlusWidth = 414.f;

// PFUser Keys

NSString *const kPFUserProfilePhotoURLKey = @"profilePhotoURL";
NSString *const kPFUserBlurbKey = @"blurb";
NSString *const kPFUserEventsJoinedKey = @"eventsJoined";


@end
