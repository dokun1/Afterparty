//
//  APSearchEventUserDetailsTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventUserDetailsTableViewCell.h"
#import "APConstants.h"
@implementation APSearchEventUserDetailsTableViewCell

- (void)awakeFromNib {
    self.authorBlurbLabel.font = [UIFont fontWithName:kBoldFont size:14.f];
    self.authorFullNameLabel.font = [UIFont fontWithName:kBoldFont size:16.f];
}

+ (NSString*)cellIdentifier {
    return @"APSearchEventUserDetailsTableViewCell";
}

+ (NSString *)nibFile {
    return @"APSearchEventUserDetailsTableViewCell";
}
@end
