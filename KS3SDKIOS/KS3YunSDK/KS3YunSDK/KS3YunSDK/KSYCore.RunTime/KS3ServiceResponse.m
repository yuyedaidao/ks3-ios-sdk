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

@implementation KS3ServiceResponse

-(NSData *)body
{
    return [NSData dataWithData:body];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
    [body setLength:0];
    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.request.delegate request:self.request didReceiveResponse:response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
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
    self.request.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.request.logModel.Log_response_size = body.length;
    self.request.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];
    _isFinishedLoading = YES;
    [self processBody];
    if (_request.delegate && [_request.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [_request.delegate request:self.request didCompleteWithResponse:nil];
    }
    
    if (self.httpStatusCode == 301 || self.httpStatusCode >= 400) {
        NSXMLParser *parse = [[NSXMLParser alloc] initWithData:self.body];
        KS3ErrorHandler *errorHandler = [[KS3ErrorHandler alloc] initWithStatusCode:self.httpStatusCode];
        [parse setDelegate:errorHandler];
        [parse parse];
        [errorHandler exception];
        [errorHandler convertKS3Error];
        self.exception = errorHandler.exception;
        self.request.logModel.ksyErrorcode = errorHandler.exception.statusCode;
        
    }
    
    if (([KS3Client initialize].totalRequestCount%[KS3Client initialize].recordRate) == 0 || [KS3Client initialize].totalRequestCount == 1) {
        [KSYLogManager sendLogData:self.request.logModel];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
    self.request.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];
    self.request.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.request.logModel.Log_response_size = body.length;
    self.request.logModel.ksyErrorcode = [theError code];
    _isFinishedLoading = YES;
    NSDictionary *info = [theError userInfo];
    NSLog(@"[theError userInfo] -----%@",info);
    self.request.logModel.ksyErrorcode = [theError code];
    self.error = theError;
    if (self.request.delegate) {
        if ([theError code] == -1003) {
            if ([[theError localizedDescription] hasPrefix:@"A server with the specified hostname could not be found"]) {
                if ([self.request isMemberOfClass:[KS3PutObjectRequest class]]) {
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] putObject:(KS3PutObjectRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                }else if ([self.request isMemberOfClass:[KS3InitiateMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] initiateMultipartUploadWithRequest:(KS3InitiateMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3UploadPartRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] uploadPart:(KS3UploadPartRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3ListPartsRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] listParts:(KS3ListPartsRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3CompleteMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] completeMultipartUpload:(KS3CompleteMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:[KS3AbortMultipartUploadRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
                        [[KS3Client initialize] abortMultipartUpload:(KS3AbortMultipartUploadRequest *)reTryRequest];
                        self.request.reTry = YES;
                    }else{
                        if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                            [self.request.delegate request:self.request didFailWithError:theError];
                        }
                    }
                    
                }else if ([self.request isMemberOfClass:
                           [KS3PutObjectRequest class]]){
                    if (!self.request.reTry) {
                        KS3ServiceRequest *reTryRequest = self.request;
                        [reTryRequest vHostToVPath:reTryRequest.host];
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
        
        [KSYLogManager sendLogData:self.request.logModel];
    }
    
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
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
    
}

@end
