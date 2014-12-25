//
//  KSS3SetObjectGrantACLRequest.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3SetObjectGrantACLRequest.h"
#import "KS3GrantAccessControlList.h"
#import "KS3Constants.h"

@implementation KS3SetObjectGrantACLRequest

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
    self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl", self.kSYResource, _key];
    NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", _acl.identifier];
    strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", _acl.displayName];
    self.kSYHeader = [_acl.accessGrantACL stringByAppendingString:@":"];
    self.kSYHeader = [self.kSYHeader stringByAppendingString:strValue];
    self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?acl", self.bucket, _key];
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPut];
    [self.urlRequest setValue:strValue forHTTPHeaderField:_acl.accessGrantACL];
    
    return self.urlRequest;
}

@end
