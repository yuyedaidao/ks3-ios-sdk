//
//  KS3PutObjectCopyRequest.h
//  KSYSDKDemo
//
//  Created by Blues on 12/25/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3PutObjectCopyRequest : KS3Request

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *strSourceBucket;
@property (nonatomic, strong) NSString *strSourceObject;

- (instancetype)initWithName:(NSString *)bucketName;

@end
