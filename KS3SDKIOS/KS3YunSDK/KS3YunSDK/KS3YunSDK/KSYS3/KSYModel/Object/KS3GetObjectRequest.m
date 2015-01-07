//
//  KSS3GetObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectRequest.h"
#import "KS3Constants.h"

@implementation KS3GetObjectRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com", bucketName];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    self.kSYResource = [self.kSYResource stringByAppendingFormat:@"/%@", _key];
    
    // **** request params
    NSMutableString *queryPramaString = [NSMutableString stringWithCapacity:512];
    if (nil != _responseContentType) {
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentType, _responseContentType];
    }
    if (nil != _responseContentLanguage) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentLanguage, _responseContentLanguage];
    }
    if (nil != _responseExpires) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseExpires, _responseExpires];
    }
    if (nil != _responseCacheControl) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseCacheControl, _responseCacheControl];
    }
    if (nil != _responseContentDisposition) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentDisposition, _responseContentDisposition];
    }
    if (nil != _responseContentEncoding) {
        if (queryPramaString.length > 0) {
            [queryPramaString appendString:@"&"];
        }
        [queryPramaString appendFormat:@"%@=%@", kKS3QueryParamResponseContentEncoding, _responseContentEncoding];
    }
    self.host = [self.host stringByAppendingFormat:@"/%@?%@", _key, queryPramaString];
    [super configureURLRequest];
    
    // **** http header
    if (nil != _range) {
        [self.urlRequest setValue:_range forHTTPHeaderField:kKSHttpHdrRange];
    }
    if (nil != _ifModifiedSince) {
        [self.urlRequest setValue:_ifModifiedSince forHTTPHeaderField:kKSHttpHdrIfModifiedSince];
    }
    if (nil != _ifUnmodifiedSince) {
        [self.urlRequest setValue:_ifUnmodifiedSince forHTTPHeaderField:kKSHttpHdrIfUnmodifiedSince];
    }
    if (nil != _ifMatch) {
        [self.urlRequest setValue:_ifMatch forHTTPHeaderField:kKSHttpHdrIfMatch];
    }
    if (nil != _ifNoneMatch) {
        [self.urlRequest setValue:_ifNoneMatch forHTTPHeaderField:kKSHttpHdrIfNoneMatch];
    }
    return self.urlRequest;
}

@end
