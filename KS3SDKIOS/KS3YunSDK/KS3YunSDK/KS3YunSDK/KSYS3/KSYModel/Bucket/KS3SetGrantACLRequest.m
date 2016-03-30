//
//  KSS3SetGrantACLRequest.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KS3SetGrantACLRequest.h"
#import "KS3GrantAccessControlList.h"
#import "KS3Constants.h"

@implementation KS3SetGrantACLRequest
- (instancetype)initWithName:(NSString *)bucketName accessACL:(KS3GrantAccessControlList *)accessACL
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@/?acl", self.bucket];
        self.host = [NSString stringWithFormat:@"http://%@.ks3-cn-beijing.ksyun.com/?acl", self.bucket];
     
        if (accessACL) {
            _acl = accessACL;
            NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", _acl.identifier];
            strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", _acl.displayName];
            self.kSYHeader = [_acl.accessGrantACL stringByAppendingString:@":"];
            self.kSYHeader = [self.kSYHeader stringByAppendingString:strValue];
            self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
            [self.urlRequest setValue:strValue forHTTPHeaderField:_acl.accessGrantACL];
        }
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    [super configureURLRequest];
    return self.urlRequest;
}

@end
