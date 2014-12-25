//
//  KSS3HeadBucketRequest.h
//  KS3YunSDK
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//
#import "KSS3Request.h"
@interface KSS3HeadBucketRequest : KSS3Request
- (instancetype)initWithName:(NSString *)bucketName;
@end
