//
//  KS3Util.h
//  KS3iOSSDKDemo
//
//  Created by JackWong on 15/4/24.
//  Copyright (c) 2015年 Blues. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KS3Request;

extern NSString *const strLogTestAccessKey;
extern NSString *const strLogTestSecretKey;
@interface KS3Util : NSObject
+ (NSString *)getAuthorization:(KS3Request *)request;

+ (NSString *)KSYAuthorizationWithHTTPVerb:(NSString *)accessKey
                                 secretKey:(NSString *)secretKey
                                  httpVerb:(NSString *)httpVerb
                                contentMd5:(NSString *)strContentMd5
                               contentType:(NSString *)strContentType
                                      date:(NSString   *)date
                    canonicalizedKssHeader:(NSString *)strHeaders
                     canonicalizedResource:(NSString *)strResource;

@end
