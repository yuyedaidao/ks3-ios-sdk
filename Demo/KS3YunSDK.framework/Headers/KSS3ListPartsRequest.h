//
//  KSS3ListPartsRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"
#import "KSS3MultipartUpload.h"

@interface KSS3ListPartsRequest : KSS3Request

@property (strong, nonatomic) NSString *key;

@property (nonatomic, strong) NSString *uploadId;


@property (nonatomic, assign) int32_t maxParts;


@property (nonatomic, assign) int32_t partNumberMarker;


-(id)initWithMultipartUpload:(KSS3MultipartUpload *)multipartUpload;
@end
