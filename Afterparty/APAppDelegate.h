//
//  APAppDelegate.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+APColor.h"
#import "NSString+APString.h"
#import <Foursquare-API-v2/Foursquare2.h>
#import <FacebookSDK/Facebook.h>
#import <Parse/Parse.h>

@interface APAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;

@end
