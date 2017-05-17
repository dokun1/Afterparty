//
//  APCreateEventPasswordViewController.m
//  Afterparty
//
//  Created by David Okun on 12/6/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCreateEventPasswordViewController.h"
#import "APLabel.h"
#import "UIColor+APColor.h"
#import "APConstants.h"

@interface APCreateEventPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *passwordLock;
@property (weak, nonatomic) IBOutlet UIImageView *confirmPasswordLock;

@property (weak, nonatomic) IBOutlet APLabel *topDescriptionLabel;
@property (weak, nonatomic) IBOutlet APLabel *bottomDescriptionLabel;
@property (weak, nonatomic) IBOutlet APLabel *noMatchLabel;

@property (nonatomic) BOOL firstPasswordEntered;

@end

@implementation APCreateEventPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topDescriptionLabel styleForType:LabelTypeCreateLabel];
    [self.bottomDescriptionLabel styleForType:LabelTypeCreateLabel];
    [self.noMatchLabel styleForType:LabelTypeCreateLabel];
    self.noMatchLabel.textColor = [UIColor afterpartyCoralRedColor];
    [self formatTextField:self.passwordTextField];
    [self formatTextField:self.confirmPasswordTextField];
    self.firstPasswordEntered = NO;
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    [self.navigationItem setRightBarButtonItems:@[btnSave]];
}

- (void)formatTextField:(UITextField *)textField {
    textField.font = [UIFont fontWithName:kRegularFont size:15.f];
    textField.textColor = [UIColor afterpartyBlackColor];
    textField.delegate = self;
    textField.returnKeyType = [textField isEqual:self.passwordTextField] ? UIReturnKeyNext : UIReturnKeyDone;
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - UITextFieldDelegate 

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.firstPasswordEntered) {
        [self checkPasswordValidity];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.confirmPasswordTextField) {
        self.firstPasswordEntered = YES;
        [self checkPasswordValidity];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "]) {
        return NO;
    } else {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 10 || returnKey;
    }
}

- (BOOL)checkPasswordValidity {
    if (self.passwordTextField.text.length < 5) {
        self.noMatchLabel.text = @"You need a longer password!";
        self.noMatchLabel.hidden = NO;
        [self.passwordLock setImage:[UIImage imageNamed:@"lockRed"]];
        return NO;
    } else {
        [self.passwordLock setImage:[UIImage imageNamed:@"lockGreen"]];
    }
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        self.noMatchLabel.text = @"Oops, they don't match! Please re-enter.";
        self.noMatchLabel.hidden = NO;
        [self.confirmPasswordLock setImage:[UIImage imageNamed:@"lockRed"]];
        return NO;
    } else {
        [self.confirmPasswordLock setImage:[UIImage imageNamed:@"lockGreen"]];
        self.noMatchLabel.hidden = YES;
    }
    if ([self.delegate respondsToSelector:@selector(controller:didUpdatePassword:)]) {
        [self.delegate controller:self didUpdatePassword:self.passwordTextField.text];
    }
    return YES;
}

- (void)saveButtonTapped {
    if ([self checkPasswordValidity]) {
        if ([self.delegate respondsToSelector:@selector(controller:didSavePassword:)]) {
            [self.delegate controller:self didSavePassword:self.passwordTextField.text];
        }
    }
}

@end
