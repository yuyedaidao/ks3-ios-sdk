//
//  KSS3MultipartUpload.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Owner.h"

@interface KS3MultipartUpload : NSObject


@property (nonatomic, strong) NSString *key;


@property (nonatomic, strong) NSString *bucket;


@property (nonatomic, strong) NSString *uploadId;

@property (nonatomic, strong) NSString *storageClass;

@property (nonatomic, strong) KS3Owner *initiator;


@property (nonatomic, strong) KS3Owner *owner;


@property (nonatomic, strong) NSDate *initiated;

@property (assign, nonatomic) BOOL isCanceled;
@end
