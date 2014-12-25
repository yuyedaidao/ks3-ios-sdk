//
//  KSS3BucketACLResult.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSS3Owner.h"
#import "KSS3Grant.h"

@interface KSS3BucketACLResult : NSObject
@property (strong, nonatomic) KSS3Owner *owner;
@property (strong, nonatomic) NSMutableArray *accessControlList;
@end
