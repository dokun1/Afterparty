//
//  APNewVenueController.h
//  Afterparty
//
//  Created by David Okun on 3/14/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APVenue.h"

@class APNewVenueController;

@protocol NewVenueDelegate <NSObject>

@required

- (void)controller:(APNewVenueController *)controller didCreateNewVenue:(APVenue *)newVenue;
- (void)controllerDidCancel:(APNewVenueController *)controller;

@end

@interface APNewVenueController : UIViewController

@property (weak, nonatomic) id <NewVenueDelegate> delegate;

@end
