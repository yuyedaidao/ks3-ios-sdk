//
//  KS3PutObjectCopyRequest.m
//  KSYSDKDemo
//
//  Created by Blues on 12/25/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3PutObjectCopyRequest.h"
#import "KS3Constants.h"

@implementation KS3PutObjectCopyRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodPut;
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
    NSString *strValue = [NSString stringWithFormat:@"/%@/%@", _strSourceBucket, _strSourceObject];
    self.kSYHeader = [@"x-kss-copy-source:" stringByAppendingString:strValue];
    self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
    [super configureURLRequest];
    [self.urlRequest setValue:strValue forHTTPHeaderField:@"x-kss-copy-source"];
    return self.urlRequest;
}

@end
