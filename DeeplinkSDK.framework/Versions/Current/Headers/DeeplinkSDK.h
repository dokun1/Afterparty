//
//  DeeplinkSDK.h
//  DeeplinkSDK
//
//  Created by Amit Attias on 2/2/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const DLQueryParam = @"DLQueryParam";
static NSString *const DLLimitParam;
static NSString *const DLRangeParam;
static NSString *const DLLocationParam;
static NSString *const DLHostsParam = @"DLHostsParam";
static NSString *const DLCategoriesParam = @"DLCategoriesParam";
static NSString *const DLOpenHoursParam;

@interface DLResultObject : NSObject
@property (nonatomic, readonly) NSURL *deeplink;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSString *title;
@end

typedef void (^CompletionHandlerType)(NSError *error, DLResultObject *result);

@interface DeeplinkSDK : NSObject

+(DeeplinkSDK *)sharedInstance;

-(void)initiateWithApiKey:(NSString *)apiKey andAppID:(NSString *)appID completion:(void(^)(BOOL succeeded))completionHandler;
-(void)getLinkWithKeywords:(NSString *)keywords completion:(CompletionHandlerType)completionHandler;
-(void)handleOpenURL:(NSURL *)url;

@end