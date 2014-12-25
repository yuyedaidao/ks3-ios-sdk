//
//  S3ListBucketsResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
@class KSS3ListBucketsResult;
@interface KSS3ListBucketsResponse : KSS3Response

@property (nonatomic, strong) KSS3ListBucketsResult *listBucketsResult;
@end
