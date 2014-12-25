//
//  KSS3ListPartsRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListPartsRequest.h"
#import "KS3Constants.h"

@implementation KS3ListPartsRequest

-(id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload
{
    if(self = [self init])
    {
        self.bucket   = multipartUpload.bucket;
        self.key      = multipartUpload.key;
        self.uploadId = multipartUpload.uploadId;
        self.contentMd5  = @"";
        self.contentType = @"";
        self.httpMethod = kHttpMethodGet;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
    }
    
    return self;
}

-(NSMutableURLRequest *)configureURLRequest
{
    
//    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploadId=%@", self.bucket, self.key, self.uploadId];;
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploadId=%@", self.bucket, self.key, self.uploadId];;
    self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploadId=%@",self.kSYResource,self.key,self.uploadId];
    NSMutableString *subresource = [NSMutableString stringWithFormat:@"%@=%@", kKS3QueryParamUploadId, self.uploadId];
    
    if (self.maxParts != 1000) {
        [subresource appendFormat:@"&%@=%d", kKS3QueryParamMaxParts, self.maxParts];
    }
    
    if (self.partNumberMarker != 0) {
        [subresource appendFormat:@"&%@=%d", kKS3QueryParamPartNumberMarker, self.partNumberMarker];
    }
    
//    self.kSYResource = [NSString stringWithString:subresource];
    
    [super configureURLRequest];
    
    [self.urlRequest setHTTPMethod:kHttpMethodGet];
    
    return self.urlRequest;
}


@end