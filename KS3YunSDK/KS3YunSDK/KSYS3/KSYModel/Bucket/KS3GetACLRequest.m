//
//  KSS3BucketACLRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetACLRequest.h"
#import "KS3Client.h"
#import "KS3Constants.h"
@implementation KS3GetACLRequest

- (instancetype)initWithName:(NSString *)bucketName {
  self = [super init];
  if (self) {
    self.bucket = [self URLEncodedString:bucketName];
    self.httpMethod = kHttpMethodGet;
    self.contentMd5 = @"";
    self.kSYResource = [NSString stringWithFormat:@"/%@/?acl", self.bucket];
    self.host = [NSString
        stringWithFormat:@"%@://%@.%@/?acl",
                         [[KS3Client initialize] requestProtocol], self.bucket,
                         [[KS3Client initialize] getBucketDomain]];
  }
  return self;
}
@end
