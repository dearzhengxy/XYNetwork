//
//  XYNetRequestInfo.h
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^XYRequestCompletionHandler)( NSError* _Nullable error,  BOOL isCache, NSDictionary* _Nullable result);
typedef BOOL (^XYRequestCompletionAddCacheCondition)(NSDictionary *result);

typedef void (^netSuccessbatchBlock)(NSArray *operationAry);


@interface XYNetRequestInfo : NSObject

@property(nonatomic, strong)NSString *urlStr;
@property(nonatomic, strong)NSString *method;
@property(nonatomic, strong)NSDictionary *parameters;
@property(nonatomic, assign)BOOL ignoreCache;
@property(nonatomic, assign)NSTimeInterval cacheDuration;
@property(nonatomic, copy)XYRequestCompletionHandler completionBlock;


typedef void (^XYRequestCompletionAddExcepetionHanle)(NSError* _Nullable errror,  NSMutableDictionary* result);

@end

NS_ASSUME_NONNULL_END
