//
//  KSS3GetObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3GetObjectRequest : KS3Request


@property (nonatomic, assign) int64_t rangeStart;


@property (nonatomic, assign) int64_t rangeEnd;

@property (nonatomic, strong) NSDate *ifModifiedSince;


@property (nonatomic, strong) NSDate *ifUnmodifiedSince;


@property (nonatomic, strong) NSString *ifMatch;


@property (nonatomic, strong) NSString *versionId;


@property (nonatomic, strong) NSString *ifNoneMatch;
- (instancetype)initWithName:(NSString *)bucketName;

@end
