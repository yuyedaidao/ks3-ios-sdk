//
//  KSYLogClient.m
//  KS3YunSDK
//
//  Created by Blues on 15/7/20.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import "KSYLogClient.h"
#import "KSYReachability.h"
#import "KSYLog.h"
#import "LFCGzipUtillity.h"
#import <CoreData/CoreData.h>

#define kTableName @"KSYLog"
#define kDataRow 120

@interface KSYLogClient ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation KSYLogClient

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[[NSBundle bundleForClass:[self class]] bundleURL] URLByAppendingPathComponent:@"KSYLogModel.momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSLog(@"_managedObjectModel is %@",_managedObjectModel);
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"KSYLogModel.sqlite"];
    NSLog(@"StoreURL: %@", storeURL);
    
    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.获取Documents路径
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - CRUD

- (void)insertLog:(KS3LogModel *)logInfo {
    NSManagedObjectContext *context = [self managedObjectContext];
    KSYLog *log = [NSEntityDescription insertNewObjectForEntityForName:kTableName inManagedObjectContext:context];
    log.source_ip = logInfo.Log_source_ip;
    log.target_ip = logInfo.Log_target_ip;
    log.model = logInfo.Log_model;
    log.manufacturer = logInfo.Log_manufacturer;
    log.build_version = logInfo.Log_build_version;
    
    log.device_id = logInfo.Log_device_id;
    log.network_type = logInfo.Log_network_type;
    log.first_data_time = logInfo.Log_first_data_time;
    log.response_time = logInfo.Log_response_time;
    log.response_size = [NSNumber numberWithDouble:logInfo.Log_response_size];
    
    log.client_state = [NSNumber numberWithInteger:logInfo.Log_client_state];
    log.mobile_network_type = logInfo.Log_mobile_network_type;
    log.ksy_error_code = [NSNumber numberWithInteger:logInfo.ksyErrorcode];
    log.send_before_time = logInfo.send_before_time;
    log.request_id = logInfo.log_RequestId;
    
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"KS3 SDK 日志记录失败：%@",[error localizedDescription]);
    }
    
    // **** 超过1200条后，从最前面第一条开始往后开始删除以前的数据
    NSInteger count = [self dataCount];
    if (count > 1200) {
        [self deleteFirstRecord];
    }
}

- (void)deleteLog:(NSArray *)arrData {
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *obj in arrData) {
        [context deleteObject:obj];
    }
    NSError *error = nil;
    if ([context save:&error] == NO) {
        NSLog(@"KS3 SDK 删除日志失败: %@", error);
    }
//    NSEntityDescription *entity = [NSEntityDescription entityForName:kTableName inManagedObjectContext:context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setIncludesPropertyValues:NO];
//    [request setEntity:entity];
//    NSError *error = nil;
//    NSArray *logs = [context executeFetchRequest:request error:&error];
//    if (!error && logs && [logs count])
//    {
//        for (NSManagedObject *obj in logs)
//        {
//            [context deleteObject:obj];
//        }
//        if (![context save:&error])
//        {
//            NSLog(@"error:%@",error);
//        }
//    }
}

- (void)updateData:(NSString*)request_id  withIsLook:(NSString*)islook {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"request_id like[cd] %@", request_id];
    
    //首先你需要建立一个request
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kTableName inManagedObjectContext:context]];
    [request setPredicate:predicate];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    NSError *error = nil;
//    NSArray *result = [context executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
//    for (KSYLog *log in result) {
//        // **** TODO: 更新需要的属性
//        log.request_id = @"request_id";
//    }
    
    //保存
    if ([context save:&error]) {
        //更新成功
        NSLog(@"KS3 SDK 日志记录更新：成功！");
    }
}

- (NSMutableArray*)selectData:(int)pageSize andOffset:(NSInteger)currentPage
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"rowid" ascending:YES];
    
    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setFetchLimit:pageSize];
    [fetchRequest setFetchOffset:currentPage];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (KSYLog *log in fetchedObjects) {
//        NSLog(@"request_id:%@", log.request_id);
//        NSLog(@"ksy_error_code:%@", log.ksy_error_code);
        [resultArray addObject:log];
    }
    return resultArray;
}

- (NSInteger)dataCount {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    for (NSInteger i = 0; i < fetchedObjects.count; i ++) {
//        KSYLog *log = fetchedObjects[i];
//        NSLog(@"index: %ld", (long)i + 1);
//        NSLog(@"request_id:%@", log.request_id);
//        NSLog(@"ksy_error_code:%@", log.ksy_error_code);
//    }
    return fetchedObjects.count;
}

- (void)deleteFirstRecord {
    NSArray *arrData = [self selectData:1 andOffset:0];
    [self deleteLog:arrData];
}

#pragma mark - Send data

- (void)sendData {
    NSInteger count = [self dataCount] / kDataRow + 1;
    if ([self dataCount] == 0) {
        count = 0;
    }
    for (NSInteger i = 0; i < count; i ++) {
        NSArray *arrData = [self selectData:kDataRow andOffset:i * kDataRow];
        if ([self isWifi] == YES) {
            [self sendOnce:arrData];
        }
        else {
            break;
        }
    }
}

- (NSData *)generateStrLogWithDataCollection:(NSArray *)arrData {
    NSMutableArray *arrSpecial = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < arrData.count; i ++) {
        KSYLog *log = arrData[i];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             log.source_ip,             @"SI",
                             log.target_ip,             @"TI",
                             log.device_id,             @"ID",
                             log.network_type,          @"NT",
                             log.mobile_network_type,   @"CT",
                             log.send_before_time,      @"ST",
                             log.first_data_time,       @"FT",
                             log.response_time,         @"RT",
                             log.response_size,         @"RS",
                             log.client_state,          @"CS",
                             log.ksy_error_code,        @"ER",
                             log.request_id,            @"RI", nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [arrSpecial addObject:str];
    }
    NSLog(@"===== send %ld records =====", (long)arrData.count);
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrSpecial options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"  " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    str = [str stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
//    NSLog(@"===== str: %@ =====", str);
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzipData = [LFCGzipUtillity gzipData:data];
    return gzipData;
}

- (void)sendOnce:(NSArray *)arrData {
    NSData *dataLog = [self generateStrLogWithDataCollection:arrData];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://mlog.ksyun.com"]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"]; // **** for gzip
    [urlRequest setHTTPBody:dataLog];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"Log send request code: ----- %ld",(long)responseCode);
        if (responseCode == 200) {
            NSLog(@"success 111");
            [self deleteLog:arrData]; // **** 发送成功就删除
        }
    }];
}

- (BOOL)isWifi {
    KS3Reachability *r = [KS3Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus status = r.currentReachabilityStatus;
    if (status == ReachableViaWiFi) {
        return YES;
    }
    return NO;
}

@end
