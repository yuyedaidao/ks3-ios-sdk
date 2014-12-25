//
//  KingSoftServiceResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KingSoftServiceRequest;
@interface KingSoftServiceResponse : NSObject
{
    NSMutableData        *body;
}
@property (nonatomic, readonly) NSData *body;
@property (nonatomic, readonly) BOOL isFinishedLoading;
@property (nonatomic, readonly) BOOL didTimeout;
@property (nonatomic, strong) NSDictionary *responseHeader;
@property (nonatomic) int32_t httpStatusCode;

@property (readonly, copy) NSURL *URL;


@property (readonly, copy) NSString *MIMEType;


@property (readonly) long long expectedContentLength;


@property (readonly, copy) NSString *textEncodingName;


@property (readonly, copy) NSString *suggestedFilename;
@property (strong, nonatomic) NSError *error;

@property (nonatomic, strong) KingSoftServiceRequest *request;
- (void)timeout;
@end
