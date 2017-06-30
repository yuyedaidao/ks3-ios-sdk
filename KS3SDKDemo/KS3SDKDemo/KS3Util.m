//
//  KS3Util.m
//  KS3iOSSDKDemo
//
//  Created by JackWong on 15/4/24.
//  Copyright (c) 2015年 Blues. All rights reserved.
//

#import "KS3Util.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <KS3Request.h>
#import <KS3AuthUtils.h>
#import "AppDelegate.h"

@implementation KS3Util
+ (NSString *)getAuthorization:(KS3Request *)request
{
    return [KS3AuthUtils KSYAuthorizationWithAccessKey:strAccessKey
                                             secretKey:strSecretKey
                                              httpVerb:request.httpMethod
                                            contentMd5:request.contentMd5
                                           contentType:request.contentType
                                               strDate:request.strDate
                                canonicalizedKssHeader:request.kSYHeader
                                 canonicalizedResource:request.kSYResource];
}

+ (NSData *)dataWithSize:(NSUInteger)size {
    return [[NSMutableData dataWithLength:size] copy];
}

@end
