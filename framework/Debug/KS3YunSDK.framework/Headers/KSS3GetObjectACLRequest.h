//
//  KSS3GetObjectACLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Request.h"

@interface KSS3GetObjectACLRequest : KSS3Request

@property (strong, nonatomic) NSString *key;
- (instancetype)initWithName:(NSString *)bucketName;
@end
