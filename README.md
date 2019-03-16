# XYNetwork
基于AFNetworking封装的网络库，提供灵活的缓存功能，多任务处理功能


## Usage

导入XYNetMananger.h文件


    //简单的post带缓存请求

    NSDictionary *infodict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"versions_id", @"1", @"system_type", nil];
    
    [[XYNetMananger sharedInstance] xyPostNoCacheWithUrl:URLPath parameters:infodict completionHandler:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        if (isCache) {
            NSLog(@"isCache");
        }
    }];


    // 多任务处理

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
    


