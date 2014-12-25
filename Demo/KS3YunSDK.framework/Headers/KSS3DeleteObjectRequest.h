//
//  KSS3DeleteObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3DeleteObjectRequest : KSS3Request

@property (nonatomic, strong) NSString *key;
- (instancetype)initWithName:(NSString *)bucketName;
@end
