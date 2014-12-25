//
//  KSS3InitiateMultipartUploadRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3InitiateMultipartUploadRequest.h"
#import "KS3Constants.h"


@interface KS3InitiateMultipartUploadRequest ()

@property (nonatomic, assign) BOOL expiresSet;
@end


@implementation KS3InitiateMultipartUploadRequest

-(id)init
{
    if (self = [super init])
    {
        _expires = 0;
        _expiresSet = NO;
    }
    
    return self;
}

-(id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket
{
    if(self = [self init])
    {
        self.key    = aKey;
        self.bucket = aBucket;
        self.httpMethod = kHttpMethodPost;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", aBucket];
        self.host = @"";
    }
    
    return self;
}

-(void)setExpires:(int32_t)exp
{
    _expires    = exp;
    _expiresSet = YES;
}

-(NSMutableURLRequest *)configureURLRequest
{
//    [self setKSYResource:kKS3SubResourceUploads];
//    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploads", self.bucket, self.key];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploads",self.kSYResource,_key];
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploads", self.bucket, self.key];
    [super configureURLRequest];
    
    [self.urlRequest setHTTPMethod:kHttpMethodPost];
    
    if (nil != self.contentEncoding) {
        [self.urlRequest setValue:self.contentEncoding
               forHTTPHeaderField:kKSHttpHdrContentEncoding];
    }
    if (nil != self.contentDisposition) {
        [self.urlRequest setValue:self.contentDisposition
               forHTTPHeaderField:kKSHttpHdrContentDisposition];
    }
    if (nil != self.cacheControl) {
        [self.urlRequest setValue:self.cacheControl
               forHTTPHeaderField:kKSHttpHdrCacheControl];
    }
//    if (nil != self.redirectLocation) {
//        [self.urlRequest setValue:self.redirectLocation
//               forHTTPHeaderField:kHttpHdrAmzWebsiteRedirectLocation];
//    }
//    
//    if (self.expiresSet) {
//        [self.urlRequest setValue:[NSString stringWithFormat:@"%d", self.expires]
//               forHTTPHeaderField:kHttpHdrExpires];
//    }
    
    
    return self.urlRequest;
}


@end
