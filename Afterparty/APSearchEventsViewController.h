//
//  AfterpartySearchEventsViewController.h
//  Afterparty
//
//  Created by David Okun on 11/13/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APConnectionManager.h"

@interface APSearchEventsViewController : UITableViewController

-(id)initWithSearchForEvent:(NSString*)eventID;

@end
