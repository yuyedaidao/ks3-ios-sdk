//
//  KSS3SetObjectGrantACLRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KSS3Request.h"

@class KSS3GrantAccessControlList;

@interface KSS3SetObjectGrantACLRequest : KSS3Request

@property (nonatomic, strong) KSS3GrantAccessControlList *acl;
@property (nonatomic, strong) NSString *key;

- (instancetype)initWithName:(NSString *)bucketName;

@end
