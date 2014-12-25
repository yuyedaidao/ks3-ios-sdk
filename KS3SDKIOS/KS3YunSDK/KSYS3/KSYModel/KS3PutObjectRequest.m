//
//  KSS3PutObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3PutObjectRequest.h"
#import "KS3Constants.h"

@implementation KS3PutObjectRequest

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
    [self.urlRequest setHTTPBody:_data];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_filename];
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_filename];
    [super configureURLRequest];
    return self.urlRequest;
}

@end
