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

- (void)addPhotoToQueue:(UIImage *)image withThumbnail:(UIImage *)thumbnail forEventID:(NSString *)eventID {
  NSDictionary *photoDict = @{@"image" : image,
                              @"thumb" : thumbnail,
                              @"event" : eventID};
  dispatch_async(self.photoUploadQueue, ^{
    [[self cacheLock] lock]; // when we add or remove photos from the array, we MUST lock the cache so we dont lose anything in space
    NSArray *cacheArray = [APUtil loadArrayForPath:kCache];
    if (!cacheArray) {
      cacheArray = @[];
    }
    NSMutableArray *cacheCopy = [cacheArray mutableCopy];
    [cacheCopy addObject:photoDict];
    [APUtil saveArray:cacheCopy forPath:kCache];
    [[self cacheLock] unlock];
    [self uploadQueuedPhotos];
  });
}

- (void)uploadQueuedPhotos {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUploading object:nil];
  });
  dispatch_async(self.photoUploadQueue, ^{
    self.isUploading = YES;
    [[self cacheLock] lock];
    NSArray *cache = [APUtil loadArrayForPath:kCache];
    NSMutableArray *cacheCopy = [cache mutableCopy];
    [[self cacheLock] unlock];
    [cache enumerateObjectsUsingBlock:^(NSDictionary *photoDict, NSUInteger idx, BOOL *stop) {
        UIImage *image = photoDict[@"image"];
        UIImage *thumb = photoDict[@"thumb"];
        NSString *eventID = photoDict[@"event"];
        [[APConnectionManager sharedManager] uploadImage:image withThumbnail:thumb forEventID:eventID success:^(BOOL succeeded) {
          [cacheCopy removeObject:photoDict];
        } failure:^(NSError *error) {
          NSLog(@"error uploading photo for eventID: %@", eventID);
        } progress:nil];
    }];
    BOOL shouldRetry = (cacheCopy.count > 0) ? YES : NO;
    [[self cacheLock] lock];
    NSMutableArray *latestCache = [[APUtil loadArrayForPath:kCache] mutableCopy];
    [cacheCopy enumerateObjectsUsingBlock:^(NSDictionary *photoDict, NSUInteger idx, BOOL *stop) {
      [latestCache addObject:photoDict];
    }];
    [APUtil saveArray:cache forPath:kCache];
    [[self cacheLock] unlock];
    if (shouldRetry) {
      [self uploadQueuedPhotos];
    }else {
      self.isUploading = NO;
      dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDoneUploading object:nil];
      });
    }
  });
}

- (NSLock*) cacheLock {
  static NSLock *lock;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    lock = [[NSLock alloc] init];
  });
  return lock;
}

@end
