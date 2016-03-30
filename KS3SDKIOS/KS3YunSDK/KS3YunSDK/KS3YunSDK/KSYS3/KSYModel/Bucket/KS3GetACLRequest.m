//
//  KSS3BucketACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetACLRequest.h"
#import "KS3Constants.h"

@implementation KS3GetACLRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@/?acl", self.bucket];
        self.host = [NSString stringWithFormat:@"http://%@.ks3-cn-beijing.ksyun.com/?acl", self.bucket];
    }
    return self;
}
@end
