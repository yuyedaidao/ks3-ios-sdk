//
//  KSS3HeadObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3HeadObjectRequest.h"
#import "KS3Constants.h"

@implementation KS3HeadObjectRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodHead;
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
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
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
