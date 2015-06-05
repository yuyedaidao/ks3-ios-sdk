//
//  KS3ErrorHandler.h
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYUnmarshallerXMLParserDelegate.h"
#import "KS3ClientException.h"

extern NSString *const KS3iOSSDKServiceErrorDomain;
extern NSString *const KS3iOSSDKClientErrorDomain;

@interface KS3ErrorHandler : KSYUnmarshallerXMLParserDelegate

@property (nonatomic, strong) KS3ClientException *exception;

- (id)initWithStatusCode:(int32_t)statusCode;
+ (void)shouldThrowExceptions __attribute__((deprecated));
+ (void)shouldNotThrowExceptions;
+ (BOOL)throwsExceptions;
+ (NSError *)errorFromExceptionWithThrowsExceptionOption:(NSException *)exception;
+ (NSError *)errorFromException:(NSException *)exception;
+ (NSError *)errorFromException:(NSException *)exception serviceErrorDomain:(NSString *)serviceErrorDomain clientErrorDomain:(NSString *)clientErrorDomain;
- (void)convertKS3Error;
@end
