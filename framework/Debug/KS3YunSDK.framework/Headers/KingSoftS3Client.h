//
//  KingSoftS3Client.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//  有问题联系
//  QQ:315720327
//  email:me@iluckly.com
//


#import "KingSoftWebServiceClient.h"

@class KSS3DownloadedFile;
@class KingSoftURLConnection;
@class KSS3DownLoad;

#pragma mark - Download block

typedef void(^KSS3DownloadBeginBlock)(KSS3DownLoad *aDownload, NSURLResponse *responseHeaders);
typedef void(^KSS3DownloadProgressChangeBlock)(KSS3DownLoad *aDownload, double newProgress);
typedef void(^KSS3DownloadFailedBlock)(KSS3DownLoad *aDownload, NSError *error);
typedef void(^kSS3DownloadFileCompleteionBlock)(KSS3DownLoad *aDownload, NSString *filePath);

@class KSS3DeleteBucketResponse;
@class KSS3SetACLResponse;
@class KSS3ListBucketsRequest;
@class KSS3ListBucketsResponse;
@class KSS3CreateBucketResponse;
@class KSS3GetACLResponse;
@class KSS3GetBucketLoggingResponse;
@class KSS3SetBucketLoggingResponse;
@class KSS3GetObjectResponse;
@class KSS3DeleteObjectResponse;
@class KSS3HeadObjectResponse;
@class KSS3PutObjectResponse;
@class KSS3GetObjectACLResponse;
@class KSS3SetObjectACLResponse;
@class KSS3UploadPartResponse;
@class KSS3UploadPartRequest;
@class KSS3MultipartUpload;
@class KSS3ListPartsResponse;
@class KSS3ListPartsRequest;
@class KSS3CompleteMultipartUploadResponse;
@class KSS3CompleteMultipartUploadRequest;
@class KSS3ListObjectsResponse;
@class KSS3ListObjectsRequest;
@class KSS3CreateBucketRequest;
@class KSS3DeleteBucketResponse;
@class KSS3DeleteBucketRequest;
@class KSS3SetACLRequest;
@class KSS3PutObjectRequest;
@class KSS3GetObjectACLRequest;
@class KSS3SetObjectACLRequest;
@class KSS3DeleteObjectRequest;
@class KSS3AbortMultipartUploadRequest;
@class KSS3AbortMultipartUploadResponse;
@class KSS3HeadBucketRequest;
@class KSS3HeadBucketResponse;
@class KSS3GetACLRequest;
@class KSS3GetObjectRequest;
@class KSS3HeadObjectRequest;
@class KSS3SetGrantACLResponse;
@class KSS3SetGrantACLRequest;
@class KSS3SetObjectGrantACLResponse;
@class KSS3SetObjectGrantACLRequest;
@interface KingSoftS3Client : KingSoftWebServiceClient

+ (KingSoftS3Client *)initialize;
/**
 *  设置AccessKey和SecretKey
 *
 *  @param accessKey
 *  @param secretKey 
 *  注释：这个接口必须实现（这个是使用下面API的（前提））在工程的delete里面实现
 */
- (void)connectWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey;

/**
 *  列出客户所有的Bucket信息
 *
 *  @return 所有bucket的数组
 */
- (NSArray *)listBuckets;
/**
 *  创建一个新的Bucket
 *
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3CreateBucketResponse *)createBucketWithName:(NSString *)bucketName;
/**
 *  创建一个新的Bucket
 *
 *  @param createBucketRequest 设置创建bucket的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3CreateBucketResponse *)createBucket:(KSS3CreateBucketRequest *)createBucketRequest;
/**
 *  删除指定Bucket
 *
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3DeleteBucketResponse *)deleteBucketWithName:(NSString *)bucketName;
/**
 *  删除指定Bucket
 *
 *  @param deleteBucketRequest 设置删除bucket的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3DeleteBucketResponse *)deleteBucket:(KSS3DeleteBucketRequest *)deleteBucketRequest;
/**
 *  查询是否已经存在指定Bucket
 *
 *  @param headBucketRequest 设置是否已经存在指定Bucket的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3HeadBucketResponse *)headBucket:(KSS3HeadBucketRequest *)headBucketRequest;
/**
 *  获得Bucket的acl
 *
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3GetACLResponse *)getBucketACL:(NSString *)bucketName;
/**
 *  获得Bucket的acl
 *
 *  @param getACLRequest 设置获取Bucket的acl的request对象
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3GetACLResponse *)getACL:(KSS3GetACLRequest *)getACLRequest;
/**
 *  设置Bucket的ACL
 *
 *  @param getACLRequest 设置设置Bucket的ACL的request对象
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3SetACLResponse *)setACL:(KSS3SetACLRequest *)getACLRequest;
/**
 *  设置GrantACL信息
 *
 *  @param setGrantACLRequest 设置grantACL的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3SetGrantACLResponse *)setGrantACL:(KSS3SetGrantACLRequest *)setGrantACLRequest;
/**
 *  列举Bucket内的Object
 *
 *  @param bucketName 
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (NSArray *)listObjectsInBucket:(NSString *)bucketName;
/**
 *  列举Bucket内的Object
 *
 *  @param listObjectsRequest 设置列举Bucket内的Object的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3ListObjectsResponse *)listObjects:(KSS3ListObjectsRequest *)listObjectsRequest;
/**
 *  获得Bucket的日志信息
 *
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3GetBucketLoggingResponse *)getBucketLoggingWithName:(NSString *)bucketName;
/**
 *  设置Bucket的日志信息
 *
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3SetBucketLoggingResponse *)setBucketLoggingWithName:(NSString *)bucketName;
/**
 *  下载Object数据
 *
 *  @param getObjectRequest 设置下载Object的request请求信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3GetObjectResponse *)getObject:(KSS3GetObjectRequest *)getObjectRequest;
/**
 *  删除指定Object
 *
 *  @param deleteObjectRequest 设置删除Object的request请求信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3DeleteObjectResponse *)deleteObject:(KSS3DeleteObjectRequest *)deleteObjectRequest;

/**
 *  查询是否已经存在指定Object
 *
 *  @param headObjectRequest 设置是否已存在Object的request的信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3HeadObjectResponse *)headObject:(KSS3HeadObjectRequest *)headObjectRequest;
/**
 *  上传Object数据 （如果文件比较大请设置委托）
 *
 *  @param putObjectRequest 设置上传object的request的信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3PutObjectResponse *)putObject:(KSS3PutObjectRequest *)putObjectRequest;

/**
 *  获得Object的acl
 *
 *  @param getObjectACLRequest 设置获取object的acl的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3GetObjectACLResponse *)getObjectACL:(KSS3GetObjectACLRequest *)getObjectACLRequest;
/**
 *  设置Object的acl
 *
 *  @param setObjectACLRequest 设置设置object的acl的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */

- (KSS3SetObjectACLResponse *)setObjectACL:(KSS3SetObjectACLRequest *)setObjectACLRequest;
/**
 *  设置ObjectGrantACL
 *
 *  @param setObjectGrantACLRequest 设置设置ObjectGrantACL的request信息
 *
 *  @return @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */

- (KSS3SetObjectGrantACLResponse *)setObjectGrantACL:(KSS3SetObjectGrantACLRequest *)setObjectGrantACLRequest;
/**
 *  调用这个接口会初始化一个分块上传
 *
 *  @param theKey    指的是上传到bucketName的文件名称
 *  @param bucketName
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3MultipartUpload *)initiateMultipartUploadWithKey:(NSString *)theKey withBucket:(NSString *)bucketName;

/**
 *  上传分块
 *
 *  @param uploadPartRequest 指定上传分块的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3UploadPartResponse *)uploadPart:(KSS3UploadPartRequest *)uploadPartRequest;
/**
 *  罗列出已经上传的块
 *
 *  @param listPartsRequest 设置罗列已经上传的分块的request信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */

- (KSS3ListPartsResponse *)listParts:(KSS3ListPartsRequest *)listPartsRequest;
/**
 *  组装所有分块上传的文件
 *
 *  @param completeMultipartUploadRequest 设置组装所有分块的http信息
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3CompleteMultipartUploadResponse *)completeMultipartUpload:(KSS3CompleteMultipartUploadRequest *)completeMultipartUploadRequest;
/**
 *  取消分块上传
 *
 *  @param abortMultipartRequest 设置分块文件属性
 *
 *  @return 返回resonse对象（里边有服务返回的数据（具体的参照demo））
 */
- (KSS3AbortMultipartUploadResponse *)abortMultipartUpload:(KSS3AbortMultipartUploadRequest *)abortMultipartRequest;
/**
 *  下载Object数据
 *
 *  @param bucketName
 *  @param key                         文件所在的仓库路径（和listObject的key对应）（具体的参照demo）
 *  @param downloadBeginBlock          下载开始回调
 *  @param downloadFileCompleteion     下载完成回调
 *  @param downloadProgressChangeBlock 下载进度回调
 *  @param failedBlock                 下载失败回调
 *
 *  @return 一个下载器对象（里面有文件属性）
 */
- (KSS3DownLoad *)downloadObjectWithBucketName:(NSString *)bucketName
                                           key:(NSString *)key
                        downloadBeginBlock:(KSS3DownloadBeginBlock)downloadBeginBlock
                       downloadFileCompleteion:(kSS3DownloadFileCompleteionBlock)downloadFileCompleteion
                   downloadProgressChangeBlock:(KSS3DownloadProgressChangeBlock)downloadProgressChangeBlock
                                   failedBlock:(KSS3DownloadFailedBlock)failedBlock;


/**
 *  返回版本信息
 *
 *  @return 版本信息
 */
+ (NSString *)apiVersion;


@end