//
//  KingSoftServiceRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceRequest.h"
#import "KS3AuthUtils.h"
#import "KS3ClientException.h"


@implementation KS3ServiceRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentMd5 = @"";
        _contentType = @"";
        _kSYHeader = @"";
        _kSYResource = @"";
        _host = @"";
        _urlRequest = [KS3URLRequest new];}
    return self;
}

- (void)sign
{
    [KS3AuthUtils signRequestV4:self urlRequest:_urlRequest headers:nil payload:nil credentials:_credentials];
}

- (KS3URLRequest *)configureURLRequest
{
    [self sign];
    return _urlRequest;
    
}
- (KS3ClientException *)validate
{
    return nil;
}
- (void)cancel
{
    [self.urlConnection cancel];
}


@end
