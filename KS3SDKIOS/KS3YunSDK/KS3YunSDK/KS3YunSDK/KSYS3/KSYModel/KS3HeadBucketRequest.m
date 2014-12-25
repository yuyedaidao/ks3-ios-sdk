//
//  KSS3HeadBucketRequest.m
//  KS3YunSDK
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3HeadBucketRequest.h"
#import "KS3Constants.h"
@implementation KS3HeadBucketRequest
- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodHead;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@/", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com", bucketName];
    }
    return self;
}

@end
