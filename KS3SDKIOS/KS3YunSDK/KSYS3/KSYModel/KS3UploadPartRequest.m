//
//  KSS3UploadPartRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3UploadPartRequest.h"
#import "KS3SDKUtil.h"
#import "KS3Constants.h"

@interface KS3UploadPartRequest ()

@property (strong, nonatomic) KS3MultipartUpload *multipartUpload;
@end

@implementation KS3UploadPartRequest

-(id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload
{
    if(self = [super init])
    {
        self.bucket   = multipartUpload.bucket;
        self.key      = multipartUpload.key;
        self.uploadId = multipartUpload.uploadId;
        
        self.contentMd5 = nil;
        _generateMD5 = YES;
        _multipartUpload = multipartUpload;
        self.contentType = @"binary/octet-stream";
        self.kSYHeader = @"";
        self.httpMethod = kHttpMethodPut;
    }
    
    return self;
}

-(NSMutableURLRequest *)configureURLRequest
{
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?partNumber=%d&uploadId=%@", self.bucket, _key, _partNumber, _multipartUpload.uploadId];
    
    if (nil == self.contentMd5 && YES == self.generateMD5 && self.data != nil) {
        self.contentMd5 = [KS3SDKUtil base64md5FromData:self.data];
    }
    
//    self.kSYResource = [NSString stringWithFormat:@"%@=%d&%@=%@", kKS3QueryParamPartNumber, self.partNumber, kKS3QueryParamUploadId, self.uploadId];
    self.kSYResource = [NSString stringWithFormat:@"/%@/%@?%@=%d&%@=%@", self.bucket,self.key, kKS3QueryParamPartNumber, self.partNumber, kKS3QueryParamUploadId, self.uploadId];
    [super configureURLRequest];
    if (self.contentLength < 1) {
        self.contentLength = [self.data length];
    }
    [self.urlRequest  setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[self.urlRequest  HTTPBody] length]] forHTTPHeaderField:kKSHttpHdrContentLength];
    if (self.data != nil) {
        [self.urlRequest setHTTPBody:self.data];
    }
    if (nil != self.contentMd5) {
        [self.urlRequest setValue:self.contentMd5 forHTTPHeaderField:kKS3HttpHdrContentMD5];
    }
    [self.urlRequest setValue:self.contentType forHTTPHeaderField:kKSHttpHdrContentType];
    return self.urlRequest;
}

@end