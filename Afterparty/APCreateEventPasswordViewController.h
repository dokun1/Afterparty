//
//  APCreateEventPasswordViewController.h
//  Afterparty
//
//  Created by David Okun on 12/6/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCreateEventPasswordViewController;

@protocol PasswordDelegate <NSObject>

- (void)controller:(APCreateEventPasswordViewController *)controller didSavePassword:(NSString *)password;
- (void)controller:(APCreateEventPasswordViewController *)controller didUpdatePassword:(NSString *)password;

@end

@interface APCreateEventPasswordViewController : UIViewController

@property (weak, nonatomic) id<PasswordDelegate> delegate;

@end
