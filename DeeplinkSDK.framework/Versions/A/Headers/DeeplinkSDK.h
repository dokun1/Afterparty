//
//  DeeplinkSDK.h
//  DeeplinkSDK
//
//  Created by Amit Attias on 2/2/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @p NSError domain for the Deeplinkme SDK.
 *
 * @description All @p NSError instances returned from the SDK are in this domain.
 */
extern NSString *const DLMEErrorDomain;

/**
 * Deeplinkme @p NSError error codes.
 *
 * @description All @p NSError instances returned from the SDK use codes from this enumeration.
 */
typedef enum : NSUInteger {
    DLMEErrorNone = 0,
    /// Error not known to the Deeplinkme SDK.
    DLMEErrorUnknownError,
    /// One or more of the parameters passed to the API is invalid.
    DLMEErrorBadParameters,
    /// User has enabled limited ad tracking.
    DLMEErrorLimitedAdTracking,
    /// The user has not installed any Marketplace apps.
    DLMEErrorNoMarketplaceAppsInstalled,
    /// DeeplinkSDK initialization has not yet completed successfully.
    DLMEErrorNotInitalized,
    /// The Deeplinkme SDK is busy handling a prior request.
    DLMEErrorBusy,
    /// Problem communicating with the Deeplinkme server.
    DLMEErrorUnableToCommunicateWithServer,
    /// Nothing to return that matches the request.
    DLMEErrorNotFound,
} DLMEError;

/**
 * A DLResultObject encapsulates DeeplinkSDK link results.
 * @discussion Returned in the completion handler of @p getLinkWithKeywords:completion:
 */
@interface DLResultObject : NSObject

/// A direct link to a page in a Marketplace app.
@property (nonatomic, readonly) NSURL *deeplink;
/// Description text of a page in a Marketplace app.
@property (nonatomic, readonly) NSString *text;
/// url host of a page in a Marketplace app’s website.
@property (nonatomic, readonly) NSString *host;
/// Title of a page in a Marketplace app.
@property (nonatomic, readonly) NSString *title;

@end

typedef void (^CompletionHandlerType)(NSError *error, DLResultObject *result);

/**
 * DeeplinkSDK is the access point to the Deeplink API.
 * @discussion Use @p +sharedInstance to obtain the singleton.
 */
@interface DeeplinkSDK : NSObject

/// @p YES if DeeplinkSDK initialization has completed successfully.
@property (nonatomic, readonly) BOOL isInitialized;

/**
 * Returns the DeeplinkSDK singleton.
 */
+(DeeplinkSDK *)sharedInstance;

/**
 * Initializes the DeeplinkSDK singleton.
 *
 * @param apiKey        The unique developer ID, assigned to you on registering for a Deeplink account.
 * @param appID         The unique app ID, assigned to the app by Deeplink on creation in the portal.
 * @param completion    The block to be called on initialization completion, successful or otherwise.
 * @discussion  Initialization involves scaning your device for installed Marketplace apps.
 *
 * An @p NSError object describes the reason for failure, if any; a @nil error signifies success.
 *
 * @warning Do not call @p getLinkWithKeywords:completion: before initialization is successfully completed.
 */
-(void)initializeWithApiKey:(NSString *)apiKey andAppID:(NSString *)appID completion:(void(^)(NSError *error))completionHandler;
/**
 * Asynchronously fetch a link to an installed Marketplace app.
 *
 * @param keywords          A space-separated list of keywords for filtering the search.
 * @param completionHandler The block to be called on completion, successful or otherwise, of the method.
 * @discussion  If successful, the link information is returned encapsulated in a DLResultObject.
 *
 * Otherwise, an @p NSError object describes the reason for failure.
 */
-(void)getLinkWithKeywords:(NSString *)keywords completion:(void(^)(NSError *error, DLResultObject *result))completionHandler;
/**
 * Handles reporting incoming Marketplace deeplinks to the Deeplink server for tracking purposes.
 *
 *
 * @param url   The URL passed to the @p UIAppDelegate subclass, representing an incoming deeplink.
 * @discussion  When your app is opened through a deeplink, one of @p application:handleOpenURL: or the preferable @p application:openURL:sourceApplication:annotation: is called, passing in the deeplink as a URL.
 *
 * Call this method with this URL to ensure accurate tracking of incoming deeplinks,
 * before handling the deeplink.
 */
-(void)handleOpenURL:(NSURL *)url;

@end