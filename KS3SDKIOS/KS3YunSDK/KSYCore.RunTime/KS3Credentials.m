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
    }
    
    return self;
}

- (id)initWithAccessKey:(NSString *)theAccessKey withSecretKey:(NSString *)theSecretKey withSecurityToken:(NSString *)theSecurityToken
{
    self = [super init];
    if (self) {
        _accessKey = theAccessKey;
        _secretKey = theSecretKey;
        _securityToken = theSecurityToken;
        
    }
    return self;
}

@end
