//
//  MSDownLoad.m
//  MusicSample
//
//  Created by JackWong on 14-1-9.
//  Copyright (c) 2014年 JackWong. All rights reserved.
//

#import "KS3DownLoad.h"
#import "KS3SDKUtil.h"
#import "KS3Credentials.h"
#import "KS3AuthUtils.h"
#import "KS3Request.h"
#import "KS3Response.h"
#import "KS3Constants.h"
#import "KSYMacroDefinition.h"
#import "KS3ErrorHandler.h"
#import "KSYHardwareInfo.h"
@interface KS3DownLoad ()
{
    NSMutableData        *body;
}

@property (strong, nonatomic) KS3Credentials *credentials;
@property (nonatomic, strong) NSDictionary *responseHeader;

@end

@implementation KS3DownLoad {
}

@synthesize delegate;
@synthesize overwrite;
@synthesize url;
@synthesize fileName;
@synthesize filePath;
@synthesize fileSize;


-(NSData *)body
{
    return [NSData dataWithData:body];
}

- (id)initWithUrl:(NSString *)aUrl credentials:(KS3Credentials *)credentials :(NSString *)bucketName :(NSString *)objectKey
{
    self = [super init];
    if (self)
    {
        _credentials = credentials;
        url = aUrl;
        _requestDate = getCurrentDate();
        _strDate = [KS3AuthUtils strDateWithDate:_requestDate andType:@"GMT"];
        _contentMd5 = @"";
        _contentType = @"";
        _kSYHeader = @"";
        _kSYResource = @"";
        _strKS3Token = nil;
        _httpMethod = kHttpMethodGet;
        _bucketName = [self URLEncodedString:bucketName];
        _key = [self URLEncodedString:objectKey];
        _kSYResource = [NSString stringWithFormat:@"/%@/%@", _bucketName,_key];
        _logModel = [KS3LogModel new];
        _logModel.ksyErrorcode = -2;
        
    }
    return self;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    
    NSMutableString *output = [NSMutableString string];
    
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    
    int sourceLen = (int)strlen((const char *)source);
    
    for (int i = 0; i < sourceLen; ++i) {
        
        const unsigned char thisChar = source[i];
        
        if (thisChar == ' '){
            
            [output appendString:@"+"];
            
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   
                   (thisChar >= '0' && thisChar <= '9')) {
            
            [output appendFormat:@"%c", thisChar];
            
        } else {
            
            [output appendFormat:@"%%%02X", thisChar];
            
        }
        
    }
    
    return output;
    
}

- (NSString *)applicationDocumentFilePath
{
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}
- (void)start
{
    _isFinished = NO;
    if (!url)
    {
        if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"Url can not be nil!" code:110 userInfo:nil];
                [delegate downloadFaild:self didFailWithError:error];
        }
    }
    fileName = [url lastPathComponent];
//    if (!fileName)
//    {
//        NSString *urlStr = [url absoluteString];
//        fileName = [urlStr lastPathComponent];
//        if ([fileName length] > 32) fileName = [fileName substringFromIndex:[fileName length]-32];
//    }
    NSString *deletingPathExtension = [url MD5Hash];
    
    NSString *pathExtension = [url pathExtension];
    
    if (!filePath)
    {
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        filePath = documentsDir;
    }
    destinationPath=[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",deletingPathExtension,pathExtension]];
    
	temporaryPath=[filePath stringByAppendingPathComponent:deletingPathExtension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        if (overwrite)
        {
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
        }else
        {
            if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
                [delegate downloadProgressChange:self progress:1.0];
            }
            if (delegate && [delegate respondsToSelector:@selector(downloadFinished:filePath:)]) {
                [delegate downloadFinished:self filePath:destinationPath];
            }
            if (_downloadProgressChangeBlock) {
                _downloadProgressChangeBlock(self,1.0);
            }
            if (_downloadFileCompleteionBlock) {
                _downloadFileCompleteionBlock(self,destinationPath);
            }
            return;
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryPath])
    {
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:temporaryPath contents:nil attributes:nil];
        if (!createSucces)
        {
            if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"Temporary File can not be create!" code:111 userInfo:nil];
                [delegate downloadFaild:self didFailWithError:error];
            }
            if (_failedBlock) {
                NSError *error = [NSError errorWithDomain:@"Temporary File can not be create!" code:111 userInfo:nil];
                _failedBlock(self, error);
            }
            return;
        }
    }
    
    self.logModel.send_before_time = [KSYHardwareInfo getCurrentTime];

    [fileHandle closeFile];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:temporaryPath];
    offset = [fileHandle seekToEndOfFile];
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
    
    if (self.endPoint == nil) {
        self.endPoint = @"kss.ksyun.com";
    }
    NSString *strHost = [NSString stringWithFormat:@"http://%@.%@/%@", _bucketName,self.endPoint, _key];
    NSLog(@"strHost is %@",strHost);
  
    
    NSString *strAuthorization = @"";
    if (_credentials.accessKey != nil && _credentials.secretKey != nil) {
        strAuthorization = [KS3AuthUtils strAuthorizationWithHTTPVerb:_credentials.accessKey
                                                            secretKey:_credentials.secretKey
                                                             httpVerb:KSS3_HTTPVerbGet
                                                           contentMd5:@""
                                                          contentType:@""
                                                                 date:_requestDate
                                               canonicalizedKssHeader:@""
                                                canonicalizedResource:_kSYResource];
    }
    
    NSTimeInterval downloadTimeOut = _timeoutInterval;
    if (_timeoutInterval == 0 || _timeoutInterval < 0) {
        downloadTimeOut = 60;
    }
    NSURL *urlRequest = [NSURL URLWithString:strHost];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:downloadTimeOut];
    [request setHTTPMethod:@"GET"];
    [request setValue:_strDate forHTTPHeaderField:@"Date"];
    [request setValue:strAuthorization forHTTPHeaderField:@"Authorization"];
    [request addValue:range forHTTPHeaderField:@"Range"];
    
    // **** set token
    NSLog(@"====== start ======");
    if (_credentials == nil) {
        NSLog(@"====== _credentials is empty ======");
//        NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @"GET",  @"http_method",
//                                   @"",     @"content_md5",
//                                   @"",     @"content_type",
//                                   _strDate, @"date",
//                                   @"",     @"headers",
//                                   @"",     @"resource", nil];
        [request setValue:_strKS3Token forHTTPHeaderField:@"Authorization"];
    }

    [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:KSYS3DefaultRunLoopMode];

    [connection start];
    
    while (!_isFinished)
    {
        [[NSRunLoop currentRunLoop] runMode:KSYS3DefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

}

- (KS3Response *)startURLRequest:(NSMutableURLRequest *)urlRequest
                      KS3Request:(KS3Request *)request
                           token:(NSString *)strToken {
    if (strToken != nil) {
        [urlRequest setValue:strToken forHTTPHeaderField:@"Authorization"];
        [connection cancel];
        connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    }
    return nil;
}


- (void)stop
{
    [connection cancel];
    connection = nil;
    [fileHandle closeFile];
    fileHandle = nil;
    _isFinished = YES;
}

- (void)stopAndClear
{
    [self stop];
    [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil];
    
    
    
    if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
       [delegate downloadProgressChange:self progress:0];
    }
    if (_downloadProgressChangeBlock) {
        _downloadProgressChangeBlock(self,0.0);
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if (self.logModel.Log_first_data_time == nil) {
        self.logModel.Log_first_data_time = [KSYHardwareInfo getCurrentTime];
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.httpStatusCode = (int32_t)[httpResponse statusCode];
    self.responseHeader = [httpResponse allHeaderFields];

    if ([response expectedContentLength] != NSURLResponseUnknownLength)
        fileSize = (unsigned long long)[response expectedContentLength]+offset;
    if (delegate && [delegate respondsToSelector:@selector(downloadBegin:didReceiveResponseHeaders:)]) {
         [delegate downloadBegin:self didReceiveResponseHeaders:response];
    }
    if (_downloadBeginBlock) {
        _downloadBeginBlock(self, response);
    }
    [body setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{

    KS3ErrorHandler *errorHandler = [[KS3ErrorHandler alloc] initWithStatusCode:self.httpStatusCode];
    
    if (self.httpStatusCode == 301 || self.httpStatusCode >= 400) {
        NSXMLParser *parse = [[NSXMLParser alloc] initWithData:aData];
        [parse setDelegate:errorHandler];
        [parse parse];
        [errorHandler exception];
        [errorHandler convertKS3Error];
        NSError *error = [NSError errorWithDomain:errorHandler.exception.message code:self.httpStatusCode userInfo:nil];
        if (_failedBlock) {
            _failedBlock(self, error);
        }

        self.logModel.ksyErrorcode = errorHandler.exception.statusCode;

    }else {
        [fileHandle writeData:aData];
        offset = [fileHandle offsetInFile];
        double progress = offset*1.0/fileSize;
        if (_downloadProgressChangeBlock) {
            _downloadProgressChangeBlock(self,progress);
        }
        if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
            [delegate downloadProgressChange:self progress:progress];
        }

        if (body == nil) {
            body = [NSMutableData data];
        }
        [body appendData:aData];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    self.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];
    self.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.logModel.Log_response_size = body.length;
    self.logModel.ksyErrorcode = [error code];

    [fileHandle closeFile];
    

    if (_failedBlock) {
        _failedBlock(self, error);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
       [delegate downloadFaild:self didFailWithError:error];
    }
   
    if (([KS3Client initialize].totalRequestCount%[KS3Client initialize].recordRate) == 0 || [KS3Client initialize].totalRequestCount == 1) {
        
        //        [KSYLogManager senNSLogData:self.request.logModel];
        
        KSYLogClient *logClient = [[KSYLogClient alloc] init];
        logClient.outsideIP = self.outsideIP;
        [logClient insertLog:self.logModel];
    }

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    self.logModel.Log_response_time = [KSYHardwareInfo getCurrentTime];
    self.logModel.Log_response_size = body.length;
    self.logModel.log_RequestId = _responseHeader[@"x-kss-request-id"];

    _isFinished = YES;
    [fileHandle closeFile];
    if (self.httpStatusCode != 301 && self.httpStatusCode < 400) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSString *finishString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        NSLog(@"finishString is %@",finishString);
        
        [[NSFileManager defaultManager] moveItemAtPath:temporaryPath toPath:destinationPath error:nil];
        
        if (_downloadFileCompleteionBlock) {
            _downloadFileCompleteionBlock(self, destinationPath);
        }
        if (delegate && [delegate respondsToSelector:@selector(downloadFinished:filePath:)]) {
            [delegate downloadFinished:self filePath:destinationPath];
        }

    }
    
    if (([KS3Client initialize].totalRequestCount%[KS3Client initialize].recordRate) == 0 || [KS3Client initialize].totalRequestCount == 1) {
        
        //        [KSYLogManager senNSLogData:self.request.logModel];
        
        KSYLogClient *logClient = [[KSYLogClient alloc] init];
        logClient.outsideIP = self.outsideIP;
        [logClient insertLog:self.logModel];
    }

}

@end
