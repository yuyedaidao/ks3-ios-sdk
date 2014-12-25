//
//  KingSoftServiceRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KingSoftCredentials.h"
#import "KingSoftURLRequest.h"
@class KingSoftServiceResponse;
@protocol  KingSoftServiceRequestDelegate;
@interface KingSoftServiceRequest : NSObject

@property (strong, nonatomic) KingSoftCredentials *credentials;

@property (strong, nonatomic) KingSoftURLRequest *urlRequest;

@property (strong, nonatomic) NSString *httpMethod;
@property (strong, nonatomic) NSURLConnection *urlConnection;

@property (strong, readonly, nonatomic) NSURL  *url;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *contentMd5;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSString *kSYHeader;
@property (strong, nonatomic) NSString *kSYResource;

@property (weak, nonatomic) id<KingSoftServiceRequestDelegate> delegate;
-(KingSoftURLRequest *)configureURLRequest;
- (void)composeHost;
- (void)sign;
- (void)cancel;
@end

@protocol KingSoftServiceRequestDelegate <NSObject>

@optional


-(void)request:(KingSoftServiceRequest *)request didReceiveResponse:(NSURLResponse *)response;


-(void)request:(KingSoftServiceRequest *)request didReceiveData:(NSData *)data;



-(void)request:(KingSoftServiceRequest *)request didCompleteWithResponse:(KingSoftServiceResponse *)response;


-(void)request:(KingSoftServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite;


-(void)request:(KingSoftServiceRequest *)request didFailWithError:(NSError *)error;


-(void)request:(KingSoftServiceRequest *)request didFailWithServiceException:(NSException *)exception __attribute__((deprecated));

@end

