//
//  APSearchEventBaseTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

static CGFloat const kAPSearchEventBaseTableViewCellDefaultCellHeight = 100.0;

#import "APSearchEventBaseTableViewCell.h"

@implementation APSearchEventBaseTableViewCell

+ (NSString*)cellIdentifier {
    return @"APSearchEventBaseTableViewCell";
}

+ (NSString *)nibFile {
    return @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)cellHeight {
    return kAPSearchEventBaseTableViewCellDefaultCellHeight;
}

+ (instancetype)cellInstanceFromNib {
    if ([self nibFile].length) {
        return [[[NSBundle mainBundle] loadNibNamed:[self nibFile] owner:self options:nil] objectAtIndex:0];
    } else {
        return nil;
    }
}


@end
