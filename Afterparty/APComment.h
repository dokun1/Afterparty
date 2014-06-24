//
//  APComment.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface APComment : NSObject

@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSDate   *timestamp;

- (instancetype)initWithComment:(NSString*)comment
                       username:(NSString*)username
                      timestamp:(NSDate*)timestamp;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)convertToDictionary;

@end
