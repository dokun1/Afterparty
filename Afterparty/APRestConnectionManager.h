//
//  APConnectionManager.h
//  AfterpartyRestTest
//
//  Created by David Okun on 6/4/14.
//  Copyright (c) 2014 Okun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APUser.h"

@import CoreLocation;

@interface APRestConnectionManager : NSObject

typedef void (^APSuccessBooleanBlock)(BOOL succeeded);
typedef void (^APSuccessBooleanPlusObjectBlock)(BOOL succeeded, id object);
typedef void (^APSuccessArrayBlock)(NSArray *objects);
typedef void (^APSuccessDataBlock)(NSData *data);
typedef void (^APSuccessObjectBlock)(id object);
typedef void (^APSuccessUserBlock)(APUser *user);

typedef void (^APFailureErrorBlock)(NSError *error);

typedef void (^APProgressBlock)(int percentDone);


/**
 *  Thread-safe singleton instance of the connection manager needed for all calls.
 *
 *  @return instancetype singleton
 *
 *  @since 0.5.0
 */
+(instancetype)sharedManager;

/**
 *  This is a REST call to sign up a user given information in a dictionary.
 *
 *  @param userDict     NSDictionary of information to sign up user
 *  @param successBlock Returns an instance APUser object if the call was successful
 *  @param failureBlock Returns a NSError if the call was not successful
 */
-(void)signUpUser:(NSDictionary*)userDict
          success:(APSuccessUserBlock)successBlock
          failure:(APFailureErrorBlock)failureBlock;

/**
 *  This is a call to the Foursquare API to get nearby venues to your current location.
 *
 *  @param location     CLLocation retrieved from getting current location
 *  @param successBlock Returns NSArray of FSVenue objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)getNearbyVenuesForLocation:(CLLocation *)location
                          success:(APSuccessArrayBlock)successBlock
                          failure:(APFailureErrorBlock)failureBlock;

/**
 *  This is a call to the Foursquare API to search by location and a name query. This will use the Foursquare search engine to narrow places down, and no logic is done app-side
 *
 *  @param name         NSString of search query entered by user
 *  @param location     CLLocation retrieved from getting current location
 *  @param successBlock Returns NSArray of FSVenue objects
 *  @param failureBlock Returns NSError
 *
 *  @since 0.6.0
 */

-(void)searchVenuesByName:(NSString *)name
               atLocation:(CLLocation *)location
                  success:(APSuccessArrayBlock)successBlock
                  failure:(APFailureErrorBlock)failureBlock;


@end
