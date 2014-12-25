//
//  KSS3HeadObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3HeadObjectRequest.h"
#import "KS3Constants.h"

@implementation KS3HeadObjectRequest
- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodHead;
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
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
    [super configureURLRequest];
    return self.urlRequest;
}
@end
