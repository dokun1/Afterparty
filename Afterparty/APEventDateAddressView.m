//
//  APEventDateAddressView.m
//  Afterparty
//
//  Created by David Okun on 2/24/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import "APEventDateAddressView.h"
#import "APLabel.h"
#import "UIColor+APColor.h"

@interface APEventDateAddressView ()

@property (nonatomic, strong) UIView *eventDateDayView;
@property (nonatomic, strong) UIView *eventDateMonthView;
@property (nonatomic, strong) UIView *eventDateTimeView;
@property (nonatomic, strong) UIView *eventDateAMPMView;
@property (nonatomic, strong) APLabel *eventDateDayLabel;
@property (nonatomic, strong) APLabel *eventDateMonthLabel;
@property (nonatomic, strong) APLabel *eventDateTimeLabel;
@property (nonatomic, strong) APLabel *eventDateAMPMLabel;
@property (nonatomic, strong) APLabel *eventAddressLabel;

@end

@implementation APEventDateAddressView

- (instancetype)initWithDate:(NSDate *)date andAddress:(NSString *)address {
    if (self = [super initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 80)]) {
        self.eventDateDayView = [self getFrameWithFrame:CGRectMake(10, 9, 65, 35)];
        self.eventDateMonthView = [self getFrameWithFrame:CGRectMake(10, 43, 65, 25)];
        self.eventDateTimeView = [self getFrameWithFrame:CGRectMake(85, 9, 65, 35)];
        self.eventDateAMPMView = [self getFrameWithFrame:CGRectMake(85, 43, 65, 25)];
        
        self.eventDateDayLabel = [[APLabel alloc] initWithFrame:self.eventDateDayView.frame];
        self.eventDateMonthLabel = [[APLabel alloc] initWithFrame:self.eventDateMonthView.frame];
        self.eventDateTimeLabel = [[APLabel alloc] initWithFrame:self.eventDateTimeView.frame];
        self.eventDateAMPMLabel = [[APLabel alloc] initWithFrame:self.eventDateAMPMView.frame];
        
        self.eventAddressLabel = [[APLabel alloc] initWithFrame:CGRectMake(160, 9, [UIScreen mainScreen].bounds.size.width - 180, 60)];
        self.eventAddressLabel.numberOfLines = 3;
        
        NSDateFormatter *formater = [self getDateFormatter];
        formater.dateFormat = @"MMM";
        NSString *monthString = [[formater stringFromDate:date]uppercaseString];
        [self.eventDateMonthLabel styleForType:LabelTypeNearbyDateView withText:monthString];
        formater.dateFormat = @"dd";
        [self.eventDateDayLabel styleForType:LabelTypeNearbyDateView withText:[formater stringFromDate:date]];
        formater.dateFormat = @"hh:mm";
        [self.eventDateTimeLabel styleForType:LabelTypeNearbyDateView withText:[formater stringFromDate:date]];
        formater.dateFormat = @"a";
        [self.eventDateAMPMLabel styleForType:LabelTypeNearbyDateView withText:[formater stringFromDate:date]];
        [self.eventAddressLabel styleForType:LabelTypeNearbyAddress withText:address];
        
        [self addSubview:self.eventDateDayLabel];
        [self addSubview:self.eventDateMonthLabel];
        [self addSubview:self.eventDateAMPMLabel];
        [self addSubview:self.eventDateTimeLabel];
        [self addSubview:self.eventAddressLabel];
    }
    return self;
}

- (NSDateFormatter *)getDateFormatter {
    static NSDateFormatter *__df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __df = [[NSDateFormatter alloc] init];
        __df.locale = [NSLocale currentLocale];
        __df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    });
    return __df;
}

- (UIView *)getFrameWithFrame:(CGRect)frame {
    UIView *returnView = [[UIView alloc] initWithFrame:frame];
    returnView.layer.borderColor = [UIColor afterpartyBlackColor].CGColor;
    returnView.layer.borderWidth = 1.0f;
    returnView.backgroundColor = [UIColor whiteColor];
    [self addSubview:returnView];
    return returnView;
}

@end
