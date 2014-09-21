//
//  APSearchEventBaseTableViewCell.h
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"

@interface APSearchEventBaseTableViewCell : UITableViewCell

+ (instancetype)cellInstanceFromNib;
- (CGFloat)cellHeight;

+ (NSString *)cellIdentifier;
+ (NSString *)nibFile;

@end
