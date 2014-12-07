//
//  APInviteFriendsViewController.m
//  Afterparty
//
//  Created by David Okun on 5/19/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APInviteFriendsViewController.h"
#import "APInviteFriendTableViewCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "UIColor+APColor.h"
#import "NSString+APString.h"
#import "APLabel.h"
#import "APConstants.h"

@import AddressBook;

@interface APInviteFriendsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *allContactDict;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableDictionary *filteredContactDict;
@property (strong, nonatomic) NSArray *sortedKeys;
@property (strong, nonatomic) UITextField *searchField;

@property (strong, nonatomic) TTTAttributedLabel *friendsSelectedLabel;

@end

@implementation APInviteFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self getAllContacts];
        self.selectedContacts = [NSMutableArray array];
    }
    return self;
}

- (id)initWithSelectedContacts:(NSArray *)selectedContacts {
    self = [super init];
    if (self) {
        [self getAllContacts];
        self.selectedContacts = [NSMutableArray arrayWithArray:selectedContacts];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"APInviteFriendTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"InviteFriendCell"];
    [self.tableView setSectionIndexColor:[UIColor afterpartyTealBlueColor]];
    [self.tableView setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self setTitle:@"CHOOSE INVITEES"];
    [self.tableView setTableHeaderView:[self getSearchHeader]];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    [self.navigationItem setRightBarButtonItems:@[btnSave]];
    [self filterResultsBySearch:self.searchField.text];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidChange:(UITextField*)textField {
    [self filterResultsBySearch:textField.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)filterResultsBySearch:(NSString*)searchString {
    if (!self.filteredContactDict) {
        self.filteredContactDict = [NSMutableDictionary dictionary];
    }
    if ([searchString isEqualToString:@""]) {
        self.filteredContactDict = self.allContactDict;
        self.sortedKeys = [[self.filteredContactDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        [self.tableView reloadData];
        return;
    }
    __block NSMutableDictionary *filteredContacts = [NSMutableDictionary dictionary];
    [self.allContactDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *contactResults, BOOL *stop) {
        __block NSMutableArray *filteredResultsForAKey = [NSMutableArray array];
        [contactResults enumerateObjectsUsingBlock:^(NSDictionary *contactDict, NSUInteger idx, BOOL *stop) {
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", contactDict[@"firstName"], contactDict[@"lastName"]];
            if ([fullName containsString:searchString]) {
                [filteredResultsForAKey addObject:contactDict];
            }
        }];
        if ([filteredResultsForAKey count] > 0) {
            NSArray *sortedArray;
            sortedArray = [filteredResultsForAKey sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *contactDict1, NSDictionary *contactDict2) {
                if ([key isEqualToString:@"#"]) {
                    NSString *phone1 = contactDict1[@"phone"];
                    NSString *phone2 = contactDict2[@"phone"];
                    
                    return [phone1 compare:phone2];
                }else{
                    NSString *name1;
                    NSString *name2;
                    
                    NSString *name1First = contactDict1[@"firstName"];
                    NSString *name1Last = contactDict1[@"lastName"];
                    
                    NSString *name2First = contactDict2[@"firstName"];
                    NSString *name2Last = contactDict2[@"lastName"];
                    
                    name1 = ([name1Last length] > 0) ? name1Last : name1First;
                    name2 = ([name2Last length] > 0) ? name2Last : name2First;
                    return [name1 compare:name2];
                }
            }];
            filteredContacts[key] = sortedArray;
        }
    }];
    self.filteredContactDict = filteredContacts;
    self.sortedKeys = [[self.filteredContactDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

-(UIView*)getSearchHeader {
    UIView *header = [[UIView alloc] init];
    [header setFrame:CGRectMake(0, 0, 320, 86)];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"icon_magnifyingglass"] forState:UIControlStateNormal];
    [searchButton setBackgroundColor:[UIColor afterpartyLightGrayColor]];
    [searchButton setFrame:CGRectMake(0, 0, 43, 43)];
    [header addSubview:searchButton];
    
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(43, 0, (self.view.bounds.size.width - searchButton.frame.size.width - 10), 43)];
    [self.searchField setFont:[UIFont fontWithName:kRegularFont size:18.f]];
    [self.searchField setPlaceholder:@"Search"];
    [self.searchField setDelegate:self];
    [self.searchField setReturnKeyType:UIReturnKeySearch];
    [self.searchField setBackgroundColor:[UIColor whiteColor]];
    [self.searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.searchField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [header addSubview:self.searchField];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.searchField setLeftViewMode:UITextFieldViewModeAlways];
    [self.searchField setLeftView:spacerView];
    
    self.friendsSelectedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(13, 43, 307, 43)];
    [self.friendsSelectedLabel setBackgroundColor:[UIColor whiteColor]];
    [self.friendsSelectedLabel setFont:[UIFont fontWithName:kRegularFont size:15.f]];
    [self setFriendCountLabel];
    [header addSubview:self.friendsSelectedLabel];
    
    return header;
}

-(void)setFriendCountLabel {
    NSString *selectedCount = [NSString stringWithFormat:@"%lu", (unsigned long)[self.selectedContacts count]];
    NSString *labelText = ([self.selectedContacts count] != 1)?[NSString stringWithFormat:@"You've invited %@ friends.", selectedCount]:[NSString stringWithFormat:@"You've invited %@ friend.", selectedCount];
    [self.friendsSelectedLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange numberRange = [labelText rangeOfString:selectedCount];
        if (numberRange.location != NSNotFound) {
            [mutableAttributedString addAttribute:(NSString*)kCTFontFamilyNameKey value:(NSString*)kBoldFont range:numberRange];
        }
        return mutableAttributedString;
    }];
}

-(void)getAllContacts {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook == nil) {
        return;
    }
    NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    self.allContactDict = [NSMutableDictionary dictionary];
    for (id record in contacts) {
        ABRecordRef contactPerson = (__bridge ABRecordRef)record;
        ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
        ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
        NSUInteger j = 0;
        NSString *email = @"";
        NSString *phone = @"";
        NSString *firstName = @"";
        NSString *lastName = @"";
        firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
        for (j = 0; j < ABMultiValueGetCount(emails); j++) {
            email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
        }
        j = 0;
        for (j = 0; j < ABMultiValueGetCount(phones); j++) {
            phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
        }
        if ([phone isEqualToString:@""]) { // we only want contacts that have phone numbers, so skip if there is none
            continue;
        }
        if (!firstName) {
            firstName = @"";
        }
        if (!lastName) {
            lastName = @"";
        }
        
        NSString *formattedPhone = [[phone componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                               componentsJoinedByString:@""]; //this helps get rid of markup text from phone numbers so we only get digits
        if ([formattedPhone length] < 9) { //we dont want to text any shortcodes or invalid numbers
            continue;
        }
        
        NSDictionary *contactDict = @{@"firstName":firstName,
                                      @"lastName":lastName,
                                      @"phone":formattedPhone,
                                      @"email":email};
        NSString *firstLetter = @"#";
        if ([lastName length] > 0) {
            firstLetter = [lastName substringToIndex:1];
        }else{
            if ([firstName length] > 0) {
                firstLetter = [firstName substringToIndex:1];
            }
        }
        NSMutableArray *orderedArray = self.allContactDict[firstLetter];
        if (!orderedArray) {
            orderedArray = [NSMutableArray array];
        }
        if ([orderedArray containsObject:contactDict]) {
            continue;
        }
        [orderedArray addObject:contactDict];
        self.allContactDict[firstLetter] = orderedArray;
    }
    self.sortedKeys = [[self.allContactDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    [self.sortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSMutableArray *contactsForKey = self.allContactDict[key];
        NSArray *sortedArray;
        sortedArray = [contactsForKey sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *contactDict1, NSDictionary *contactDict2) {
            if ([key isEqualToString:@"#"]) {
                NSString *phone1 = contactDict1[@"phone"];
                NSString *phone2 = contactDict2[@"phone"];
                
                return [phone1 compare:phone2];
            }else{
                NSString *name1;
                NSString *name2;
                
                NSString *name1First = contactDict1[@"firstName"];
                NSString *name1Last = contactDict1[@"lastName"];
                
                NSString *name2First = contactDict2[@"firstName"];
                NSString *name2Last = contactDict2[@"lastName"];
                
                name1 = ([name1Last length] > 0) ? name1Last : name1First;
                name2 = ([name2Last length] > 0) ? name2Last : name2First;
                return [name1 compare:name2];
            }
        }];
        self.allContactDict[key] = sortedArray;
    }];
    CFRelease(addressBook);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.filteredContactDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *header = self.sortedKeys[section];
    NSArray *contacts = self.filteredContactDict[header];
    return [contacts count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = self.sortedKeys[section];
    return header;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *header = [[UIView alloc] init];
  [header setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
  
  APLabel *titleLabel = [[APLabel alloc] initWithFrame:CGRectMake(10, 2, 100, 20)];
  [titleLabel styleForType:LabelTypeFriendHeader withText:[self tableView:self.tableView titleForHeaderInSection:section]];
  [header addSubview:titleLabel];
  return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.5f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InviteFriendCell";
    APInviteFriendTableViewCell *cell = (APInviteFriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[APInviteFriendTableViewCell alloc] init];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(APInviteFriendTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NSString *header = self.sortedKeys[indexPath.section];
    NSArray *contacts = self.filteredContactDict[header];
    NSDictionary *contactDict = contacts[indexPath.row];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", contactDict[@"firstName"], contactDict[@"lastName"]];
    if ([fullName isEqualToString:@" "]) {
        fullName = contactDict[@"phone"];
    }
    [cell.nameLabel styleForType:LabelTypeFriendInvite withText:fullName];
    BOOL isSelected = [self.selectedContacts containsObject:contactDict];
    [cell.buttonImage setImage:(isSelected)?[UIImage imageNamed:@"icon_checkgreen"]:[UIImage imageNamed:@"icon_checkempty"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *header = self.sortedKeys[indexPath.section];
    NSArray *contacts = self.filteredContactDict[header];
    NSDictionary *contactDict = contacts[indexPath.row];
    BOOL isSelected = [self.selectedContacts containsObject:contactDict];
    APInviteFriendTableViewCell *cell = (APInviteFriendTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    (isSelected) ? [self.selectedContacts removeObject:contactDict] : [self.selectedContacts addObject:contactDict];
    [cell.buttonImage setImage:(isSelected)?[UIImage imageNamed:@"icon_checkempty"]:[UIImage imageNamed:@"icon_checkgreen"]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setFriendCountLabel];
    [self.delegate didUpdateInvitees:self.selectedContacts forController:self];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView { //returns the scrub bar on right hand side
    return self.sortedKeys;
}

#pragma mark - FriendInviteDelegate

-(void)saveButtonTapped {
    [self.delegate didConfirmInvitees:self.selectedContacts forController:self];
}
@end
