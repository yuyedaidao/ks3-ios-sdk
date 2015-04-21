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

- (id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload
{
    if(self = [self init])
    {
        self.bucket   = [self URLEncodedString:multipartUpload.bucket];
        self.key      = [self URLEncodedString:multipartUpload.key];
        self.uploadId = multipartUpload.uploadId;
        self.contentMd5  = @"";
        self.contentType = @"";
        self.maxParts = 1000;// **** default value
        self.httpMethod = kHttpMethodGet;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        //
        self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploadId=%@",self.kSYResource,self.key,self.uploadId];
    }
    return self;
}

- (NSMutableURLRequest *)configureURLRequest
{
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploadId=%@", self.bucket, self.key, self.uploadId];
//    self.host = [NSString stringWithFormat:@"http://115.231.96.27:8080/%@/%@?uploadId=%@", self.bucket, self.key, self.uploadId];
    
//    self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploadId=%@",self.kSYResource,self.key,self.uploadId];

    NSMutableString *subresource = [NSMutableString stringWithCapacity:512];
    if (self.maxParts != 1000) { // **** default is 1000
        [subresource appendFormat:@"&%@=%d", kKS3QueryParamMaxParts, self.maxParts];
    }
    if (self.partNumberMarker != 0) {
        [subresource appendFormat:@"&%@=%d", kKS3QueryParamPartNumberMarker, self.partNumberMarker];
    }
    if (nil != _encodingType) {
        if (subresource.length > 0) {
            [subresource appendString:@"&"];
        }
        [subresource appendFormat:@"%@=%@", kKS3QueryParamEncodingType, _encodingType];
    }
    if (subresource.length > 0) {
        self.host = [NSString stringWithFormat:@"%@%@", self.host, subresource];
    }
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodGet];
    return self.urlRequest;
}

@end
