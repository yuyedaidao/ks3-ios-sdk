//
//  KSS3DeleteObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3DeleteObjectRequest.h"
#import "KS3Constants.h"

@implementation KS3DeleteObjectRequest
- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKey
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.key = [self URLEncodedString:strKey];
        self.httpMethod = kHttpMethodDelete;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = [NSString stringWithFormat:@"http://%@.ks3-cn-beijing.ksyun.com", self.bucket];
        
        //
        self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_key];
        self.host = [NSString stringWithFormat:@"%@/%@",self.host,_key];
    }
    return self;
}
- (KS3URLRequest *)configureURLRequest{
    [super configureURLRequest];
    return self.urlRequest;
}
@end
