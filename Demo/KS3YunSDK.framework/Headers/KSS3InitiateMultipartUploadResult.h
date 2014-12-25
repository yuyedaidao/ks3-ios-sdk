//
//  KSS3InitiateMultipartUploadResult.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSS3MultipartUpload.h"

@interface KSS3InitiateMultipartUploadResult : NSObject
@property (strong, nonatomic) KSS3MultipartUpload *multipartUpload;
@end
