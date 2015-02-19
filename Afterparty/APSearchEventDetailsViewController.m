//
//  APSearchEventDetailsViewController.m
//  Afterparty
//
//  Created by David Okun on 2/19/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import "APSearchEventDetailsViewController.h"

@interface APSearchEventDetailsViewController ()

@end

@implementation APSearchEventDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //init logic
    }
    return self;
}

- (void)setCurrentEvent:(APEvent *)currentEvent {
    NSLog(@"setting");
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.currentEvent.eventName;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
