//
//  APCreateEventTimeViewController.h
//  Afterparty
//
//  Created by David Okun on 12/6/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCreateEventTimeViewController;

@protocol APEventTimeDelegate <NSObject>

- (void)updateForStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime;

@end

@interface APCreateEventTimeViewController : UITableViewController

@property (weak, nonatomic) id<APEventTimeDelegate> delegate;

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
