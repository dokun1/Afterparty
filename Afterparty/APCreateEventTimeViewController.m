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
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@property (copy, nonatomic) NSDate *startDate;
@property (copy, nonatomic) NSDate *endDate;

@end

@implementation APCreateEventTimeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.endDatePicker.date = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 4];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    [self.navigationItem setRightBarButtonItems:@[btnSave]];
    
    if (self.startDate && self.endDate) {
        self.startDatePicker.date = self.startDate;
        self.endDatePicker.date = self.endDate;
    } else {
        self.startDatePicker.minimumDate = [NSDate date];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self datePickerUpdated:nil];
}

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    self.startDate = [NSDate date];
    self.endDate = [NSDate date];
    self.startDate = startDate;
    self.endDate = endDate;
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
        [self.delegate updateForStartTime:self.startDatePicker.date andEndTime:self.endDatePicker.date];
    }
}

- (void)saveButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
