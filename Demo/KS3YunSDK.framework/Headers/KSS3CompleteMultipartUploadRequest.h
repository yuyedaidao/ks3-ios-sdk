//
//  KSS3CompleteMultipartUploadRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"
#import "KSS3MultipartUpload.h"
@interface KSS3CompleteMultipartUploadRequest : KSS3Request
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSData *dataParts;
-(id)initWithMultipartUpload:(KSS3MultipartUpload *)multipartUpload;
-(void)addPartWithPartNumber:(int)partNumber withETag:(NSString *)etag;
-(NSData *)requestBody;
@end
