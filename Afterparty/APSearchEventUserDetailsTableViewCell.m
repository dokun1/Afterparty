//
//  APSearchEventUserDetailsTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventUserDetailsTableViewCell.h"
@interface APSearchEventUserDetailsTableViewCell()
@property (nonatomic, strong, readwrite) IBOutlet UILabel *authorFullNameLabel; // capital letters
@property (nonatomic, strong, readwrite) IBOutlet UILabel *authorBlurbLabel; // capital letters
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *avatarImageView;
@end

@implementation APSearchEventUserDetailsTableViewCell
- (void)awakeFromNib
{
    // Initialization code
    [self updateUI];
}

#pragma mark - External methods Implementation
- (void)updateUI {
    self.authorFullNameLabel.text = [self.event.createdByUsername capitalizedString];
    self.authorBlurbLabel.text = [self.event.eventUserBlurb capitalizedString];
    if (self.event.eventUserPhotoURL.length) {
        self.avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.event.eventUserPhotoURL]]];
    }
}

+ (NSString*)cellIdentifier {
    return @"APSearchEventUserDetailsTableViewCell";
}

+ (NSString *)nibFile {
    return @"APSearchEventUserDetailsTableViewCell";
}
@end
