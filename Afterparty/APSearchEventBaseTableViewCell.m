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

- (void)setEvent:(APEvent *)event{
    if (_event != event) {
        _event = event;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)updateUI {
    
}

- (CGFloat)cellHeight {
    return kAPSearchEventBaseTableViewCellDefaultCellHeight;
}


@end
