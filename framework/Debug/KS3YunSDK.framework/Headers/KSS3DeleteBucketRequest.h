//
//  KSS3DeleteBucketRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3DeleteBucketRequest : KSS3Request

- (instancetype)initWithName:(NSString *)bucketName;
@end
