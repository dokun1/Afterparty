//
//  UIAlertView+APAlert.m
//  Afterparty
//
//  Created by David Okun on 11/17/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "UIAlertView+APAlert.h"

@implementation UIAlertView (APAlert)

+ (void)showSimpleAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [simpleAlert show];
}

@end
