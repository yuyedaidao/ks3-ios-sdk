//
//  KSS3CompleteMultipartUploadResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
#import "KSS3CompleteMultipartUploadResult.h"

@interface KSS3CompleteMultipartUploadResponse : KSS3Response
@property (nonatomic, readonly) KSS3CompleteMultipartUploadResult *completeMultipartUploadResult;
@end
