//
//  APEventAnnotation.m
//  Afterparty
//
//  Created by David Okun on 12/1/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APEventAnnotation.h"

@implementation APEventAnnotation

- (instancetype)initWithEvent:(APEvent *)event {
    if (self = [super init]) {
        _event = event;
        _title = event.eventName;
        _subtitle = [NSString stringWithFormat:@"%lu Attendees", (unsigned long)event.attendees.count];
        _coordinate = event.location;
    }
    return self;
}

@end
