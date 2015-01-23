//
//  KingSoftCredentials.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Credentials.h"

@implementation KS3Credentials

- (id)initWithAccessKey:(NSString *)accessKey withSecretKey:(NSString *)secretKey
{
    self = [super init];
    if (self) {
        _accessKey = accessKey;
        _secretKey = secretKey;
        _securityToken = nil;
        NSLog(@"##### 采用本地AK/SK签名的方式!#####");
    }
    return self;
}

- (id)initWithSecurityToken:(NSString *)theSecurityToken
{
    self = [super init];
    if (self) {
        _accessKey = nil;
        _secretKey = nil;
        _securityToken = theSecurityToken;
        NSLog(@"##### 采用服务器端Token签名的方式!#####");
    }
    return self;
}

@end
