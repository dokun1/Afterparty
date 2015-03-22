//
//  APEventNotification.h
//  Afterparty
//
//  Created by David Okun on 3/22/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EventNotificationType) {
    EventNotificationTypeEventEnded = 0,
    EventNotificationTypeEventOneHourFromDelete,
    EventNotificationTypeEventDeleted,
    EventNotificationTypeOther
};

@interface APEventNotification : NSObject

@property (copy, nonatomic) NSString *eventID;
@property (nonatomic) EventNotificationType notificationType;

@end
