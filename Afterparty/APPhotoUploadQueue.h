//
//  APPhotoUploadQueue.h
//  Afterparty
//
//  Created by David Okun on 6/19/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPhotoUploadQueue : NSObject

+ (instancetype)sharedQueue;

- (void)addPhotoToQueue:(UIImage*)image withThumbnail:(UIImage*)thumbnail forEventID:(NSString*)eventID;

@end
