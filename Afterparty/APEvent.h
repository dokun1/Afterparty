//
//  APEvent.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"
#import "APUser.h"
#import <Parse/Parse.h>

@interface APEvent : NSObject

@property (strong, nonatomic) NSString               *objectID;
@property (strong, nonatomic) NSString               *eventName;
@property (strong, nonatomic) FSVenue                *eventVenue;
@property (strong, nonatomic) NSString               *password;
@property (strong, nonatomic) NSString               *createdByUsername;
@property (strong, nonatomic) NSDate                 *startDate;
@property (strong, nonatomic) NSDate                 *endDate;
@property (strong, nonatomic) NSDate                 *deleteDate;
@property (assign, nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) NSString               *coverPhotoID;
@property (strong, nonatomic) NSString               *eventDescription;
@property (strong, nonatomic) NSString               *eventAddress;
@property (strong, nonatomic) UIImage                *eventImage;
@property (strong, nonatomic) NSData                 *eventImageData;
@property (strong, nonatomic) NSString               *eventUserPhotoURL;
@property (strong, nonatomic) NSString               *eventUserBlurb;

- (instancetype)initWithName:(NSString*)name
                       venue:(FSVenue*)venue
                    password:(NSString*)password
                   startDate:(NSDate*)startDate
                     endDate:(NSDate*)endDate
                  deleteDate:(NSDate*)deleteDate
           createdByUsername:(NSString*)createdByUsername
                  atLocation:(CLLocationCoordinate2D)location
                coverPhotoID:(NSString*)coverPhotoID
            eventDescription:(NSString*)eventDescription
                eventAddress:(NSString*)eventAddress
                  eventImage:(UIImage*)eventImage
           eventUserPhotoURL:(NSString*)eventUserPhotoURL
              eventUserBlurb:(NSString*)eventUserBlurb;

- (instancetype)initWithParseObject:(PFObject*)parseObject;

@end
