//
//  KingSoftS3Client.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Client.h"
#import "KS3Credentials.h"
#import "KS3AuthUtils.h"
#import "KS3SDKUtil.h"
#import "KS3ListBucketsResult.h"
#import "KS3CreateBucketResponse.h"
#import "KS3CreateBucketRequest.h"
#import "KS3DeleteBucketResponse.h"
#import "KS3DeleteBucketRequest.h"
#import "KS3GetACLRequest.h"
#import "KS3GetACLResponse.h"
#import "KS3SetACLRequest.h"
#import "KS3AccessControlList.h"
#import "KS3ListObjectsRequest.h"
#import "KS3ListObjectsResponse.h"
#import "KS3GetBucketLoggingResponse.h"
#import "KS3GetBucketLoggingRequest.h"
#import "KS3ListObjectsResult.h"
#import "KS3SetBucketLoggingResponse.h"
#import "KS3SetBucketLoggingRequest.h"
#import "KS3GetObjectResponse.h"
#import "KS3GetObjectRequest.h"
#import "KS3DeleteObjectResponse.h"
#import "KS3DeleteObjectRequest.h"
#import "KS3HeadObjectResponse.h"
#import "KS3HeadObjectRequest.h"
#import "KS3PutObjectResponse.h"
#import "KS3PutObjectRequest.h"
#import "KS3GetObjectACLResponse.h"
#import "KS3GetObjectACLRequest.h"
#import "KS3SetObjectACLResponse.h"
#import "KS3SetObjectACLRequest.h"
#import "KS3UploadPartResponse.h"
#import "KS3UploadPartRequest.h"
#import "KS3InitiateMultipartUploadRequest.h"
#import "KS3InitiateMultipartUploadResponse.h"
#import "KS3ListPartsResponse.h"
#import "KS3ListPartsRequest.h"
#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3CompleteMultipartUploadResponse.h"
#import "KS3DownLoad.h"
#import "KS3AbortMultipartUploadResponse.h"
#import "KS3AbortMultipartUploadRequest.h"
#import "KS3HeadBucketResponse.h"
#import "KS3HeadBucketRequest.h"
#import "KS3SetGrantACLResponse.h"
#import "KS3SetGrantACLRequest.h"
#import "KS3DeleteBucketResponse.h"
#import "KS3SetACLResponse.h"
#import "KS3ListBucketsResponse.h"
#import "KS3ListBucketsRequest.h"
#import "KS3SetObjectGrantACLRequest.h"
#import "KS3SetObjectGrantACLResponse.h"
#import "KS3ErrorHandler.h"
#import "KS3ClientException.h"
#import "KS3PutObjectCopyResponse.h"
#import "KS3PutObjectCopyRequest.h"
#import "KS3LogModel.h"
#import "KSYHardwareInfo.h"
#import "KSYLogManager.h"
#import "KSYLogClient.h"

static NSString     * const KingSoftYun_Host_Name      = @"http://kss.ksyun.com";
static NSTimeInterval const KingSoftYun_RequestTimeout = 60;

static NSString     * const KingSoftYun_Host_GETIp1      = @"http://120.131.2.241";
static NSString     * const KingSoftYun_Host_GETIp2      = @"http://123.59.35.94";

@interface KS3Client () <NSURLConnectionDataDelegate>{
    BOOL getIPSuccess;
}

@property (strong, nonatomic) KS3Credentials *credentials;
@property (strong, nonatomic) KSS3GetTokenSuccessBlock tokenBlock;
@property (assign, nonatomic) BOOL isSend;
@property (strong, nonatomic) NSTimer *sendTimer;


@end

@implementation KS3Client
- (instancetype)init
{
    if (self == [super init]) {
        _recordRate = 1;
        _isSend = YES;
        _sendTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(sendLog) userInfo:nil repeats:YES]; // **** 应该是 1小时 ＝ 3600秒 发一次
        [_sendTimer setFireDate:[NSDate distantPast]]; // **** 立即执行
    }
    return self;
}

+ (KS3Client *)initialize
{
    static KS3Client *shareObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[self alloc] init];
//        [self getKS3IPList:KingSoftYun_Host_GETIp1];
        
    });
    return shareObj;
}

#pragma mark - DataBase

- (void)sendLog {
    KSYLogClient *logClient = [[KSYLogClient alloc] init];
    [logClient sendData];
}

#pragma mark - Init credentials
- (void)connectWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey
{
    if (_credentials == nil) {
        _credentials = [[KS3Credentials alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
    }
}

#pragma mark - Buckets
- (NSArray *)listBuckets:(KS3ListBucketsRequest *)listBucketsRequest
{
    KS3ListBucketsResponse *listResponse = (KS3ListBucketsResponse *)[self invoke:listBucketsRequest];
    if (listResponse.error == nil) {
        if (![listResponse respondsToSelector:@selector(listBucketsResult)]) {
            return nil;
        }
        if (listResponse.listBucketsResult != nil && listResponse.listBucketsResult.buckets != nil) {
            return [NSArray arrayWithArray:listResponse.listBucketsResult.buckets];
        }
    }
    return nil;
}

- (KS3CreateBucketResponse *)createBucket:(KS3CreateBucketRequest *)createBucketRequest
{
    return (KS3CreateBucketResponse *)[self invoke:createBucketRequest];
}

- (KS3DeleteBucketResponse *)deleteBucket:(KS3DeleteBucketRequest *)deleteBucketRequest
{
    return (KS3DeleteBucketResponse *)[self invoke:deleteBucketRequest];
}

- (KS3HeadBucketResponse *)headBucket:(KS3HeadBucketRequest *)headBucketRequest;
{
    return (KS3HeadBucketResponse *)[self invoke:headBucketRequest];
}

- (KS3GetACLResponse *)getBucketACL:(KS3GetACLRequest *)getACLRequest
{
    return (KS3GetACLResponse *)[self invoke:getACLRequest];
}

- (KS3SetACLResponse *)setBucketACL:(KS3SetACLRequest *)bucketACLRequest
{
    return (KS3SetACLResponse *)[self invoke:bucketACLRequest];
}

- (KS3GetBucketLoggingResponse *)getBucketLogging:(KS3GetBucketLoggingRequest *)getBucketLoggingRequest
{
    return (KS3GetBucketLoggingResponse *)[self invoke:getBucketLoggingRequest];
}

- (KS3SetBucketLoggingResponse *)setBucketLogging:(KS3SetBucketLoggingRequest *)setBucketTaggingRequest{
    return (KS3SetBucketLoggingResponse *)[self invoke:setBucketTaggingRequest];
}

#pragma mark - Objects

- (KS3ListObjectsResponse *)listObjects:(KS3ListObjectsRequest *)listObjectsRequest
{
    return (KS3ListObjectsResponse *)[self invoke:listObjectsRequest];
}

- (KS3GetObjectResponse *)getObject:(KS3GetObjectRequest *)getObjectRequest
{
    return (KS3GetObjectResponse *)[self invoke:getObjectRequest];
}

- (KS3DeleteObjectResponse *)deleteObject:(KS3DeleteObjectRequest *)deleteObjectRequest
{
    return (KS3DeleteObjectResponse *)[self invoke:deleteObjectRequest];
}

- (KS3HeadObjectResponse *)headObject:(KS3HeadObjectRequest *)headObjectRequest
{
    return (KS3HeadObjectResponse *)[self invoke:headObjectRequest];
}

- (KS3PutObjectResponse *)putObject:(KS3PutObjectRequest *)putObjectRequest
{
    return (KS3PutObjectResponse *)[self invoke:putObjectRequest];
}

- (KS3PutObjectCopyResponse *)putObjectCopy:(KS3PutObjectCopyRequest *)putObjectCopyRequest
{
    return (KS3PutObjectCopyResponse *)[self invoke:putObjectCopyRequest];
}

- (KS3GetObjectACLResponse *)getObjectACL:(KS3GetObjectACLRequest *)getObjectACLRequest
{
    return (KS3GetObjectACLResponse *)[self invoke:getObjectACLRequest];
}

- (KS3SetObjectACLResponse *)setObjectACL:(KS3SetObjectACLRequest *)setObjectACLRequest
{
    return (KS3SetObjectACLResponse *)[self invoke:setObjectACLRequest];
}

- (KS3SetObjectGrantACLResponse *)setObjectGrantACL:(KS3SetObjectGrantACLRequest *)setObjectGrantACLRequest
{
    return (KS3SetObjectGrantACLResponse *)[self invoke:setObjectGrantACLRequest];
}

- (KS3SetGrantACLResponse *)setGrantACL:(KS3SetGrantACLRequest *)setGrantACLRequest
{
    return (KS3SetGrantACLResponse *)[self invoke:setGrantACLRequest];
}

#pragma mark - MultipartUpload

- (KS3MultipartUpload *)initiateMultipartUploadWithRequest:(KS3InitiateMultipartUploadRequest *)request
{
    KS3InitiateMultipartUploadResponse *response = (KS3InitiateMultipartUploadResponse *)[self invoke:request];
    return response.multipartUpload;
}

- (KS3UploadPartResponse *)uploadPart:(KS3UploadPartRequest *)uploadPartRequest
{
    return (KS3UploadPartResponse *)[self invoke:uploadPartRequest];
}

- (KS3ListPartsResponse *)listParts:(KS3ListPartsRequest *)listPartsRequest
{
    return (KS3ListPartsResponse *)[self invoke:listPartsRequest];
}

- (KS3CompleteMultipartUploadResponse *)completeMultipartUpload:(KS3CompleteMultipartUploadRequest *)completeMultipartUploadRequest
{
    return (KS3CompleteMultipartUploadResponse *)[self invoke:completeMultipartUploadRequest];
}

- (KS3AbortMultipartUploadResponse *)abortMultipartUpload:(KS3AbortMultipartUploadRequest *)abortMultipartRequest
{
    return (KS3AbortMultipartUploadResponse *)[self invoke:abortMultipartRequest];
}

+ (id)constructResponseFromRequest:(KS3Request *)request
{
    NSString *requestClassName  = NSStringFromClass([request class]);
    NSString *responseClassName = [[requestClassName substringToIndex:[requestClassName length] - 7] stringByAppendingFormat:@"Response"];
    id response = [[NSClassFromString(responseClassName) alloc] init];
    if (nil == response) {
        response = [[KS3Response alloc] init];
    }
    return response;
}

- (NSMutableURLRequest *)signKSS3Request:(KS3Request *)request
{
    request.credentials = _credentials;
    KS3URLRequest *urlRequest= [request configureURLRequest];
    return urlRequest;
}

- (NSTimeInterval)getRequestTimeOut:(KS3Request *)request
{
    NSTimeInterval ksyRequestTimeOut = request.timeoutInterval;
    if (ksyRequestTimeOut == 0 || ksyRequestTimeOut < 0) {
        ksyRequestTimeOut = KingSoftYun_RequestTimeout;
        
    }
    return ksyRequestTimeOut;
}

- (void)getKSSIPList:(NSString *)host
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *requestIP1 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/kssiplist",host]]];
        requestIP1.timeoutInterval = 10;
        [NSURLConnection sendAsynchronousRequest:requestIP1 queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                if ([host isEqualToString:KingSoftYun_Host_GETIp1]) {
                    [self getKSSIPList:KingSoftYun_Host_GETIp2];
                }
            }else{
                NSError *error = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (!error) {
                    getIPSuccess = YES;
                    _ksyIps = [jsonDict[@"ct"] componentsSeparatedByString:@","];
                }
            }
            if ([host isEqualToString:KingSoftYun_Host_GETIp2]) {
                getIPSuccess = YES;
            }
        }];
        

    });
}

- (void)syncKS3IPList:(NSString *)host timeoutInterval:(NSTimeInterval)timeoutInterval completionHander:(void (^) (NSArray *ipsArray))completionHander faildHander:(void (^)(NSError *error,NSString *host))faildHander {
    NSArray *ks3IPSArray= [NSMutableArray array];
    NSMutableURLRequest *requestIP1 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/kssiplist",host]]];
    requestIP1.timeoutInterval = timeoutInterval;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestIP1 returningResponse:nil error:&error];
    if (data) {
        NSError *dataError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&dataError];
        if (!dataError) {
            ks3IPSArray = [jsonDict[@"ct"] componentsSeparatedByString:@","];
            completionHander(ks3IPSArray);
        }else {
            faildHander(dataError,host);
        }
    }else {
        faildHander(error,host);
    }
}

- (void)syncGetIPList:(NSTimeInterval)timeoutInterval completionHandler:(void (^) (BOOL success,NSArray *ipsArray,NSError *error))hander {
    [self syncKS3IPList:KingSoftYun_Host_GETIp1 timeoutInterval:timeoutInterval completionHander:^(NSArray *ipsArray) {
        hander(YES,ipsArray,nil);
    } faildHander:^(NSError *error,NSString *host) {
        if ([host isEqualToString:KingSoftYun_Host_GETIp1]) {
            [self syncKS3IPList:KingSoftYun_Host_GETIp2 timeoutInterval:timeoutInterval completionHander:^(NSArray *ipsArray) {
                hander(YES,ipsArray,nil);
            } faildHander:^(NSError *error, NSString *host) {
                hander(NO,nil,error);
            }];
        }else {
            hander(NO,nil,error);
        }
    }];
}

- (KS3Response *)invoke:(KS3Request *)request
{
    {
        if (!_ksyIps.count) {
            [self getKSSIPList:KingSoftYun_Host_GETIp1];
            while (!getIPSuccess) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
    }
    NSString *message = nil;
    if ((_credentials.accessKey == nil || _credentials.secretKey == nil) && _credentials != nil) {
        NSLog(@"######### 使用本地AK/SK签名, 请正确配置本地AK/SK #############");
        message = @"请正确配置本地AK/SK";
    }
    
    if (message) {
        KS3Response *response = [KS3Response new];
        response.error = [KS3ErrorHandler errorFromExceptionWithThrowsExceptionOption:[KS3ClientException exceptionWithMessage:message]];
        return response;
    }
    
    if (nil == request) {
        KS3Response *response = [KS3Response new];
        response.error = [KS3ErrorHandler errorFromExceptionWithThrowsExceptionOption:[KS3ClientException exceptionWithMessage:@"Request cannot be nil."]];
        return response;
    }
    
    KS3ClientException *clientException = [request validate];
    if (clientException != nil) {
        KS3Response *response = [KS3Response new];
        response.error = [KS3ErrorHandler errorFromExceptionWithThrowsExceptionOption:((NSException *)clientException)];
        return response;
    }
    
    KS3Response *response = [self startURLRequest:request token:request.strKS3Token];
    NSLog(@"%@",[response.error description]);
    if ([request delegate] == nil) {
        if ([KS3SDKUtil isDNSParseFaild:response]) {
            if (!request.reTry) {
                request.reTry = YES;
                [request vHostToVPath:request.host withBucketName:request.bucket];
                return [self startURLRequest:request token:request.strKS3Token];
            }
        }
    }
    
    return response;
}

- (KS3Response *)startURLRequest:(KS3Request *)request token:(NSString *)strToken {
    
    NSMutableURLRequest *urlRequest = [self signKSS3Request:request];
    [urlRequest setTimeoutInterval:[self getRequestTimeOut:request]];
    
    if (strToken != nil) {
        [urlRequest setValue:strToken forHTTPHeaderField:@"Authorization"];
    }
    
    KS3Response *response = [KS3Client constructResponseFromRequest:request];
    [response setRequest:request];
    [KSYLogManager setLocalLogInfo:request];
    request.logModel.send_before_time = [KSYHardwareInfo getCurrentTime];
    if ([request delegate] != nil) {
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                         delegate:response
                                                                 startImmediately:NO];
        request.urlConnection = urlConnection;
        
        [NSTimer scheduledTimerWithTimeInterval:[self getRequestTimeOut:request]
                                         target:response
                                       selector:@selector(timeout)
                                       userInfo:nil
                                        repeats:NO];
        [urlConnection start];
        return nil;
    }
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                     delegate:response
                                                             startImmediately:NO];
    [urlConnection  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:KSYS3DefaultRunLoopMode];
    request.urlConnection = urlConnection;
    [urlConnection start];
    
    NSTimer *timeoutTimer = [NSTimer timerWithTimeInterval:[self getRequestTimeOut:request]
                                                    target:response
                                                  selector:@selector(timeout)
                                                  userInfo:nil
                                                   repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timeoutTimer forMode:KSYS3DefaultRunLoopMode];
    while (!response.isFinishedLoading) {
        [[NSRunLoop currentRunLoop] runMode:KSYS3DefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return response;
}


#pragma mark - Download

- (KS3DownLoad *)downloadObjectWithBucketName:(NSString *)bucketName
                                          key:(NSString *)key
                           downloadBeginBlock:(KSS3DownloadBeginBlock)downloadBeginBlock
                      downloadFileCompleteion:(kSS3DownloadFileCompleteionBlock)downloadFileCompleteion
                  downloadProgressChangeBlock:(KSS3DownloadProgressChangeBlock)downloadProgressChangeBlock
                                  failedBlock:(KSS3DownloadFailedBlock)failedBlock
{
    if (!bucketName || !key) {
        NSLog(@"bucket 或 key 不能为空");
        return nil;
    }
    
    if ((_credentials.accessKey == nil || _credentials.secretKey == nil) && _credentials != nil) {
        NSLog(@"######### 使用本地AK/SK签名, 请正确配置本地AK/SK #############");
        return nil;
    }
    NSLog(@"====== downloadObjectWithBucketName ======");
    NSString *strHost = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@", bucketName, key];
    KS3DownLoad *downLoad = [[KS3DownLoad alloc] initWithUrl:strHost credentials:_credentials :bucketName :key];
    downLoad.downloadBeginBlock = downloadBeginBlock;
    downLoad.downloadFileCompleteionBlock = downloadFileCompleteion;
    downLoad.downloadProgressChangeBlock = downloadProgressChangeBlock;
    downLoad.failedBlock = failedBlock;
    
    return downLoad;
}

+ (NSString *)apiVersion
{
    return @"2014-12-17";
}


@end
