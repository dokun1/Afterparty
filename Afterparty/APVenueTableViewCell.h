//
//  APVenueTableViewCell.h
//  Afterparty
//
//  Created by David Okun on 3/26/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLabel.h"

@interface APVenueTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet APLabel *venueName;
@property (weak, nonatomic) IBOutlet APLabel *venueAddress;
@property (weak, nonatomic) IBOutlet UIImageView *venueIcon;

@end
