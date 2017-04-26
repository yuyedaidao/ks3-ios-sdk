//
//  KSS3BucketACLResult.h
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Grant.h"
#import "KS3Owner.h"
#import <Foundation/Foundation.h>

@interface KS3BucketACLResult : NSObject
@property(strong, nonatomic) KS3Owner *owner;
@property(strong, nonatomic) NSMutableArray *accessControlList;
@end
