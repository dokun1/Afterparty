//
//  APComment.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APComment.h"

@implementation APComment

- (instancetype)initWithComment:(NSString*)comment
                       username:(NSString*)username
                      timestamp:(NSDate*)timestamp {
  if (self = [super init]) {
    _comment = comment;
    _username = username;
    _timestamp = timestamp;
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
  if (self = [super init]) {
    NSDictionary *dict = [[dictionary allValues] firstObject];
    _comment = [[dictionary allKeys] firstObject];
    _username = dict[@"username"];
    _timestamp = dict[@"timestamp"];
  }
  return self;
}

- (NSDictionary*)convertToDictionary {
  NSDictionary *dict = @{@"username" : self.username,
                         @"timestamp": self.timestamp};
  NSDictionary *finalDict = @{self.comment : dict};
  return finalDict;
}

@end
