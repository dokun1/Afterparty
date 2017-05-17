//
//  APSearchEventTableViewCell.h
//  Afterparty
//
//  Created by David Okun on 4/4/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLabel.h"

@interface APSearchEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet APLabel *userLabel;
@property (weak, nonatomic) IBOutlet APLabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet APLabel *countdownLabel;

@property (strong, nonatomic) NSString *coverPhotoID;

+ (CGFloat)suggestedCellHeight;

@end
