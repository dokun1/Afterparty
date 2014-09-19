//
//  APSearchEventTableViewCellFactory.m
//  Afterparty
//
//  Created by Andrei Popa on 19/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventTableViewCellFactory.h"

@implementation APSearchEventTableViewCellFactory

+ (APSearchEventBaseTableViewCell *)initializedCellForTableView:(UITableView *)tableView
                                                    atIndexPath:(NSIndexPath *)indexPath
                                                       andEvent:(APEvent *)event {
    NSString *identifier = nil;
    switch (indexPath.row) {
        case 0: {
            identifier = [APSearchEventUserDetailsTableViewCell cellIdentifier];
            APSearchEventUserDetailsTableViewCell *cell = nil;
            if (tableView) {
                cell = (APSearchEventUserDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventUserDetailsTableViewCell cellIdentifier] forIndexPath:indexPath];
            } else {
                cell = [APSearchEventUserDetailsTableViewCell cellInstanceFromNib];
            }
            cell.authorFullNameLabel.text = [event.createdByUsername capitalizedString];
            cell.authorBlurbLabel.text = [event.eventUserBlurb capitalizedString];
            if (event.eventUserPhotoURL.length) {
                cell.avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:event.eventUserPhotoURL]]];
            }
            return cell;
        }
        case 1: {
            identifier = [APSearchEventDescriptionTableViewCell cellIdentifier];
            APSearchEventDescriptionTableViewCell *cell = nil;
            if (tableView) {
                cell = (APSearchEventDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventDescriptionTableViewCell cellIdentifier] forIndexPath:indexPath];
            } else {
                cell = [APSearchEventDescriptionTableViewCell cellInstanceFromNib];
            }
            cell.eventDescriptionTextView.text = event.eventDescription;
            return cell;
        }
        case 2: {
            identifier = [APSearchEventDateLocationTableViewCell cellIdentifier];
            APSearchEventDateLocationTableViewCell *cell = nil;
            if (tableView) {
                cell = (APSearchEventDateLocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventDateLocationTableViewCell cellIdentifier]                                                                                                                           forIndexPath:indexPath];
            } else {
                cell = [APSearchEventDateLocationTableViewCell cellInstanceFromNib];
            }
            if (event.startDate != nil) {
                NSDateFormatter *formater = [NSDateFormatter new];
                formater.dateFormat = @"MMM";
                formater.locale = [NSLocale currentLocale];
                formater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
                NSString *monthString = [[formater stringFromDate:event.startDate]uppercaseString];
                cell.eventDateMonthLabel.text = [monthString substringToIndex:monthString.length - 1];
                formater.dateFormat = @"dd";
                cell.eventDateDayLabel.text = [formater stringFromDate:event.startDate];
                formater.dateFormat = @"hh:mm";
                cell.eventDateHourLabel.text = [formater stringFromDate:event.startDate];
                formater.dateFormat = @"a";
                cell.eventAmPMLabel.text = [formater stringFromDate:event.startDate];
                cell.eventAddressLabel.text = event.eventAddress;
            }
            
            return cell;
        }
        default: {
            identifier = [APSearchEventBaseTableViewCell cellIdentifier];
            APSearchEventBaseTableViewCell *cell = nil;
            if (tableView) {
                cell = (APSearchEventBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventBaseTableViewCell cellIdentifier]
                                                                                                                                forIndexPath:indexPath];
            } else {
                cell = [APSearchEventBaseTableViewCell cellInstanceFromNib];
            }
            return cell;
        }
    }
}

+ (CGFloat)appropriateHeightForIndexPath:(NSIndexPath *)indexPath
                                andEvent:(APEvent *)event {
    CGFloat cellHeight = 0;
    APSearchEventBaseTableViewCell *cell = [self initializedCellForTableView:nil atIndexPath:indexPath andEvent:event];
    cellHeight = [cell cellHeight];
    return cellHeight;
}

@end
