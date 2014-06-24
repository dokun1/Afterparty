//
//  UIColor+APColor.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "UIColor+APColor.h"

@implementation UIColor (APColor)

+ (UIColor*)colorWithHexString:(NSString *)hex withAlpha:(CGFloat)alpha {
  NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
  
  if ([cString length] < 6) {
    return [UIColor grayColor];
  }
  
  if ([cString hasPrefix:@"0X"]) {
    cString = [cString substringFromIndex:2];
  }
  
  if ([cString length] != 6) {
    return [UIColor grayColor];
  }
  
  NSRange range;
  range.location = 0;
  range.length = 2;
  NSString *rString = [cString substringWithRange:range];
  
  range.location = 2;
  NSString *gString = [cString substringWithRange:range];
  
  range.location = 4;
  NSString *bString = [cString substringWithRange:range];
  
  unsigned int r,g,b;
  [[NSScanner scannerWithString:rString] scanHexInt:&r];
  [[NSScanner scannerWithString:gString] scanHexInt:&g];
  [[NSScanner scannerWithString:bString] scanHexInt:&b];
  
  return [UIColor colorWithRed:((float) r / 255.0f)
                         green:((float) g / 255.0f)
                          blue:((float) b / 255.0f)
                         alpha:alpha];
  
}

+ (UIColor*)afterpartyTealBlueColor {
  return [self colorWithHexString:@"24AFB2" withAlpha:1.0f];
}

+ (UIColor*)afterpartyCoralRedColor {
  return [self colorWithHexString:@"F15849" withAlpha:1.0f];
}

+ (UIColor*)afterpartyBrightGreenColor {
  return [self colorWithHexString:@"4DD865" withAlpha:1.0f];
}

+ (UIColor*)afterpartyBlackColor {
  return [self colorWithHexString:@"1C1C1C" withAlpha:1.0f];
}

+ (UIColor*)afterpartyLightGrayColor {
  return [self colorWithHexString:@"9B9B9B" withAlpha:1.0f];
}

+ (UIColor*)afterpartyPasswordLightGrayColor {
  return [self colorWithHexString:@"C9C9CE" withAlpha:1.0f];
}

+ (UIColor*)afterpartyDarkGrayColor {
  return [self colorWithHexString:@"666666" withAlpha:1.0f];
}

+ (UIColor*)afterpartyRedColor {
  return [self colorWithHexString:@"FF3B30" withAlpha:1.0f];
}

+ (UIColor*)afterpartyOffWhiteColor {
  return [self colorWithHexString:@"EEEEEE" withAlpha:1.0f];
}



@end
