//
//  APCreateEventTimeViewController.m
//  Afterparty
//
//  Created by David Okun on 12/6/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCreateEventTimeViewController.h"

@interface APCreateEventTimeViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@end

@implementation APCreateEventTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startDatePicker.minimumDate = [NSDate date];
    self.endTimePicker.date = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 4];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    [self.navigationItem setRightBarButtonItems:@[btnSave]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self datePickerUpdated:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (IBAction)datePickerUpdated:(id)sender {
    if ([self.delegate respondsToSelector:@selector(updateForStartTime:andEndTime:)]) {
        [self.delegate updateForStartTime:self.startDatePicker.date andEndTime:self.endTimePicker.date];
    }
}

- (void)saveButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
