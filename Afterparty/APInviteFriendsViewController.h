//
//  APInviteFriendsViewController.h
//  Afterparty
//
//  Created by David Okun on 5/19/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendInviteDelegate <NSObject>

-(void)didConfirmInvitees:(NSArray*)invitees;

@end

@interface APInviteFriendsViewController : UITableViewController

-(id)initWithSelectedContacts:(NSArray*)selectedContacts;

@property (weak, nonatomic) id<FriendInviteDelegate> delegate;

@end
