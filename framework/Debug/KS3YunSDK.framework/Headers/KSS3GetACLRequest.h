//
//  KSS3BucketACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3GetACLRequest : KSS3Request
- (instancetype)initWithName:(NSString *)bucketName;
@end