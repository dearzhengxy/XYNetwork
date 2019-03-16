//
//  XYNetMananger.h
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYNetRequestInfo.h"

NS_ASSUME_NONNULL_BEGIN

#define NetCacheDuration 60*5

@interface XYNetMananger : NSObject

@property (nonatomic, copy) NSString *netState;

+ (nonnull instancetype)sharedInstance;


/**
 外部添加异常处理 （根据服务器返回的数据，统一处理，如处理登录实效），默认不做处理
 */
@property (nonatomic, copy)XYRequestCompletionAddExcepetionHanle exceptionBlock;
// 返回NO， cache不保存
@property (nonatomic, copy)XYRequestCompletionAddCacheCondition cacheConditionBlock;


// 使用默认配置的缓存策略
- (void)xyGetCacheWithUrl:(NSString*)urlString
               parameters:(NSDictionary * _Nullable)parameters
        completionHandler:(XYRequestCompletionHandler)completionHandler;

- (void)xyPostCacheWithUrl:(NSString*)urlString
                parameters:(NSDictionary * _Nullable)parameters
         completionHandler:(XYRequestCompletionHandler)completionHandler;

// 不使用缓存
- (void)xyPostNoCacheWithUrl:(NSString*)urlString
                  parameters:(NSDictionary * _Nullable)parameters
           completionHandler:(XYRequestCompletionHandler)completionHandler;

- (void)xyGetNoCacheWithUrl:(NSString*)urlString
                 parameters:(NSDictionary * _Nullable)parameters
          completionHandler:(XYRequestCompletionHandler)completionHandler;
/**
 POST请求
 @param URLString url地址
 @param parameters 请求参数
 @param ignoreCache 是否忽略缓存，YES 忽略，NO 不忽略
 @param cacheDuration 缓存实效
 @param completionHandler 请求结果处理
 */
- (void)xyPostWithURLString:(NSString *)URLString
                 parameters:(NSDictionary * _Nullable)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(XYRequestCompletionHandler)completionHandler;


/**
 GET请求
 
 @param URLString url地址
 @param parameters 请求参数
 @param ignoreCache 是否忽略缓存，YES 忽略，NO 不忽略
 @param cacheDuration 缓存实效
 @param completionHandler 请求结果处理
 */
- (void)xyGetWithURLString:(NSString *)URLString
                parameters:(NSDictionary *)parameters
               ignoreCache:(BOOL)ignoreCache
             cacheDuration:(NSTimeInterval)cacheDuration
         completionHandler:(XYRequestCompletionHandler)completionHandler;




/**
 保存网络请求信息 和 batchOfRequestOperations方法一起用
 */
- (XYNetRequestInfo*)xyNetRequestWithURLStr:(NSString *)URLString
                                     method:(NSString*)method
                                 parameters:(NSDictionary *)parameters
                                ignoreCache:(BOOL)ignoreCache
                              cacheDuration:(NSTimeInterval)cacheDuration
                          completionHandler:(XYRequestCompletionHandler)completionHandler;



/**
 执行多个网络请求
 
 @param tasks 请求信息
 @param progressBlock 网络任务完成的进度
 @param completionBlock tasks中所有网络任务结束
 */
- (void)xyBatchOfRequestOperations:(NSArray<XYNetRequestInfo *> *)tasks
                     progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
                   completionBlock:(netSuccessbatchBlock)completionBlock;


NS_ASSUME_NONNULL_END
@end
