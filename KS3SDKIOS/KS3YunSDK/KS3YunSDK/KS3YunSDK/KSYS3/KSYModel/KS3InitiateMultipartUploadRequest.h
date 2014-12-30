//
//  KSS3InitiateMultipartUploadRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3AbstractPutRequest.h"

@interface KS3InitiateMultipartUploadRequest : KS3AbstractPutRequest

-(id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket;

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) NSString *cacheControl;


@property (nonatomic, strong) NSString *contentDisposition;


@property (nonatomic, strong) NSString *contentEncoding;

@property (nonatomic, strong) NSString *redirectLocation;


@property (nonatomic, readonly) int32_t expires;

@end
