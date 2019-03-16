//
//  ViewController.m
//  XYNetwork
//
//  Created by MAC005 on 2019/3/16.
//  Copyright © 2019年 MAC005. All rights reserved.
//

#import "ViewController.h"
#import "XYNetMananger.h"

#define URLPath @"http://svr.tuliu.com/center/front/app/util/updateVersions"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSDictionary *infodict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    
    
    //post请求
    [[XYNetMananger sharedInstance] xyPostNoCacheWithUrl:URLPath parameters:infodict completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        if (isCache) {
            NSLog(@"isCache");
        }
    }];
    
    
    
}

// 多任务处理
- (void)multiNetTask{
    NSDictionary *infodictOne = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    XYNetRequestInfo *infoNetOne = [[XYNetMananger sharedInstance] xyNetRequestWithURLStr:URLPath method:@"POST" parameters:infodictOne ignoreCache:NO cacheDuration:2 completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        
        if (isCache) {
            NSLog(@"isCache");
        }
        
    }];
    
    NSDictionary *infodictTwo = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    XYNetRequestInfo *infoNetTwo = [[XYNetMananger sharedInstance] xyNetRequestWithURLStr:URLPath method:@"POST" parameters:infodictTwo ignoreCache:NO cacheDuration:2 completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        
        if (isCache) {
            NSLog(@"isCache");
        }
        
    }];
    
    
    NSArray *taskAry = [NSArray arrayWithObjects:infoNetOne, infoNetTwo, nil];
    [[XYNetMananger sharedInstance] xyBatchOfRequestOperations:taskAry progressBlock:^(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks) {
        
    } completionBlock:^(NSArray * _Nonnull operationAry) {
        
    }];
    
    
}


@end
