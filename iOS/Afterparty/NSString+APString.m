//
//  NSString+APString.m
//  Afterparty
//
//  Created by David Okun on 11/17/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "NSString+APString.h"

@implementation NSString (APString)

-(BOOL)containsString:(NSString *)string {
    NSRange range = [self rangeOfString:string options:NSCaseInsensitiveSearch];
    return !(range.location == NSNotFound);
}

@end
