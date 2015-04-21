//
//  KSS3CreateBucketRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3CreateBucketRequest.h"
#import "KS3Constants.h"
#import "KS3BucketNameUtilities.h"
@implementation KS3CreateBucketRequest

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.httpMethod = kHttpMethodPut;
//        self.contentMd5 = @"";
//        self.contentType = @"";
//        self.kSYHeader = @"";
//        self.kSYResource = @"";
//        self.host = @"";
//    }
//    return self;
//}
- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = [self URLEncodedString:bucketName];
        self.httpMethod = kHttpMethodPut;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@/", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com", bucketName];
    }
    return self;
}
//- (KS3URLRequest *)configureURLRequest
//{
//    self.kSYResource = [NSString stringWithFormat:@"%@/%@",self.kSYResource,self.bucket];
//    [super configureURLRequest];
//    return self.urlRequest;
//}
- (KS3ClientException *)validate
{
    KS3ClientException *clientException = [super validate];
    if (!clientException) {
        clientException = [KS3BucketNameUtilities validateBucketName:self.bucket];
    }
    return clientException;
}

@end
