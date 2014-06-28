//
//  APCreateEventViewController.h
//  Afterparty
//
//  Created by David Okun on 6/28/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"

@interface APCreateEventViewController : UIViewController

-(id)initForNewEvent;
-(id)initForEditingWithEvent:(APEvent*)event;

@end
