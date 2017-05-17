//
//  APPhotoInfo.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "APComment.h"

@interface APPhotoInfo : NSObject

@property (strong, nonatomic) NSString       *username;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSDate         *timestamp;
@property (strong, nonatomic) NSURL          *photoURL;
@property (strong, nonatomic) NSURL          *thumbURL;
@property (strong, nonatomic) NSString       *refID;
@property (strong, nonatomic) NSString       *eventID;
@property (strong, nonatomic) NSString       *thumbID;
@property (assign, nonatomic) CGSize         size;
@property (strong, nonatomic) NSNumber       *reports;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (instancetype)initWithParseObject:(PFObject*)parseObject
                           forEvent:(NSString*)eventID;

- (NSDictionary*)convertToDictionary;

- (void)addComment:(APComment*)comment;

@end
