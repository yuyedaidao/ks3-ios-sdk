//
//  KSS3AbortMultipartUploadRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KSS3Request.h"
#import "KSS3MultipartUpload.h"

@interface KSS3AbortMultipartUploadRequest : KSS3Request

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *uploadId;

- (instancetype)initWithName:(NSString *)bucketName;
- (id)initWithMultipartUpload:(KSS3MultipartUpload *)multipartUpload;

@end
