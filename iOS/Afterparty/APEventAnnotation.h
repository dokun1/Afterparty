//
//  APEventAnnotation.h
//  Afterparty
//
//  Created by David Okun on 12/1/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APEvent.h"

@interface APEventAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithEvent:(APEvent *)event;

@property (nonatomic, readonly) APEvent *event;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
