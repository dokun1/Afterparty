//
//  APMyEventUpdateLocationViewController.h
//  Afterparty
//
//  Created by David Okun on 4/20/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APVenue.h"

@protocol UpdateLocationDelegate <NSObject>

-(void)venueSuccessfullyUpdated:(APVenue*)newVenue;

@end

@interface APMyEventUpdateLocationViewController : UITableViewController

-(id)initWithCurrentLocation:(CLLocation*)currentLocation forEventID:(NSString*)eventID;

@property (weak, nonatomic) id<UpdateLocationDelegate> delegate;

@end
