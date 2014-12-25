//
//  KSS3ListObjectsResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
@class KSS3ListObjectsResult;

@interface KSS3ListObjectsResponse : KSS3Response
@property (nonatomic, strong) KSS3ListObjectsResult *listBucketsResult;
@end
