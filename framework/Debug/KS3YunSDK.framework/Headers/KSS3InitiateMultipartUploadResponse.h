//
//  KSS3InitiateMultipartUploadResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
#import "KSS3MultipartUpload.h"

@interface KSS3InitiateMultipartUploadResponse : KSS3Response
@property (nonatomic, strong) KSS3MultipartUpload *multipartUpload;
@end
