//
//  KSS3SetACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@class KSS3AccessControlList;
@interface KSS3SetACLRequest : KSS3Request
@property (strong, nonatomic) KSS3AccessControlList *acl;
- (instancetype)initWithName:(NSString *)bucketName;

@end
