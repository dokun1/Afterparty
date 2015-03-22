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
- (void)controllerDidFinish:(APCreateEventViewController *)controller withEventID:(NSString*)eventID;
- (void)controllerDidFinishEditing:(APCreateEventViewController *)controller withEventID:(NSString *)eventID;
@end

@interface APCreateEventViewController : UIViewController

- (id)initForNewEvent;
- (id)initForEditingWithEvent:(APEvent*)event;
- (void)setEventForEditing:(APEvent *)event;

@property (weak, nonatomic) id<CreateEventDelegate> delegate;

@end
