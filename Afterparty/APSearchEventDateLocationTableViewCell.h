//
//  APSearchEventDateLocationTableViewCell.h
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APSearchEventBaseTableViewCell.h"

@interface APSearchEventDateLocationTableViewCell : APSearchEventBaseTableViewCell
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateDayLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateMonthLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateHourLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventAmPMLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventAddressLabel;


@end
