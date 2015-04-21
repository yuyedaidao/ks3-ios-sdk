//
//  KSS3SetACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3SetACLRequest.h"
#import "KS3AccessControlList.h"
#import "KS3Constants.h"
@implementation KS3SetACLRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@/?acl", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/?acl", bucketName];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
    self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
    [super configureURLRequest];
    [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    return self.urlRequest;
    
}
@end
