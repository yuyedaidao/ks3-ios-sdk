//
//  KSS3SetObjectACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3SetObjectACLRequest.h"
#import "KS3Constants.h"
#import "KS3AccessControlList.h"
@implementation KS3SetObjectACLRequest
- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", bucketName];
        self.host = @"";
    }
    return self;
}
- (KS3URLRequest *)configureURLRequest
{
    self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
    self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl", self.kSYResource,_key];
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?acl", self.bucket, _key];
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPut];
    [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    return self.urlRequest;
}

@end
