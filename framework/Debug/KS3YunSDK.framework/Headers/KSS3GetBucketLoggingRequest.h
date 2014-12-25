//
//  KSS3GetBucketLoggingRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3GetBucketLoggingRequest : KSS3Request
@property (nonatomic, strong) NSString *prefix;

@property (nonatomic, strong) NSString *marker;

@property (nonatomic) int32_t maxKeys;

@property (nonatomic, retain) NSString *delimiter;

- (instancetype)initWithName:(NSString *)bucketName;
@end
