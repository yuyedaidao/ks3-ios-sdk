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
    }
    return self;
}

@end
