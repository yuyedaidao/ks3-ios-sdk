//
//  KSS3PutObjectRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3PutObjectRequest.h"
#import "KS3Constants.h"
#import "KS3SDKUtil.h"

@implementation KS3PutObjectRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = nil;
        self.contentType = @"application/octet-stream";
        self.kSYHeader = @"";
        self.generateMD5 = YES;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com", bucketName];
    }
    return self;
}

- (KS3URLRequest *)configureURLRequest
{
    [self.urlRequest setHTTPBody:_data];
    [self.urlRequest setValue:self.contentType forHTTPHeaderField:kKSHttpHdrContentType];
    
    // **** 一定要先设置callbackbody，再设置callbackurl才可以签名成功
    if (nil != _callbackBody && nil != _callbackUrl) {
        self.kSYHeader = [@"x-kss-callbackbody:" stringByAppendingString:_callbackBody];
        self.kSYHeader = [self.kSYHeader stringByAppendingFormat:@"\n"];
        [self.urlRequest setValue:_callbackBody forHTTPHeaderField:@"x-kss-callbackbody"];
        
        NSString *callbackUrl = [@"x-kss-callbackurl:" stringByAppendingString:_callbackUrl];
        self.kSYHeader = [self.kSYHeader stringByAppendingFormat:@"%@\n", callbackUrl];
        [self.urlRequest setValue:_callbackUrl forHTTPHeaderField:@"x-kss-callbackurl"];
        
        // **** 回调的自定义参数
        if (nil != _callbackParams) {
            for (NSString *strKey in _callbackParams.allKeys) {
                if (strKey.length >= 4 && [[strKey substringToIndex:4] isEqualToString:@"kss-"] == YES) {
                    [self.urlRequest setValue:_callbackParams[strKey] forHTTPHeaderField:strKey];
                }
                else {
                    NSLog(@"The header with field: \"%@\" and value: \"%@\" is not cocrect, this header will be ingored", strKey, _callbackParams[strKey]);
                }
            }
        }
    }
    if (nil == self.contentMd5 && YES == self.generateMD5 && self.data != nil) {
        self.contentMd5 = [KS3SDKUtil base64md5FromData:self.data];
    }
    
    [self.urlRequest setValue:self.contentMd5 forHTTPHeaderField:kKS3HttpHdrContentMD5];
    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,_filename];
    self.host = [NSString stringWithFormat:@"%@/%@",self.host,_filename];
    [super configureURLRequest];
    return self.urlRequest;
}

@end
