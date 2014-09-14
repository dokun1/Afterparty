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
@property (nonatomic, strong, readwrite) APEvent *event;

- (void)updateUI;
- (CGFloat)cellHeight;

+ (NSString *)cellIdentifier;
+ (NSString *)nibFile;

@end
