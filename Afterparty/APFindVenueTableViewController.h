//
//  APCreateEventChooseVenueTableViewController.h
//  Afterparty
//
//  Created by David Okun on 5/13/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVenue.h"

@protocol VenueChoiceDelegate <NSObject>

-(void)controllerDidChooseVenue:(FSVenue*)venue;

@end

@interface APFindVenueTableViewController : UITableViewController

@property (weak, nonatomic) id<VenueChoiceDelegate> delegate;

@end