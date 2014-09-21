//
//  APSearchEventDescriptionTableViewCell.h
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APSearchEventBaseTableViewCell.h"

@interface APSearchEventDescriptionTableViewCell : APSearchEventBaseTableViewCell
@property (nonatomic, strong, readwrite) IBOutlet UITextView *eventDescriptionTextView;

@end