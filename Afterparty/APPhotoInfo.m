//
//  APPhotoInfo.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APPhotoInfo.h"

@implementation APPhotoInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  if (self = [super init]) {
    _username            = dictionary[@"username"];
    _timestamp           = dictionary[@"timestamp"];
    _refID               = dictionary[@"refID"];
    _thumbID             = dictionary[@"thumbID"];
    _eventID             = dictionary[@"eventID"];
    _size                = CGSizeMake([dictionary[@"width"] floatValue], [dictionary[@"height"] floatValue]);
    NSArray *commentArray    = [dictionary objectForKey:@"comments"];
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:commentArray.count];
    for (NSDictionary *commentDict in commentArray)
      [comments addObject:[[APComment alloc] initWithDictionary:commentDict]];
    _comments            = comments;
  }
  return self;
}

- (instancetype)initWithParseObject:(PFObject *)parseObject forEvent:(NSString *)eventID {
  if (self = [super init]) {
    _username  = parseObject[@"user"];
    _timestamp = parseObject[@"timestamp"];
    _refID     = parseObject[@"refID"];
    _thumbID   = parseObject[@"thumbID"];
    _comments  = [NSMutableArray array];
    _size      = CGSizeMake([parseObject[@"width"] floatValue], [parseObject[@"height"] floatValue]);
    for (NSDictionary *commentDict in [parseObject valueForKey:@"comments"])
      [_comments addObject:[[APComment alloc] initWithDictionary:commentDict]];
    _eventID   = eventID;
    PFFile *photoFile = parseObject[@"imageFile"];
    PFFile *thumbFile = parseObject[@"thumbFile"];
    _photoURL = [NSURL URLWithString:photoFile.url];
    _thumbURL = [NSURL URLWithString:thumbFile.url];
  }
  return self;
}

- (NSDictionary*)convertToDictionary {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:_username forKey:@"username"];
  [dict setObject:_timestamp forKey:@"timestamp"];
  [dict setObject:_refID forKey:@"refID"];
  [dict setObject:_thumbID forKey:@"thumbID"];
  [dict setObject:_eventID forKey:@"eventID"];
  [dict setObject:[NSNumber numberWithFloat:_size.width] forKey:@"width"];
  [dict setObject:[NSNumber numberWithFloat:_size.height] forKey:@"height"];
  NSMutableArray *commentArray = [NSMutableArray arrayWithCapacity:_comments.count];
  for (APComment *comment in _comments)
    [commentArray addObject:[comment convertToDictionary]];
  [dict setObject:[NSArray arrayWithArray:commentArray] forKey:@"comments"];
  
  return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)addComment:(APComment*)comment {
  [_comments addObject:comment];
}

-(NSString *)description {
  return [NSString stringWithFormat:@"username=%@\ntimestamp=%@\ncomments=%@\nrefID=%@\nthumbID=%@\neventID=%@", self.username, self.timestamp, self.comments, self.refID, self.thumbID, self.eventID];
}
@end
