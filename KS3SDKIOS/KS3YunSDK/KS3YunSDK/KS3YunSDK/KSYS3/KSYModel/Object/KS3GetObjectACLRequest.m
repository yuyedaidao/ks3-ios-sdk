//
//  KSS3GetObjectACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectACLRequest.h"
#import "KS3Constants.h"

@implementation KS3GetObjectACLRequest

- (instancetype)initWithName:(NSString *)bucketName withKeyName:(NSString *)strKey
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.key = [self URLEncodedString:strKey];
        self.httpMethod = kHttpMethodGet;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@", self.bucket];
        self.host = [NSMutableString stringWithFormat:@"http://%@.kss.ksyun.com/", self.bucket];
        
        //
        self.kSYResource = [NSString stringWithFormat:@"%@/%@?acl",self.kSYResource,_key];
        self.host = [NSMutableString stringWithFormat:@"%@%@?acl",self.host,_key];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    [super configureURLRequest];
    return self.urlRequest;
}
@end
