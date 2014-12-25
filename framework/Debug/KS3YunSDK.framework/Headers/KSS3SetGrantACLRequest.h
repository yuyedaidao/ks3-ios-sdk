//
//  KSS3SetGrantACLRequest.h
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/18/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "KSS3Request.h"

@class KSS3GrantAccessControlList;

@interface KSS3SetGrantACLRequest : KSS3Request

@property (nonatomic, strong) KSS3GrantAccessControlList *acl;

- (instancetype)initWithName:(NSString *)bucketName;

@end
