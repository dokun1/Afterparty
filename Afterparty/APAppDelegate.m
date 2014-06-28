//
//  APAppDelegate.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APAppDelegate.h"
#import "APMainTabBarController.h"


@implementation APAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  
  [Parse setApplicationId:@"CvhkqubpxeRFVm6j4HiMf237NWRjaYdPR1PC9vUE" clientKey:@"ds9CT52n1L0cK704AcesYLyZWX2VUNleGarg3jWK"];
  
  [Foursquare2 setupFoursquareWithClientId:@"A3QWFSMMPWEKZLXY434YWY3CRIMA53PU50IB4BPEMRFVHLEG" secret:@"FE0YBODXUDB235LSKPN3I1YPPDZCAVULCST4PDYMI0IMDEQM" callbackURL:@"afterparty://foursquare"];
  
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  
  [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor afterpartyBlackColor], NSForegroundColorAttributeName, [UIFont fontWithName:kBoldFont size:18.5f], NSFontAttributeName, nil]];
  
  [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kRegularFont size:11], NSFontAttributeName, [UIColor afterpartyBlackColor], NSForegroundColorAttributeName,  nil] forState:UIControlStateNormal];
  [[UIBarButtonItem appearance] setTintColor:[UIColor afterpartyBlackColor]];
  [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:kRegularFont size:12.0f]];
  
  [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([url.absoluteString containsString:@"foursquare"]) {
    return [Foursquare2 handleURL:url];
  }
  else if([url.absoluteString containsString:@"fb1377327292516803"]){
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
  }else if([url.absoluteString containsString:@"eventID"]) {
#warning need to handle an event link being opened in new hierarchy
//    handle event url being opened
//    NSArray *components = [url.absoluteString componentsSeparatedByString:@":"];
//    NSString *eventID = [components lastObject];
//    APSearchEventsViewController *vc = [[APSearchEventsViewController alloc] initWithSearchForEvent:eventID];
//    CRNavigationController *navController = [[CRNavigationController alloc] initWithRootViewController:vc];
//    navController.navigationBar.tintColor = [APStyleSheet blackColor];
//    UIViewController *view = [APAppDelegate topMostController];
//    [view presentViewController:navController animated:YES completion:nil];
  }else{
    return YES;
  }
  return NO;
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
