//
//  APVenueTableViewCell.h
//  Afterparty
//
//  Created by David Okun on 3/26/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APVenueTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *venueName;
@property (weak, nonatomic) IBOutlet UILabel *venueAddress;
@property (weak, nonatomic) IBOutlet UILabel *venueDistance;

@end
