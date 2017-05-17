//
//  UIColor+APColor.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (APColor)

+ (UIColor*)colorWithHexString:(NSString *)hex withAlpha:(CGFloat)alpha;

+ (UIColor*)afterpartyTealBlueColor;
+ (UIColor*)afterpartyCoralRedColor;
+ (UIColor*)afterpartyBrightGreenColor;
+ (UIColor*)afterpartyBlackColor;
+ (UIColor*)afterpartyLightGrayColor;
+ (UIColor*)afterpartyPasswordLightGrayColor;
+ (UIColor*)afterpartyDarkGrayColor;
+ (UIColor*)afterpartyRedColor;
+ (UIColor*)afterpartyOffWhiteColor;
+ (UIColor*)afterpartyLoginBackgroundColor;

@end
