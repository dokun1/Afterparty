//
//  APSearchEventDescriptionTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventDescriptionTableViewCell.h"
@implementation APSearchEventDescriptionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor redColor];
}

+ (NSString*)cellIdentifier {
    return @"APSearchEventDescriptionTableViewCell";
}

+ (NSString *)nibFile {
    return @"APSearchEventDescriptionTableViewCell";
}

- (CGFloat)cellHeight {
    CGFloat cellHeight = 0;
    if (self.eventDescriptionTextView.text.length) {
        CGRect textNecessaryRect = [self.eventDescriptionTextView.text boundingRectWithSize: CGSizeMake(self.eventDescriptionTextView.bounds.size.width, NSUIntegerMax)
                                                                                    options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                                 attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}
                                                                                    context: nil];
        cellHeight = textNecessaryRect.size.height + 10.0;
    }
    return cellHeight;
}

@end
