//
//  APConnectionManager.m
//  AfterpartyRestTest
//
//  Created by David Okun on 6/4/14.
//  Copyright (c) 2014 Okun. All rights reserved.
//

#import "APRestConnectionManager.h"
#import <AFNetworking/AFNetworking.h>
#import <Foursquare-API-v2/Foursquare2.h>
#import "FSConverter.h"

NSString * const ParseApplicationID = @"CvhkqubpxeRFVm6j4HiMf237NWRjaYdPR1PC9vUE";
NSString * const ParseRestAPIKey    = @"HccXvSd74UIUZ226rMNsebRcBi7kEXeqAcANjxXg";
NSString * const APIRootAddress     = @"https://api.parse.com/1/";

@interface APRestConnectionManager ()

@property (strong, nonatomic) AFHTTPSessionManager *httpManager;

@end

@implementation APRestConnectionManager

+(instancetype)sharedManager {
  static APRestConnectionManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[APRestConnectionManager alloc] init];
  });
  return sharedManager;
}

-(id)init {
  self = [super init];
  if (self) {
    NSURL *baseURL = [NSURL URLWithString:APIRootAddress];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{@"X-Parse-Application-Id": ParseApplicationID,
                                       @"X-Parse-REST-API-Key": ParseRestAPIKey,
                                       @"Content-Type": @"application/json",
                                       @"Accept":@"application/json"}];
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                      diskCapacity:50 * 1024 * 1024
                                                          diskPath:nil];
    [config setURLCache:cache];
    
    self.httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                sessionConfiguration:config];
    [self.httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [self.httpManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
  }
  return self;
}

-(void)getAllUsersWithSuccess:(APSuccessObjectBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
  [self.httpManager GET:@"users"
             parameters:nil
                success:^(NSURLSessionDataTask *task, id responseObject) {
                  NSLog(@"%@", responseObject);
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  NSLog(@"error");
                }];
}

-(void)signUpUser:(NSDictionary *)userDict success:(APSuccessUserBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
  [self.httpManager POST:@"users" parameters:userDict success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error);
  }];
}

-(void)getNearbyVenuesForLocation:(CLLocation *)location success:(APSuccessArrayBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
  [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                               longitude:@(location.coordinate.longitude)
                                   query:nil
                                   limit:nil
                                  intent:intentCheckin
                                  radius:@(3000)
                              categoryId:nil callback:^(BOOL success, id result) {
                                if (success) {
                                  NSDictionary *dic = result;
                                  NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                  FSConverter *converter = [[FSConverter alloc] init];
                                  NSArray *nearbyVenues = [converter convertToObjects:venues];
                                  successBlock(nearbyVenues);
                                }else{
                                  NSError *error = [[NSError alloc] initWithDomain:@"com.dmos.afterparty" code:404 userInfo:@{@"Couldn't get venues" : NSLocalizedFailureReasonErrorKey}];
                                  failureBlock(error);
                                }
                              }];
}

-(void)searchVenuesByName:(NSString *)name atLocation:(CLLocation *)location success:(APSuccessArrayBlock)successBlock failure:(APFailureErrorBlock)failureBlock {
  [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                               longitude:@(location.coordinate.longitude)
                                   query:name
                                   limit:nil
                                  intent:intentBrowse
                                  radius:@(10000)
                              categoryId:nil callback:^(BOOL success, id result) {
                                if (success) {
                                  NSDictionary *dic = result;
                                  NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                  FSConverter *converter = [[FSConverter alloc] init];
                                  NSArray *nearbyVenues = [converter convertToObjects:venues];
                                  successBlock(nearbyVenues);
                                }else{
                                  NSError *error = [[NSError alloc] initWithDomain:@"com.dmos.afterparty" code:404 userInfo:@{@"Couldn't get venues" : NSLocalizedFailureReasonErrorKey}];
                                  failureBlock(error);
                                }
                              }];
}



@end
