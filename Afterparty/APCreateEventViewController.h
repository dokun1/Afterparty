//
//  APCreateEventViewController.h
//  Afterparty
//
//  Created by David Okun on 6/28/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"

@class APCreateEventViewController;

@protocol CreateEventDelegate <NSObject>

@optional
- (void)controllerDidFinish:(APCreateEventViewController*)controller;

@end

@interface APCreateEventViewController : UIViewController

-(id)initForNewEvent;
-(id)initForEditingWithEvent:(APEvent*)event;

@property (weak, nonatomic) id<CreateEventDelegate> delegate;

@end
