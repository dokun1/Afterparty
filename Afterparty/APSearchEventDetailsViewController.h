//
//  APSearchEventDetailsViewController.h
//  Afterparty
//
//  Created by David Okun on 2/19/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"
#import "APLabel.h"
#import "APButton.h"
#import "APUtil.h"
#import "UIAlertView+APAlert.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APMyEventViewController.h"
#import "APConstants.h"
#import "APSearchEventTableViewCellFactory.h"
#import "APCreateEventViewController.h"

@interface APSearchEventDetailsViewController : UIViewController

@property (nonatomic, strong) APEvent *currentEvent;


@end
