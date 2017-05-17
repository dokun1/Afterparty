//
//  APUser.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APUser : NSObject

// when we finally move to a RESTful web service without parse, this object will become necessary

@property (strong, nonatomic) NSString *sessionToken;
@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *installedVersion;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *twitterID;
@property (strong, nonatomic) NSString *profilePhotoURL;

@end
