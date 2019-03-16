//
//  AppDelegate+NetCache.m
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import "AppDelegate+NetCache.h"
#import "XYNetMananger.h"

@implementation AppDelegate (NetCache)

// 配置缓存条件
- (void)configNetCacheCondition{
    
    // return YES 缓存， NO不缓存
    [XYNetMananger sharedInstance].cacheConditionBlock = ^BOOL(NSDictionary * _Nonnull result) {
        
        if([result isKindOfClass:[NSDictionary class]]){
            
            if([[result objectForKey:@"success"] intValue] == 0){
                
                return NO;
            }
        }
        
        return YES;
    };
    
}

@end
