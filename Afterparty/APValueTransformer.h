//
//  APValueTransformer.h
//  Afterparty
//
//  Created by David Okun on 7/4/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "APEvent.h"

@interface APValueTransformer : NSObject

+ (PFObject*)convertEvent:(APEvent*)event;

@end
