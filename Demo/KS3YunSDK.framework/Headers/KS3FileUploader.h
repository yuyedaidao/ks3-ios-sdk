//
//  KSS3FileUploader.h
//  KSYSDKDemo
//
//  Created by Blues on 12/24/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KS3FileUploader;

typedef void(^KS3UploadProgressChangedBlock)(KS3FileUploader *uploader, double progress);
typedef void(^KS3UploadCompleteBlock)(KS3FileUploader *uploader);
typedef void(^KS3UploadFailedBloack)(KS3FileUploader *uploader, NSString *strUploadId, NSInteger partNumber, NSError *error);

@interface KS3FileUploader : NSObject

@property (nonatomic, strong) NSString *strFilePath;
@property (nonatomic, strong) NSString *strKey;
@property (nonatomic, assign) double  partSize; // **** unit: MB
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, strong) NSString *callbackBody;
@property (nonatomic, strong) NSDictionary *callbackParams;

- (instancetype)initWithBucketName:(NSString *)strBucketName;
- (void)startUploadWithProgressChangeBlock:(KS3UploadProgressChangedBlock)uploadProgressChangedBlock
                    completeBlock:(KS3UploadCompleteBlock)uploadCompleteBlock
                      failedBlock:(KS3UploadFailedBloack)uploadFailedBlock;

@end
