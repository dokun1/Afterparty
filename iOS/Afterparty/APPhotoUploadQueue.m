//
//  APPhotoUploadQueue.m
//  Afterparty
//
//  Created by David Okun on 6/19/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APPhotoUploadQueue.h"
#import "APConnectionManager.h"
#import "APUtil.h"
#import "APConstants.h"

static NSString *const kCache = @"cachedUploadPhotos";

@interface APPhotoUploadQueue ()

@property dispatch_queue_t photoUploadQueue;
@property BOOL isUploading;
@property (strong, nonatomic) NSTimer *pendingPhotoTimer;

@end

@implementation APPhotoUploadQueue

+ (instancetype)sharedQueue {
  static APPhotoUploadQueue *sharedQueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedQueue = [[self alloc] init];
    sharedQueue.photoUploadQueue = dispatch_queue_create("com.afterparty.uploadQueue", NULL);
  });
  return sharedQueue;
}

- (void)addPhotoToQueue:(UIImage *)image forEventID:(NSString *)eventID {
  NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
  NSDictionary *photoDict = @{@"image" : imageData,
                              @"event" : eventID};

  dispatch_async(self.photoUploadQueue, ^{
    [[APUtil cacheLock] lock]; // when we add or remove photos from the array, we MUST lock the cache so we dont lose anything in space
    NSArray *cacheArray = [APUtil loadArrayForPath:kCache];
    if (!cacheArray) {
      cacheArray = @[];
    }
    NSMutableArray *cacheCopy = [cacheArray mutableCopy];
    [cacheCopy addObject:photoDict];
    [APUtil saveArray:cacheCopy forPath:kCache];
    [[APUtil cacheLock] unlock];
    if (!self.isUploading) {
      [self uploadQueuedPhotos];
    }
  });
}

- (void)uploadQueuedPhotos {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kQueueIsUploading object:nil];
  });
  __weak APPhotoUploadQueue *weakself = self;
  dispatch_async(self.photoUploadQueue, ^{
    self.isUploading = YES;
    [[APUtil cacheLock] lock];
    NSArray *cache = [APUtil loadArrayForPath:kCache];
    NSMutableArray *cacheCopy = [cache mutableCopy];
    [[APUtil cacheLock] unlock];
    [cache enumerateObjectsUsingBlock:^(NSDictionary *photoDict, NSUInteger idx, BOOL *stop) {
      UIImage *image = [UIImage imageWithData:photoDict[@"image"]];
      NSString *eventID = photoDict[@"event"];
      [[APConnectionManager sharedManager] uploadImage:image forEventID:eventID success:^{
        [cacheCopy removeObject:photoDict];
        if (idx == (cache.count - 1)) {
          [[APUtil cacheLock] lock];
          NSMutableArray *latestCache = [[APUtil loadArrayForPath:kCache] mutableCopy];
          [latestCache enumerateObjectsUsingBlock:^(NSDictionary *photoDict, NSUInteger idx, BOOL *stop) {
            if (![cache containsObject:photoDict]) {
              [cacheCopy addObject:photoDict];
            }
          }];
          [APUtil saveArray:cacheCopy forPath:kCache];
          [[APUtil cacheLock] unlock];
          BOOL shouldRetry = (cacheCopy.count > 0) ? YES : NO;
          if (shouldRetry) {
            [weakself uploadQueuedPhotos];
          } else {
            self.isUploading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
              [[NSNotificationCenter defaultCenter] postNotificationName:kQueueIsDoneUploading object:nil];
            });
          }
        }
      } failure:^(NSError *error) {
      }];
    }];
  });
}

@end
