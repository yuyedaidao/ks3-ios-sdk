//
//  KingSoftServiceResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceResponse.h"
#import "KS3ServiceRequest.h"
#import "KS3PutObjectRequest.h"
#import "KS3Client.h"
#import "KS3LogModel.h"
#import "KSYHardwareInfo.h"
#import "KSYLogManager.h"
#import "KS3ErrorHandler.h"
#import "KS3InitiateMultipartUploadRequest.h"
#import "KS3UploadPartRequest.h"
#import "KS3ListPartsRequest.h"
#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3AbortMultipartUploadRequest.h"
#import "KSYMacroDefinition.h"
#import "LGSocketServe.h"
#import <resolv.h>
#include <arpa/inet.h>


#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>

@interface KS3ServiceResponse ()<KSYLogClientDelegate,SocketDelegate>
{
    NSTimeInterval _startTime;
}
@end
@implementation KS3ServiceResponse

-(NSData *)body
{
    return [NSData dataWithData:body];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    ReponseLog(@"didReceiveResponse");
    if (self.request.logModel.Log_first_data_time == nil) {
        self.request.logModel.Log_first_data_time = [KSYHardwareInfo getCurrentTime];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    // setting response header to use it in shouldRetry method of AmazonAbstractWebServiceClient
    _responseHeader = [httpResponse allHeaderFields];
    NSLog(@"Response Headers:");
//    for (NSString *header in [[httpResponse allHeaderFields] allKeys]) {
//        NSLog(@"%@ = [%@]", header, [[httpResponse allHeaderFields] valueForKey:header]);
//    }
    self.httpStatusCode = (int32_t)[httpResponse statusCode];
    NSString *code = [NSString stringWithFormat:@"httpCode is %@",@(self.httpStatusCode)];
    ReponseLog(code);
    [body setLength:0];
    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.request.delegate request:self.request didReceiveResponse:response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    ReponseLog(@"didReceiveData");

    if (nil == body) {
        body = [NSMutableData data] ;
    }
    [body appendData:data];
    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
        [self.request.delegate request:self.request didReceiveData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ReponseLog(@"connectionDidFinishLoading");
    NSLog(@"host is %@",self.request.host);
    NSString *host  = [NSString stringWithFormat:@"host is %@",self.request.host];
    NSString *requestId = [NSString stringWithFormat:@"request_id is %@",_responseHeader[@"x-kss-request-id"]];
    ReponseLog(host);
    ReponseLog(requestId);

    self.request.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.request.logModel.Log_response_size = body.length;
    self.request.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];
    _isFinishedLoading = YES;
    [self processBody];
    if (_request.delegate && [_request.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [_request.delegate request:self.request didCompleteWithResponse:nil];
    }
    
    KS3ErrorHandler *errorHandler = [[KS3ErrorHandler alloc] initWithStatusCode:self.httpStatusCode];

    if (self.httpStatusCode == 301 || self.httpStatusCode >= 400) {
        NSXMLParser *parse = [[NSXMLParser alloc] initWithData:self.body];
        [parse setDelegate:errorHandler];
        [parse parse];
        [errorHandler exception];
        [errorHandler convertKS3Error];
        self.exception = errorHandler.exception;
        ReponseLog(errorHandler.exception.message);
    }
    self.request.logModel.ksyErrorcode = errorHandler.exception.statusCode;
    NSString *code = [NSString stringWithFormat:@"httpCode is %@",@(self.httpStatusCode)];
    ReponseLog(code);

    NSString *ip = [NSString stringWithFormat:@"ip address is %@",self.request.logModel.Log_target_ip];
    ReponseLog(ip);


    if (([KS3Client initialize].totalRequestCount%[KS3Client initialize].recordRate) == 0 || [KS3Client initialize].totalRequestCount == 1) {
//        [KSYLogManager senNSLogData:self.request.logModel];
        
        KSYLogClient *logClient = [[KSYLogClient alloc] init];
        logClient.delegate = self;
        logClient.outsideIP = self.outsideIP;
        [logClient insertLog:self.request.logModel];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
    ReponseLog(@"connection didFail");

    if (self.request.logModel.Log_target_ip) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            LGSocketServe *socketServe = [LGSocketServe sharedSocketServe];
            socketServe.delegate = self;
            [socketServe cutOffSocket];
            socketServe.socket.userData = SocketOfflineByServer;
            socketServe.ipAddress = self.request.logModel.Log_target_ip;
            
            [socketServe startConnectSocket];
            [socketServe sendMessage:@"hello"];
            
        });
        NSString *ip = [NSString stringWithFormat:@"ip address is %@",self.request.logModel.Log_target_ip];
        ReponseLog(ip);

    }
    


    NSString *failUrl = [NSString stringWithFormat:@"failUrl is %@",self.request.host];
    ReponseLog(failUrl);
    if ([self.delegate respondsToSelector:@selector(connectionFailWithError:url:)]) {
        [self.delegate connectionFailWithError:theError url:self.request.host];
    }
    NSString *errorCode = [NSString stringWithFormat:@"error code is %@",@(theError.code)];
    ReponseLog(errorCode);

    self.request.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];
    self.request.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.request.logModel.Log_response_size = body.length;
    self.request.logModel.ksyErrorcode = [theError code];
    _isFinishedLoading = YES;
    NSDictionary *info = [theError userInfo];
    NSLog(@"[theError userInfo] -----%@",info);
    NSString *errorInfo = [NSString stringWithFormat:@"errorInfo is %@",[theError userInfo]];
    ReponseLog(errorInfo);

    self.request.logModel.ksyErrorcode = [theError code];
    self.error = theError;
    if (self.request.delegate) { // **** 如果人为的为除了Put object, multipart upload object之外的API请求设置了delegate，也不会重试，这只针对这几个特定的请求有效
        if ([theError code] == -1003 || [theError code] == -1001 || [theError code] == -1006) {
            if (1) {
                if ([self.request isMemberOfClass:[KS3PutObjectRequest class]]) {
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3PutObjectRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3PutObjectRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] putObject:(KS3PutObjectRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                }else if ([self.request isMemberOfClass:[KS3InitiateMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3InitiateMultipartUploadRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3InitiateMultipartUploadRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] initiateMultipartUploadWithRequest:(KS3InitiateMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3UploadPartRequest class]]){
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3UploadPartRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3UploadPartRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] uploadPart:(KS3UploadPartRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3ListPartsRequest class]]){
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3ListPartsRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3ListPartsRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] listParts:(KS3ListPartsRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3CompleteMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3CompleteMultipartUploadRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3CompleteMultipartUploadRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] completeMultipartUpload:(KS3CompleteMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3AbortMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        ReponseLog(@"KS3AbortMultipartUploadRequest 自己设定delegate，并重试");

                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3AbortMultipartUploadRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] abortMultipartUpload:(KS3AbortMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:
                           [KS3PutObjectRequest class]]){ // **** 写重复了
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host withBucketName:[(KS3PutObjectRequest *)reTryRequest bucket]];
                        [[KS3Client initialize] putObject:(KS3PutObjectRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }
            }
            
        }else{
            if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                [self.request.delegate request:self.request didFailWithError:theError];
            }
        }
        
    }
    
    if (([KS3Client initialize].totalRequestCount%[KS3Client initialize].recordRate) == 0 || [KS3Client initialize].totalRequestCount == 1) {
        
//        [KSYLogManager senNSLogData:self.request.logModel];
        
        KSYLogClient *logClient = [[KSYLogClient alloc] init];
        logClient.delegate = self;
        logClient.outsideIP = self.outsideIP;
        [logClient insertLog:self.request.logModel];
    }
    
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    ReponseLog(@"didSendBodyData");

    if ([self.request.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.request.delegate request:self.request
                           didSendData:(long long)bytesWritten
                     totalBytesWritten:(long long)totalBytesWritten
             totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite];
    }
}

// When a request gets a redirect due to the bucket being in a different region,
// The request gets re-written with a GET http method. This is to set the method back to
// the appropriate method if necessary
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)proposedRequest redirectResponse:(NSURLResponse *)redirectResponse
{
    ReponseLog(@"willSendRequest");

    return proposedRequest;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)processBody
{
    
}
- (void)timeout
{
    NSLog(@"timeout!!!");
}

#pragma mark- logClientDelegate

- (void)logCilentLog:(NSString *)log
{
    ReponseLog(log);

}

- (void)socketDidDisconnect:(AsyncSocket *)sock
{
    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
    NSString *useTime = [NSString stringWithFormat:@"重新连接iP时间%f",end - _startTime];
    ReponseLog(useTime);

}
- (void)socket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    ReponseLog(@"重连IP失败");
}
- (void)socket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    ReponseLog(@"重连IP成功");

}


@end
