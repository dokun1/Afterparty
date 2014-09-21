//
//  APSearchEventTableViewCellFactory.h
//  Afterparty
//
//  Created by Andrei Popa on 19/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSearchEventTableViewCells.h"
@class  APEvent;

@interface APSearchEventTableViewCellFactory : NSObject

+ (APSearchEventBaseTableViewCell *)initializedCellForTableView:(UITableView *)tableView
                                                    atIndexPath:(NSIndexPath *)indexPath
                                                       andEvent:(APEvent *)event;

+ (CGFloat)appropriateHeightForIndexPath:(NSIndexPath *)indexPath
                               andEvent:(APEvent *)event;


@end
