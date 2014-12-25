//
//  KSS3ListBucketsResult.h
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSS3Owner;

@interface KSS3ListBucketsResult : NSObject

@property (nonatomic, strong) KSS3Owner *owner;
@property (nonatomic, strong) NSMutableArray *buckets;

@end
