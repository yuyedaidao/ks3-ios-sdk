//
//  KSS3BucketACLResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
@class KSS3BucketACLResult;
@interface KSS3GetACLResponse : KSS3Response

@property (nonatomic, strong) KSS3BucketACLResult *listBucketsResult;
@end
