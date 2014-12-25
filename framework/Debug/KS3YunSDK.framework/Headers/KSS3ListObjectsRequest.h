//
//  KSS3ListObjectsRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3ListObjectsRequest : KSS3Request

@property (nonatomic, strong) NSString *prefix;

@property (nonatomic, strong) NSString *marker;

@property (nonatomic) int32_t maxKeys;

@property (nonatomic, retain) NSString *delimiter;


- (instancetype)initWithName:(NSString *)bucketName;
@end
