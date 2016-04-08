//
//  KSS3MultipartUpload.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Owner.h"

//上传类型
typedef enum {
    kUploadAlasset = 0,  //相册中
   kUploadNormal ,    //沙盒里或工程里
}UploadType;

@interface KS3MultipartUpload : NSObject


@property (nonatomic, strong) NSString *key;


@property (nonatomic, strong) NSString *bucket;


@property (nonatomic, strong) NSString *uploadId;

@property (nonatomic, strong) NSString *storageClass;

@property (nonatomic, strong) KS3Owner *initiator;


@property (nonatomic, strong) KS3Owner *owner;


@property (nonatomic, strong) NSDate *initiated;

@property (assign, nonatomic) BOOL isCanceled;
@property (assign,nonatomic) UploadType uploadType;
@end
