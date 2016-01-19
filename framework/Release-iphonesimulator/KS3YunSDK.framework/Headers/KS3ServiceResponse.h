//
//  KingSoftServiceResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3ClientException.h"
#import "KSYLogClient.h"

@class KS3ServiceRequest;

#define ReponseLog(log)	    if ([self.delegate respondsToSelector:@selector(responseLog:)]) {\
[self.delegate responseLog:log];\
}

@protocol KS3ServiceResponseDelegate <NSObject>

- (void)responseLog:(NSString *)log;

- (void)connectionFailWithError:(NSError *)error;
@end
@interface KS3ServiceResponse : NSObject
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

@property (strong, nonatomic) KS3ClientException *exception;

@property (nonatomic, strong) KS3ServiceRequest *request;

@property (assign, nonatomic) NSInteger rateInteger;
@property (nonatomic, weak)id <KS3ServiceResponseDelegate> delegate;
@property (nonatomic, copy)NSString *outsideIP;

- (void)timeout;

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError;

@end
