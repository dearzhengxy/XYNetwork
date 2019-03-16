//
//  XYNetMananger.m
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import "XYNetMananger.h"
#import "XYNetLocalCache.h"
#import "AFNetworking.h"


extern NSString *XYConvertMD5FromParameter(NSString *url, NSString* method, NSDictionary* paramDict);

static NSString *XYNetProcessingQueue = @"com.xy.net";


@interface XYNetMananger (){
    dispatch_queue_t _XYNetQueue;
}

@property (nonatomic, strong) XYNetLocalCache *cache;
@property (nonatomic, strong) NSMutableArray *batchGroups;//批处理
@property (nonatomic, strong)dispatch_queue_t XYNetQueue;
@end

@implementation XYNetMananger

- (instancetype)init
{
    self = [super init];
    if (self) {
        _XYNetQueue = dispatch_queue_create([XYNetProcessingQueue UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _cache      = [XYNetLocalCache sharedInstance];
        _batchGroups = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static XYNetMananger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (void)xyGetCacheWithUrl:(NSString*)urlString
               parameters:(NSDictionary * _Nullable)parameters
        completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    [self xyGetWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:NetCacheDuration completionHandler:completionHandler];
}


- (void)xyPostCacheWithUrl:(NSString*)urlString
                parameters:(NSDictionary * _Nullable)parameters
         completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    [self xyPostWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:NetCacheDuration completionHandler:completionHandler];
}


- (void)xyPostNoCacheWithUrl:(NSString*)urlString
                  parameters:(NSDictionary * _Nullable)parameters
           completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    [self xyPostWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];
    
}

- (void)xyGetNoCacheWithUrl:(NSString*)urlString
                 parameters:(NSDictionary * _Nullable)parameters
          completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    [self xyGetWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];
}


- (void)xyPostWithURLString:(NSString *)URLString
                 parameters:(NSDictionary * _Nullable)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_XYNetQueue, ^{
        
        [weakSelf taskWithMethod:@"POST" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
    
}

- (void)xyGetWithURLString:(NSString *)URLString
                parameters:(NSDictionary *)parameters
               ignoreCache:(BOOL)ignoreCache
             cacheDuration:(NSTimeInterval)cacheDuration
         completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_XYNetQueue, ^{
        
        [weakSelf taskWithMethod:@"GET" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
}


- (void)taskWithMethod:(NSString*)method
             urlString:(NSString*)urlStr
            parameters:(NSDictionary *)parameters
           ignoreCache:(BOOL)ignoreCache
         cacheDuration:(NSTimeInterval)cacheDuration
     completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    
    // 1 url+参数 生成唯一码
    NSString *fileKeyFromUrl = XYConvertMD5FromParameter(urlStr, method, parameters);
    __weak typeof(self) weakSelf = self;
    
    // 2 缓存+失效 判断是否有有效缓存
    if (!ignoreCache && [self.cache checkIfShouldUseCacheWithCacheDuration:cacheDuration cacheKey:fileKeyFromUrl]) {
        
        NSMutableDictionary *localCache = [NSMutableDictionary dictionary];
        NSDictionary *cacheDict = [self.cache searchCacheWithUrl:fileKeyFromUrl];
        [localCache setDictionary:cacheDict];
        if (cacheDict) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (weakSelf.exceptionBlock) {
                    weakSelf.exceptionBlock(nil, localCache);
                }
                completionHandler(nil, YES, localCache);
            });
            return;
        }
    }
    
    // 5 处理网络返回来的数据，即缓存处理
    XYRequestCompletionHandler newCompletionBlock = ^( NSError* error,  BOOL isCache, NSDictionary* result){
        
        //5.1处理缓存  ⚠️参数ignoreCache(网络task发起前，是否从本来缓存中获取数据)  cacheDuration(网络task结束后，是否对网络数据缓存)
        result = [NSMutableDictionary dictionaryWithDictionary:result];
        if (cacheDuration > 0) {// 缓存时效(即缓存时间)大于0
            if (result) {
                if (weakSelf.cacheConditionBlock) {
                    if (weakSelf.cacheConditionBlock(result)) {
                        [weakSelf.cache saveCacheData:result forKey:fileKeyFromUrl];
                    }
                }else{
                    [weakSelf.cache saveCacheData:result forKey:fileKeyFromUrl];
                }
            }
        }
        
        //5.2回掉
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.exceptionBlock) {
                weakSelf.exceptionBlock(error, (NSMutableDictionary*)result);
            }
            completionHandler(error, NO, result);
        });
        
    };
    
    //3  发起AF网络任务
    NSURLSessionTask *task = nil;
    if ([method isEqualToString:@"GET"]) {
        
        task = [self.afHttpManager  GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            /*
             4 处理数据 （处理数据的时候，需要处理下载的网络数据是否要缓存）
             这里可以直接使用 completionHandler，如果这样，网络返回的数据没有做缓存处理机制
             */
            newCompletionBlock(nil,NO, responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            newCompletionBlock(error,NO, nil);;
        }];
        
    }else{
        
        task = [self.afHttpManager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            newCompletionBlock(nil,NO, responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            newCompletionBlock(error,NO, nil);
        }];
        
    }
    
    [task resume];
}

- (AFHTTPSessionManager*)afHttpManager{
    
    AFHTTPSessionManager *afManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    return afManager;
}

- (XYNetRequestInfo*)xyNetRequestWithURLStr:(NSString *)URLString
                                     method:(NSString*)method
                                 parameters:(NSDictionary *)parameters
                                ignoreCache:(BOOL)ignoreCache
                              cacheDuration:(NSTimeInterval)cacheDuration
                          completionHandler:(XYRequestCompletionHandler)completionHandler{
    
    XYNetRequestInfo *xyNetRequestInfo = [XYNetRequestInfo new];
    xyNetRequestInfo.urlStr = URLString;
    xyNetRequestInfo.method = method;
    xyNetRequestInfo.parameters = parameters;
    xyNetRequestInfo.ignoreCache = ignoreCache;
    xyNetRequestInfo.cacheDuration = cacheDuration;
    xyNetRequestInfo.completionBlock = completionHandler;
    return xyNetRequestInfo;
}

- (void)xyBatchOfRequestOperations:(NSArray<XYNetRequestInfo *> *)tasks
                     progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
                   completionBlock:(netSuccessbatchBlock)completionBlock{
    
    /*
     使用 dispatch_group_t 技术点
     多少个任务  对group添加多少个 空任务数(dispatch_group_enter)
     任务完成后  对group的任务数-1 操作(dispatch_group_leave);
     当group的任务数为0了，就会执行dispatch_group_notify的block块操作，即所有的网络任务请求完了。
     
     可以看作是一个信号量的处理， 刚开始有3个信号量 sem = 3， 当 sem = 0时 处理
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(_XYNetQueue, ^{
        
        __block dispatch_group_t group = dispatch_group_create();
        [weakSelf.batchGroups addObject:group];
        
        __block NSInteger finishedTasksCount = 0;
        __block NSInteger totalNumberOfTasks = tasks.count;
        
        [tasks enumerateObjectsUsingBlock:^(XYNetRequestInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj) {
                
                // 网络任务启动前dispatch_group_enter
                dispatch_group_enter(group);
                
                XYRequestCompletionHandler newCompletionBlock = ^( NSError* error,  BOOL isCache, NSDictionary* result){
                    
                    progressBlock(finishedTasksCount, totalNumberOfTasks);
                    if (obj.completionBlock) {
                        obj.completionBlock(error, isCache, result);
                    }
                    // 网络任务结束后dispatch_group_enter
                    dispatch_group_leave(group);
                    
                };
                if ([obj.method isEqual:@"POST"]) {
                    
                    [[XYNetMananger sharedInstance] xyPostWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];
                    
                }else{
                    
                    [[XYNetMananger sharedInstance] xyGetWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];
                }
                
            }
            
        }];
        
        //监听
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [weakSelf.batchGroups removeObject:group];
            if (completionBlock) {
                completionBlock(tasks);
            }
        });
    });
}


@end
