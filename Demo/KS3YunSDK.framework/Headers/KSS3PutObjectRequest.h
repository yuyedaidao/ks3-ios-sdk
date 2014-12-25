//
//  KSS3PutObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3PutObjectRequest : KSS3Request

@property (nonatomic, strong) NSString *cacheControl;


@property (nonatomic, strong) NSString *contentDisposition;


@property (nonatomic, strong) NSString *contentEncoding;

@property (nonatomic, strong) NSString *contentMD5;


@property (nonatomic, assign) BOOL generateMD5;


@property (nonatomic, strong) NSString *expect;


@property (nonatomic, strong) NSData *data;


@property (nonatomic, strong) NSInputStream *stream;

@property (nonatomic, assign, readonly) int32_t expires;

@property (nonatomic, strong) NSString *filename;


@property (nonatomic, strong) NSString *redirectLocation;

- (instancetype)initWithName:(NSString *)bucketName;

@end
