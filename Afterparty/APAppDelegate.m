//
//  APAppDelegate.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APAppDelegate.h"
#import "APMainTabBarController.h"
#import <Crashlytics/Crashlytics.h>
#import "APConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <DeeplinkSDK/DeeplinkSDK.h>

@implementation APAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#ifdef DEBUG
    NSLog(@"--------DEV SERVER--------");
    [Parse setApplicationId:kParseApplicationIDDev clientKey:kParseClientKeyDev];
#else
    NSLog(@"--------PROD SERVER--------");
    [Parse setApplicationId:kParseApplicationIDProduction clientKey:kParseClientKeyProduction];
#endif
    
    //API Setup
    [PFTwitterUtils initializeWithConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    [PFFacebookUtils initializeFacebook];
    [Foursquare2 setupFoursquareWithClientId:kFoursquareClientID secret:kFoursquareSecret callbackURL:@"afterparty://foursquare"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
    [[DeeplinkSDK sharedInstance] initiateWithApiKey:kDeeplinkApiKey andAppID:kDeeplinkAppID completion:^(BOOL succeeded) {
        NSLog(@"%@", succeeded?@"YES":@"NO");
    }];

    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor afterpartyBlackColor], NSForegroundColorAttributeName, [UIFont fontWithName:kBoldFont size:18.5f], NSFontAttributeName, nil]];
  
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kRegularFont size:11], NSFontAttributeName, [UIColor afterpartyBlackColor], NSForegroundColorAttributeName,  nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor afterpartyBlackColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:kRegularFont size:12.0f]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kRegularFont size:11.f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [SVProgressHUD setFont:[UIFont fontWithName:kRegularFont size:13.f]];
    [SVProgressHUD setBackgroundColor:[UIColor afterpartyTealBlueColor]];
    [SVProgressHUD setForegroundColor:[UIColor afterpartyOffWhiteColor]];
    [SVProgressHUD setRingThickness:2.0f];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([url.absoluteString containsString:@"foursquare"]) {
    return [Foursquare2 handleURL:url];
  }
  else if([url.absoluteString containsString:kFacebookAppIDWithPrefix]){
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
  }else if([url.absoluteString containsString:@"eventID"]) {
    NSArray *components = [url.absoluteString componentsSeparatedByString:@":"];
    NSString *eventID = [components lastObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchSpecificEventNotification object:eventID];
  }else{
    return YES;
  }
  return NO;
}

+ (UIViewController*) topMostController {
  UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }
  return topController;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [FBSession.activeSession close];
  
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
