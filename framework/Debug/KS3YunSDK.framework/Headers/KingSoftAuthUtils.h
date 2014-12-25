//
//  KingSoftAuthUtils.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KingSoftAuthUtils.h"
typedef enum{
    KSS3_HTTPVerbGet,
    KSS3_HTTPVerbPost,
    KSS3_HTTPVerbPut,
    KSS3_HTTPVerbDelete,
    KSS3_HTTPVerbHead,
} KSS3_HTTPVerbType;

@class KingSoftServiceRequest;
@class KingSoftCredentials;
@class KingSoftURLRequest;

@interface KingSoftAuthUtils : NSObject

+ (NSString *)strAuthorizationWithHTTPVerb:(NSString *)accessKey
                                 secretKey:(NSString *)secretKey
                                  httpVerb:(KSS3_HTTPVerbType)httpVerb
                                contentMd5:(NSString *)strContentMd5
                               contentType:(NSString *)strContentType
                                      date:(NSDate   *)date
                    canonicalizedKssHeader:(NSString *)strHeaders
                     canonicalizedResource:(NSString *)strResource;

+ (NSString *)strDateWithDate:(NSDate *)date andType:(NSString *)strType;

+ (void)signRequestV4:(KingSoftServiceRequest *)serviceRequest urlRequest:(KingSoftURLRequest *)urlRequest headers:(NSMutableDictionary *)headers payload:(NSString *)payload credentials:(KingSoftCredentials *)credentials;

@end
