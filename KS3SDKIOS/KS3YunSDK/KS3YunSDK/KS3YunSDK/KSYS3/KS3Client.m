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

static NSString * const KingSoftYun_Host_Name = @"http://kss.ksyun.com";
static NSTimeInterval const KingSoftYun_RequestTimeout = 60;
@interface KS3Client ()
@property (strong, nonatomic) KS3Credentials *credentials;
@end

@implementation KS3Client

+ (KS3Client *)initialize
{
    static KS3Client *shareObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[self alloc] init];
    });
    return shareObj;
}
#pragma mark --
#pragma mark -- ConnectWithAccessKey
- (void)connectWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey
{
    if (_credentials == nil) {
        _credentials = [[KS3Credentials alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
    }
}
#pragma mark --
#pragma mark -- Buckets
- (NSArray *)listBuckets
{
    KS3ListBucketsRequest *req = [KS3ListBucketsRequest new];
    KS3ListBucketsResponse *listResponse = [self listBuckets:req];
    if (listResponse.error == nil && listResponse.listBucketsResult != nil && listResponse.listBucketsResult.buckets != nil) {
        return [NSArray arrayWithArray:listResponse.listBucketsResult.buckets];
    }
    
    return nil;
}

- (KS3ListBucketsResponse *)listBuckets:(KS3ListBucketsRequest *)listBucketsRequest
{
    return (KS3ListBucketsResponse *)[self invoke:listBucketsRequest];
}

- (KS3CreateBucketResponse *)createBucketWithName:(NSString *)bucketName
{
    KS3CreateBucketRequest  *createBucketRequest  = [[KS3CreateBucketRequest alloc] initWithName:bucketName];
    KS3CreateBucketResponse *createBucketResponse = [self createBucket:createBucketRequest];
    return createBucketResponse;
}

- (KS3CreateBucketResponse *)createBucket:(KS3CreateBucketRequest *)createBucketRequest
{
    return (KS3CreateBucketResponse *)[self invoke:createBucketRequest];
}

- (KS3DeleteBucketResponse *)deleteBucketWithName:(NSString *)bucketName
{
    KS3DeleteBucketRequest  *deleteBucketRequest  = [[KS3DeleteBucketRequest alloc] initWithName:bucketName];
    KS3DeleteBucketResponse *deleteBucketResponse = [self deleteBucket:deleteBucketRequest];
    return deleteBucketResponse;
}
- (KS3DeleteBucketResponse *)deleteBucket:(KS3DeleteBucketRequest *)deleteBucketRequest
{
    return (KS3DeleteBucketResponse *)[self invoke:deleteBucketRequest];
}
- (KS3HeadBucketResponse *)headBucket:(KS3HeadBucketRequest *)headBucketRequest;
{
    return (KS3HeadBucketResponse *)[self invoke:headBucketRequest];
}

- (KS3GetACLResponse *)getBucketACL:(NSString *)bucketName
{
    KS3GetACLRequest *getBucketACLRequest  = [[KS3GetACLRequest alloc] initWithName:bucketName];
    KS3GetACLResponse *getBucketResponse = [self getACL:getBucketACLRequest];
    return getBucketResponse;
}
- (KS3GetACLResponse *)getACL:(KS3GetACLRequest *)getACLRequest
{
    return (KS3GetACLResponse *)[self invoke:getACLRequest];
}


- (KS3SetACLResponse *)setBucketACL:(NSString *)bucketName
{
    KS3SetACLRequest *setACLRequest = [[KS3SetACLRequest alloc] initWithName:bucketName];
    KS3AccessControlList *accessControlList = [KS3AccessControlList new];
    [accessControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
    setACLRequest.acl = accessControlList;
    KS3SetACLResponse *setACLResponse = [self setACL:setACLRequest];
    return setACLResponse;
}
- (KS3SetACLResponse *)setACL:(KS3SetACLRequest *)getACLRequest
{
    return (KS3SetACLResponse *)[self invoke:getACLRequest];
}

- (KS3GetBucketLoggingResponse *)getBucketLoggingWithName:(NSString *)bucketName
{
    KS3GetBucketLoggingRequest  *req = [[KS3GetBucketLoggingRequest alloc] initWithName:bucketName] ;
    return [self getBucketLogging:req];
}
- (KS3GetBucketLoggingResponse *)getBucketLogging:(KS3GetBucketLoggingRequest *)getBucketLoggingRequest
{
    return (KS3GetBucketLoggingResponse *)[self invoke:getBucketLoggingRequest];
}



- (KS3SetBucketLoggingResponse *)setBucketLoggingWithName:(NSString *)bucketName
{
    KS3SetBucketLoggingRequest  *req = [[KS3SetBucketLoggingRequest alloc] initWithName:bucketName] ;
    return [self setBucketLogging:req];
}
- (KS3SetBucketLoggingResponse *)setBucketLogging:(KS3SetBucketLoggingRequest *)setBucketTaggingRequest{
    return (KS3SetBucketLoggingResponse *)[self invoke:setBucketTaggingRequest];
}
#pragma mark --
#pragma mark -- Objects
- (NSArray *)listObjectsInBucket:(NSString *)bucketName
{
    if (!bucketName) {
        NSLog(@"bucket 不能为空");
        return nil;
    }
    KS3ListObjectsRequest  *req = [[KS3ListObjectsRequest alloc] initWithName:bucketName] ;
    //    req.prefix = @"r32/tew3";
    //    req.delimiter = @"c";
    //    req.maxKeys = 5;
    KS3ListObjectsResponse *res = [self listObjects:req];
    return res.listBucketsResult.objectSummaries;
}

- (KS3ListObjectsResponse *)listObjects:(KS3ListObjectsRequest *)listObjectsRequest
{
    return (KS3ListObjectsResponse *)[self invoke:listObjectsRequest];
}

/*

-(KSS3GetObjectResponse *)getObjectWithName:(NSString *)bucketName
{
    KSS3GetObjectRequest *req = [[KSS3GetObjectRequest alloc] initWithName:bucketName];
    return (KSS3GetObjectResponse *)[self getObject:req];
}
*/
- (KS3GetObjectResponse *)getObject:(KS3GetObjectRequest *)getObjectRequest
{
    return (KS3GetObjectResponse *)[self invoke:getObjectRequest];
}
/*
- (KSS3DeleteObjectResponse *)deleteObjectWithBucketName:(NSString *)deleteBucketName
{
    KSS3DeleteObjectRequest *req = [[KSS3DeleteObjectRequest alloc] initWithName:deleteBucketName];
    req.key = @"31231312312.png";
    return [self deleteObject:req];

}
 */

- (KS3DeleteObjectResponse *)deleteObject:(KS3DeleteObjectRequest *)deleteObjectRequest
{
    return (KS3DeleteObjectResponse *)[self invoke:deleteObjectRequest];
}

/*
- (KSS3HeadObjectResponse *)headObjectWithBucketName:(NSString *)headBucketName
{
    KSS3HeadObjectRequest *req = [[KSS3HeadObjectRequest alloc] initWithName:headBucketName];
    req.key = @"test_yun_1.jpg";
    return [self headObject:req];
}
*/

- (KS3HeadObjectResponse *)headObject:(KS3HeadObjectRequest *)headObjectRequest
{
    return (KS3HeadObjectResponse *)[self invoke:headObjectRequest];
}
/*
-(KSS3PutObjectResponse *)putObjectWithBucketName:(NSString *)bucketName
{
    KSS3PutObjectRequest *req = [[KSS3PutObjectRequest alloc] initWithName:bucketName];
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test_yun_3" ofType:@"jpg"];
    req.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
    req.filename = [fileName lastPathComponent];
    return (KSS3PutObjectResponse *)[self putObject:req];
}
*/
- (KS3PutObjectResponse *)putObject:(KS3PutObjectRequest *)putObjectRequest
{
    return (KS3PutObjectResponse *)[self invoke:putObjectRequest];
}

- (KS3PutObjectCopyResponse *)putObjectCopy:(KS3PutObjectCopyRequest *)putObjectCopyRequest
{
    return (KS3PutObjectCopyResponse *)[self invoke:putObjectCopyRequest];
}
/*
-(KSS3GetObjectACLResponse *)getObjectACLWithBucketName:(NSString *)bucketName
{
    KSS3GetObjectACLRequest *req = [[KSS3GetObjectACLRequest alloc] initWithName:bucketName];
    req.key = @"bcd";
    return (KSS3GetObjectACLResponse *)[self getObjectACL:req];
}
*/
- (KS3GetObjectACLResponse *)getObjectACL:(KS3GetObjectACLRequest *)getObjectACLRequest
{
    return (KS3GetObjectACLResponse *)[self invoke:getObjectACLRequest];
}
/*
-(KSS3SetObjectACLResponse *)setObjectACLWithBucketName:(NSString *)bucketName
{
    KSS3SetObjectACLRequest *req = [[KSS3SetObjectACLRequest alloc] initWithName:bucketName];
    req.key = @"bcd";
    KSS3AccessControlList *accessControlList = [KSS3AccessControlList new];
    [accessControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
    req.acl = accessControlList;
    return (KSS3SetObjectACLResponse *)[self setObjectACL:req];
}
 */
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

#pragma mark --
#pragma mark -- MultipartUpload
- (KS3MultipartUpload *)initiateMultipartUploadWithKey:(NSString *)theKey withBucket:(NSString *)bucketName
{
    KS3InitiateMultipartUploadRequest *request = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:theKey inBucket:bucketName];
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
- (KS3Response *)invoke:(KS3Request *)request
{
    if (!_credentials && !_credentials.accessKey && !_credentials.secretKey) {
        KS3Response *response = [KS3Response new];
        response.error = [KS3ErrorHandler errorFromExceptionWithThrowsExceptionOption:[KS3ClientException exceptionWithMessage:@"配置的accessKey和secretKey有错误!"]];
        return response;
    }
    if (!_credentials && !_credentials.accessKey && !_credentials.secretKey) {
        
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
    NSMutableURLRequest *urlRequest = [self signKSS3Request:request];
    [urlRequest setTimeoutInterval:KingSoftYun_RequestTimeout];
    KS3Response *response = [KS3Client constructResponseFromRequest:request];
    [response setRequest:request];
    if ([request delegate] != nil) {
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                                         delegate:response
                                                                 startImmediately:NO];
        request.urlConnection = urlConnection;
        [NSTimer scheduledTimerWithTimeInterval:KingSoftYun_RequestTimeout
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
    NSTimer *timeoutTimer = [NSTimer timerWithTimeInterval:KingSoftYun_RequestTimeout
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
//NSLog(@"%@",@"配置的accessKey和secretKey有错误");
#pragma mark --
#pragma mark -- Download
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
    if (!_credentials && !_credentials.accessKey && !_credentials.secretKey) {
        NSLog(@"请设置 accessKey 或 secretKey！！");
        return nil;
    }
    
    NSString *strHost = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@", bucketName, key];
    KS3DownLoad *downLoad = [[KS3DownLoad alloc] initWithUrl:strHost credentials:_credentials];
    downLoad.bucketName = bucketName;
    downLoad.key = key;
    downLoad.downloadBeginBlock = downloadBeginBlock;
    downLoad.downloadFileCompleteionBlock = downloadFileCompleteion;
    downLoad.downloadProgressChangeBlock = downloadProgressChangeBlock;
    downLoad.failedBlock = failedBlock;
    [downLoad start];
    return downLoad;
}

+ (NSString *)apiVersion
{
    return @"2014-12-17";
}
@end
