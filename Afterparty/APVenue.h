//
//  APVenue.h
//  Afterparty
//
//  Created by David Okun on 12/28/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"

@interface APVenue : FSVenue

@property (nonatomic, strong) NSString *prettyAddress;
@property (nonatomic, strong) NSString *iconURL;

@end
