//
//  KSS3FileUploader.m
//  KSYSDKDemo
//
//  Created by Blues on 12/24/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3FileUploader.h"
#import "KS3Client.h"
#import "KS3UploadPartRequest.h"
#import "KS3Request.h"
#import "KS3Response.h"
#import "KS3ListPartsRequest.h"
#import "KS3ListPartsResponse.h"
#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3Part.h"
#import "KS3MultipartUpload.h"
#import "KS3AbortMultipartUploadRequest.h"
#import "KS3AbortMultipartUploadResponse.h"

@interface KS3FileUploader () <KingSoftServiceRequestDelegate>

@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (assign, nonatomic) long long fileSize;
@property (assign, nonatomic) long long partLength;
@property (nonatomic) NSInteger totalNum;
@property (nonatomic) NSInteger uploadNum;
@property (nonatomic, strong) NSString *bucketName;
@property (strong, nonatomic)  KS3MultipartUpload *muilt;

@property (nonatomic, copy) KS3UploadProgressChangedBlock uploadProgressChangedBlock;
@property (nonatomic, copy) KS3UploadCompleteBlock uploadCompleteBlock;
@property (nonatomic, copy) KS3UploadFailedBloack uploadFailedBlock;

@end


@implementation KS3FileUploader


- (instancetype)initWithBucketName:(NSString *)strBucketName
{
    self = [super init];
    if (self) {
        _partSize = 5.0;
        _bucketName = strBucketName;
    }
    return self;
}

- (void)abortUpload
{
    KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
    KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
    if (response.httpStatusCode == 204) {
        NSLog(@"Abort multipart upload success!");
    }
    else {
        NSLog(@"error: %@", response.error.description);
    }
}

- (void)startUploadWithProgressChangeBlock:(KS3UploadProgressChangedBlock)uploadProgressChangedBlock
                    completeBlock:(KS3UploadCompleteBlock)uploadCompleteBlock
                      failedBlock:(KS3UploadFailedBloack)uploadFailedBlock
{
    
    if (!_bucketName || !_strKey) {
        NSLog(@"bucket 或 key 不能为空");
        return ;
    }
    _fileHandle = [NSFileHandle fileHandleForReadingAtPath:_strFilePath];
    _fileSize = [_fileHandle availableData].length;
    if (_fileSize <= 0) {
        NSLog(@"####This file is not exist!####");
        return ;
    }
    if (!(_partSize > 0 || _partSize != 0)) {
        _partLength = _fileSize;
    }else{
       _partLength = _partSize * 1024.0 * 1024.0;
    }
    
    _totalNum = (ceilf((float)_fileSize / (float)_partLength));
    [_fileHandle seekToFileOffset:0];
    
    _muilt = [[KS3Client initialize] initiateMultipartUploadWithKey:_strKey withBucket:_bucketName];
    if (_muilt == nil) {
        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
        return ;
    }
    _uploadProgressChangedBlock = uploadProgressChangedBlock;
    _uploadCompleteBlock = uploadCompleteBlock;
    _uploadFailedBlock = uploadFailedBlock;
    _uploadNum = 1;
    [self uploadWithPartNumber:_uploadNum];
}

- (void)uploadWithPartNumber:(NSInteger)partNumber
{
    long long partLength = _partSize * 1024.0 * 1024.0;
    NSData *data = nil;
    if (_uploadNum == _totalNum) {
        data = [_fileHandle readDataToEndOfFile];
    }else {
        data = [_fileHandle readDataOfLength:(NSUInteger)partLength];
        [_fileHandle seekToFileOffset:partLength*(_uploadNum)];
    }
    
    KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
    req.delegate = self;
    req.data = data;
    req.partNumber = (int32_t)partNumber;
    req.contentLength = data.length;
    [[KS3Client initialize] uploadPart:req];
}

#pragma mark - Delegate

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    _uploadNum ++;
    if (_totalNum < _uploadNum) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        req.callbackUrl = _callbackUrl;
        req.callbackBody = _callbackBody;
        req.callbackParams = _callbackParams;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [[KS3Client initialize] completeMultipartUpload:req];
            _uploadCompleteBlock(self);
        });
    }
    else {
        [self uploadWithPartNumber:_uploadNum];
    }
}

- (void)request:(KS3Request *)request didFailWithError:(NSError *)error
{
    _uploadFailedBlock(self, _muilt.uploadId, _uploadNum, error);
}

- (void)request:(KS3Request *)request didReceiveResponse:(NSURLResponse *)response
{
    // **** TODO:
}

- (void)request:(KS3Request *)request didReceiveData:(NSData *)data
{
    /**
     *  Never call this method, because it's upload
     *
     *  @return <#return value description#>
     */
}

-(void)request:(KS3Request *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    long long alreadyTotalWriten = (_uploadNum - 1) * _partLength + totalBytesWritten;
    double progress = alreadyTotalWriten / (float)_fileSize;
    _uploadProgressChangedBlock(self, progress);
}

#pragma mark - Override

- (void)setPartSize:(double)partSize
{
    _partSize = partSize;
    if (partSize < 5.0) {
        _partSize = 5.0;
    }
}

@end
