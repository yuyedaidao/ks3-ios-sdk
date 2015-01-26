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
#import "KS3ServiceResponse.h"

@interface KS3DownLoad ()

@property (strong, nonatomic) KS3Credentials *credentials;
@end

@implementation KS3DownLoad

@synthesize delegate;
@synthesize overwrite;
@synthesize url;
@synthesize fileName;
@synthesize filePath;
@synthesize fileSize;

- (id)initWithUrl:(NSString *)aUrl credentials:(KS3Credentials *)credentials
{
    self = [super init];
    if (self)
    {
        _credentials = credentials;
        url = aUrl;
    }
    return self;
}
- (NSString *)applicationDocumentFilePath
{
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}
- (void)start
{
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
    
    [fileHandle closeFile];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:temporaryPath];
    offset = [fileHandle seekToEndOfFile];
    
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
    
    NSString *strHost = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@", _bucketName, _key];
    NSDate *curDate = getCurrentDate();
    NSString *strCanonResource = [NSString stringWithFormat:@"/%@/%@", _bucketName,_key];
    NSString *strAuthorization = @"";
    if (_credentials.accessKey != nil && _credentials.secretKey != nil) {
        strAuthorization = [KS3AuthUtils strAuthorizationWithHTTPVerb:_credentials.accessKey
                                                            secretKey:_credentials.secretKey
                                                             httpVerb:KSS3_HTTPVerbGet
                                                           contentMd5:@""
                                                          contentType:@""
                                                                 date:curDate
                                               canonicalizedKssHeader:@""
                                                canonicalizedResource:strCanonResource];
    }
    NSString *strTime = [KS3AuthUtils strDateWithDate:curDate andType:@"GMT"];
    
    NSURL *urlRequest = [NSURL URLWithString:strHost];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [request setValue:strTime forHTTPHeaderField:@"Date"];
    [request setValue:strAuthorization forHTTPHeaderField:@"Authorization"];
    [request addValue:range forHTTPHeaderField:@"Range"];
    // **** 如果采用服务器计算token的方式，则设置token
    [self setTokenForURLRequest:request withResource:strCanonResource];
    [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)setTokenForURLRequest:(NSMutableURLRequest *)urlRequest withResource:(NSString *)strResource
{
    if (_credentials.tokenHost != nil) {
        NSLog(@"#### 请求token...... ####");
        NSString *strDate = [urlRequest valueForHTTPHeaderField:@"Date"];
        NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"GET",      @"http_method",
                                   @"",         @"content_md5",
                                   @"",         @"content_type",
                                   strDate,     @"date",
                                   @"",         @"headers",
                                   strResource, @"resource", nil];
        NSURL *tokenUrl = [NSURL URLWithString:_credentials.tokenHost];
        NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
                                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                     timeoutInterval:10];
        NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
        KS3ServiceResponse *response1 = [[KS3ServiceResponse alloc] init];
        [tokenRequest setURL:tokenUrl/*request.tokenRequestUrl*/];
        [tokenRequest setHTTPMethod:@"POST"];
        [tokenRequest setHTTPBody:dataParams];
        NSURLConnection *tokenConnection = [[NSURLConnection alloc] initWithRequest:tokenRequest/*urlRequest*/ delegate:response1 startImmediately:NO];
        [tokenConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:KSYS3DefaultRunLoopMode];
//        request.urlConnection = tokenConnection;
        [tokenConnection start];
        NSTimer *timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                 target:response1
                                                               selector:@selector(timeout)
                                                               userInfo:nil
                                                                repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timeoutTimer forMode:KSYS3DefaultRunLoopMode];
        while (!response1.isFinishedLoading) {
            [[NSRunLoop currentRunLoop] runMode:KSYS3DefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        if (response1.error == nil && response1.body != nil) {
            NSString *strToken = [[NSString alloc] initWithData:response1.body encoding:NSUTF8StringEncoding];
            NSLog(@"#### 获取token成功! #### token: %@", strToken);
            [urlRequest setValue:strToken forHTTPHeaderField:@"Authorization"];
        }
        else {
            NSLog(@"获取token失败");
        }
    }
}

- (void)stop
{
    [connection cancel];
    connection = nil;
    [fileHandle closeFile];
    fileHandle = nil;
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
    if ([response expectedContentLength] != NSURLResponseUnknownLength)
        fileSize = (unsigned long long)[response expectedContentLength]+offset;
    if (delegate && [delegate respondsToSelector:@selector(downloadBegin:didReceiveResponseHeaders:)]) {
         [delegate downloadBegin:self didReceiveResponseHeaders:response];
    }
    if (_downloadBeginBlock) {
        _downloadBeginBlock(self, response);
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    [fileHandle writeData:aData];
    offset = [fileHandle offsetInFile];
    double progress = offset*1.0/fileSize;
    if (_downloadProgressChangeBlock) {
        _downloadProgressChangeBlock(self,progress);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadProgressChange:progress:)]) {
        [delegate downloadProgressChange:self progress:progress];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [fileHandle closeFile];
    if (_failedBlock) {
        _failedBlock(self, error);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) {
       [delegate downloadFaild:self didFailWithError:error];
    }
   
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileHandle closeFile];
    [[NSFileManager defaultManager] moveItemAtPath:temporaryPath toPath:destinationPath error:nil];
    
    if (_downloadFileCompleteionBlock) {
        _downloadFileCompleteionBlock(self, destinationPath);
    }
    if (delegate && [delegate respondsToSelector:@selector(downloadFinished:filePath:)]) {
        [delegate downloadFinished:self filePath:destinationPath];
    }
}

@end
