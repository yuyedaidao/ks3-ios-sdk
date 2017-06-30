//
//  PerfViewController.m
//  KS3SDKDemo
//
//  Created by Sun Peng on 2017/6/29.
//  Copyright © 2017年 Kingsoft. All rights reserved.
//

#import "PerfViewController.h"
#import <KS3YunSDK.h>
#import "KS3Util.h"
#import "AppDelegate.h"

#define kUploadBucketName @"test-voidmain-hz-2"   //上传所用的bucketName

@interface PerfViewController ()

@property (assign) NSInteger nextCount;
@property (assign) NSInteger successCount;
@property (assign) NSInteger totalCount;
@property (assign) NSInteger totalSize;
@property (assign) double totalTime;

@property (nonatomic, strong) NSDate* lastStartDate;

@property (nonatomic, strong) KS3UploadManager *uploadManager;

@property (assign) UIBackgroundTaskIdentifier taskId;

@end

@implementation PerfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetViews];

    [[KS3Client initialize] setCredentials:[[KS3Credentials alloc] initWithAccessKey:strAccessKey withSecretKey:strSecretKey]];
    
    self.uploadManager = [KS3UploadManager sharedInstanceWithClient:[KS3Client initialize] authHandler:nil];
}

- (void)resetViews {
    self.uploadTimes.text = @"1000";

    [self resetProgressAndResult];
}

- (void)resetProgressAndResult {
    self.totalProgress.progress = 0;
    self.currentProgress.progress = 0;
    self.result.text = @"";
}

- (void)resetCount {
    _nextCount = 0;
    _totalCount = [self.uploadTimes.text integerValue];
    _successCount = 0;
    _totalSize = 0;
    _totalTime = 0;
}

- (IBAction)startUpload:(id)sender {
    _taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];

    [self resetProgressAndResult];

    [self resetCount];
    [self uploadWithUploadManager];
    [self.startUploadButton setEnabled:NO];
}

- (NSInteger) sizeAtIndex:(NSInteger)index {
    NSInteger remainder = index % 10;
    if (remainder < 7) {
        return 200 * 1024;
    } else if (remainder < 9) {
        return 5 * 1024 * 1024;
    } else {
        return 12 * 1024 * 1024;
    }
}

- (void)uploadWithUploadManager {
    _nextCount ++;
    if (_nextCount > _totalCount) {
        [self.startUploadButton setEnabled:YES];

        self.result.text = [NSString stringWithFormat:@"文件总大小：%ld B\n上传成功率：%.2lf\n上传总耗时：%.2lf秒", _totalSize, (_successCount * 1.0 / _totalCount), _totalTime];

        [[UIApplication sharedApplication] endBackgroundTask:_taskId];
        // end
        return;
    }

    NSData *data = [KS3Util dataWithSize:[self sizeAtIndex:_nextCount]];
    _totalSize += data.length;

    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:KingSoftYun_Permission_Public_Read];

    _lastStartDate = [NSDate date];

    KS3UploadRequest *uploadRequest = [[KS3UploadRequest alloc] initWithKey:[NSString stringWithFormat:@"perf-test-%ld", _nextCount] inBucket:kUploadBucketName acl:acl grantAcl:nil];
    [uploadRequest setCompleteRequest];
    [uploadRequest setStrKS3Token:[KS3Util getAuthorization:uploadRequest]];

    [self.uploadManager putData:data
                        request:uploadRequest
                      blockSize:1 * kMB
                       progress:^(NSString *key, double percent) {
                           NSLog(@"objectKey: %@, progress %lf", key, percent);
                           self.currentProgress.progress = percent;
                       } cancelSignal:^BOOL(NSString *key) {
                           return false; // 修改这里进行取消
                       } complete:^(KS3Upload *upload, KS3Response *response) {
                           _successCount ++;
                           self.totalProgress.progress = (_nextCount * 1.0 / _totalCount);

                           double deltaTime = [[NSDate date] timeIntervalSinceDate:_lastStartDate];
                           _totalTime += deltaTime;

                           [self uploadWithUploadManager];
                       } error:^(KS3Upload *upload, NSError *error) {
                           NSLog(@"uploadId: %@, error: %@", upload.uploadId, error);

                           [self uploadWithUploadManager];
                       }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.uploadTimes endEditing:YES];
}

@end
