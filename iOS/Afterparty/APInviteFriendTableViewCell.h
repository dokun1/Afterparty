//
//  APInviteFriendTableViewCell.h
//  Afterparty
//
//  Created by David Okun on 5/19/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLabel.h"

@interface APInviteFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet APLabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buttonImage;

@end
