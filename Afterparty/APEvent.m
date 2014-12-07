//
//  APEvent.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APEvent.h"
#import "APConstants.h"

@implementation APEvent

- (instancetype)initWithName:(NSString *)name venue:(FSVenue *)venue password:(NSString *)password startDate:(NSDate *)startDate endDate:(NSDate *)endDate deleteDate:(NSDate *)deleteDate createdByUsername:(NSString *)createdByUsername atLocation:(CLLocationCoordinate2D)location coverPhotoID:(NSString *)coverPhotoID eventDescription:(NSString *)eventDescription eventAddress:(NSString *)eventAddress eventImage:(UIImage *)eventImage eventUserPhotoURL:(NSString *)eventUserPhotoURL eventUserBlurb:(NSString *)eventUserBlurb{
  if (self = [super init]) {
    _eventName         = name;
    _eventVenue        = venue;
    _password          = password;
    _startDate         = startDate;
    _endDate           = endDate;
    _deleteDate        = deleteDate;
    _createdByUsername = createdByUsername;
    _objectID          = nil;
    _location          = location;
    _coverPhotoID      = coverPhotoID;
    _eventDescription  = eventDescription;
    _eventAddress      = (eventAddress) ? eventAddress : @"";
    _eventImage        = eventImage;
    _eventUserPhotoURL = eventUserPhotoURL;
    _eventUserBlurb    = eventUserBlurb;
    _attendees         = @[];
  }
  return self;
}

- (instancetype)initWithParseObject:(PFObject*)parseObject {
  if (self = [super init]) {
    _eventName         = parseObject[@"eventName"];
    _eventVenue        = nil;
    _password          = parseObject[@"password"];
    _startDate         = parseObject[@"startDate"];
    _endDate           = parseObject[@"endDate"];
    _deleteDate        = parseObject[@"deleteDate"];
    _createdByUsername = parseObject[@"createdByUsername"];
    _location          = CLLocationCoordinate2DMake([parseObject[@"latitude"] doubleValue],[parseObject[@"longitude"] doubleValue]);
    _objectID          = parseObject.objectId;
    _coverPhotoID      = parseObject[@"coverPhotoID"];
    _eventDescription  = parseObject[@"eventDescription"];
    _eventAddress      = (parseObject[@"eventAddress"]) ? parseObject[@"eventAddress"] : @"";
    _eventImage        = parseObject[@"eventImage"];
    _eventUserPhotoURL = parseObject[kPFUserProfilePhotoURLKey];
    _eventUserBlurb    = parseObject[kPFUserBlurbKey];
    _attendees         = parseObject[@"attendees"];
  }
  return self;
}

@end
