//
//  APSearchEventUserDetailsTableViewCell.h
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APSearchEventBaseTableViewCell.h"

@interface APSearchEventUserDetailsTableViewCell : APSearchEventBaseTableViewCell
@property (nonatomic, strong, readwrite) IBOutlet UILabel *authorFullNameLabel; // capital letters
@property (nonatomic, strong, readwrite) IBOutlet UILabel *authorBlurbLabel; // capital letters
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *avatarImageView;

@end
