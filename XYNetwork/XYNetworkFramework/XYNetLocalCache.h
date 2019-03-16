//
//  XYNetLocalCache.h
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYNetLocalCache : NSObject

+ (nonnull instancetype)sharedInstance;

@property (assign, nonatomic) NSInteger maxCacheDeadline;
@property (assign, nonatomic) NSUInteger maxCacheSize;

-(BOOL)checkIfShouldUseCacheWithCacheDuration:(NSTimeInterval)cacheDuration cacheKey:(NSString*)urlkey;

-(void)addProtectCacheKey:(NSString*)key;

- (id)searchCacheWithUrl:(NSString *)urlkey;
- (void)saveCacheData:(id<NSCopying>)data forKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
