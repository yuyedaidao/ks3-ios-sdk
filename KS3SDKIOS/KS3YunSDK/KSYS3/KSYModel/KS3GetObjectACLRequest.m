//
//  KSS3GetObjectACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectACLRequest.h"
#import "KS3Constants.h"

@implementation KS3GetObjectACLRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/", bucketName];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl",self.kSYResource,_key];
    self.host = [NSString stringWithFormat:@"%@%@?acl",self.host,_key];
    [super configureURLRequest];
    return self.urlRequest;
}
@end
