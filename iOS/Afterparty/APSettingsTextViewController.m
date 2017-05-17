//
//  APSettingsTextViewController.m
//  Afterparty
//
//  Created by David Okun on 11/30/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSettingsTextViewController.h"
#import "APConstants.h"
#import "UIColor+APColor.h"

static NSString *kWhatsNewFilePath = @"APWhatsNew";

@interface APSettingsTextViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) BOOL isWhatsNew;

@end

@implementation APSettingsTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
    self.isWhatsNew = [self.textFilePath isEqualToString:kWhatsNewFilePath];
    [self loadTextViewContent];
    self.title = self.isWhatsNew ? @"WHAT'S NEW" : @"T'S & C'S";
}

-(void)loadTextViewContent {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.textFilePath ofType:@"json"];
    NSDictionary *jsonDict = [self dictionaryWithContentsOfJSONString:filePath];
    
    NSMutableString *textString = [NSMutableString stringWithString:@"\n"];
    NSMutableArray *sortedKeys = [[jsonDict allKeys] mutableCopy];
    
    [sortedKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *key1 = (NSString*)obj1;
        NSString *key2 = (NSString*)obj2;
        
        return self.isWhatsNew ? [self string:key2 isGreaterThanString:key1] : [self string:key1 isGreaterThanString:key2];
    }];
    
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString *key = sortedKeys[i];
        NSDictionary *refineDict = [jsonDict valueForKey:key];
        [textString appendString:self.isWhatsNew ? @"v" : @"§ "];
        [textString appendString:[NSString stringWithFormat:@"%@\n", key]];
        for (NSString *string in refineDict) {
            [textString appendString:[NSString stringWithFormat:@"\u2022 %@\n", [refineDict valueForKey:string]]];
        }
        [textString appendString:@"\n\n"];
    }
    
    self.textView.text = textString;
    self.textView.font = [UIFont fontWithName:kRegularFont size:15.f];
}

-(BOOL)string:(NSString*)str1 isGreaterThanString:(NSString*)str2
{
    NSArray *a1 = [str1 componentsSeparatedByString:@"."];
    NSArray *a2 = [str2 componentsSeparatedByString:@"."];
    
    NSInteger totalCount = ([a1 count] < [a2 count]) ? [a1 count] : [a2 count];
    NSInteger checkCount = 0;
    
    while (checkCount < totalCount) {
        if([a1[checkCount] integerValue] < [a2[checkCount] integerValue]) {
            return NO;
        } else if([a1[checkCount] integerValue] > [a2[checkCount] integerValue]) {
            return YES;
        } else {
            checkCount++;
        }
    }
    
    return NO;
}

-(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation{
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil){
        return nil;
    }
    return result;
}

@end
