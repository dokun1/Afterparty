//
//  APSearchEventDetailViewControllerNew.h
//  Afterparty
//
//  Created by David Okun on 4/4/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"

@class APSearchEventDetailViewController;

@protocol SearchEventDetailDelegate <NSObject>

@required
- (void)controllerDidSelectEvent:(APSearchEventDetailViewController*)controller;

@end

@interface APSearchEventDetailViewController : UIViewController

@property (weak, nonatomic) id<SearchEventDetailDelegate> delegate;

- (id)initWithEvent:(APEvent*)event;
- (void)setCurrentEvent:(APEvent*)event;

@end
