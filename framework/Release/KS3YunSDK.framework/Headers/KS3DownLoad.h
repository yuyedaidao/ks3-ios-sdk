//
//  MSDownLoad.h
//  MusicSample
//
//  Created by JackWong on 14-1-9.
//  Copyright (c) 2014年 JackWong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3Client.h"


@class KS3Credentials;

@protocol KS3DownloadDelegate;
@interface KS3DownLoad : NSObject
{

    BOOL       overwrite;
	NSString      *url;
	NSString   *fileName;
    NSString   *filePath;
    unsigned long long fileSize;
@private
    NSString   *destinationPath;
    NSString   *temporaryPath;
    NSFileHandle        *fileHandle;
    NSURLConnection     *connection;
    unsigned long long  offset;
    
}
- (id)initWithUrl:(NSString *)aUrl credentials:(KS3Credentials *)credentials;

@property (nonatomic, weak) id<KS3DownloadDelegate> delegate;

@property (nonatomic, weak) id<TokenDelegate> tokenDelegate;

@property (strong, nonatomic) NSString *bucketName;

@property (strong, nonatomic) NSString *key;

@property (nonatomic, assign) BOOL overwrite;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, readonly) unsigned long long fileSize;

@property (copy, nonatomic) KSS3DownloadProgressChangeBlock downloadProgressChangeBlock;

@property (copy, nonatomic) KSS3DownloadFailedBlock failedBlock;

@property (copy, nonatomic) kSS3DownloadFileCompleteionBlock downloadFileCompleteionBlock;

@property (copy, nonatomic) KSS3DownloadBeginBlock downloadBeginBlock;

- (void)start;


- (void)stop;


- (void)stopAndClear;

@end

@protocol KS3DownloadDelegate<NSObject>

- (void)downloadBegin:(KS3DownLoad *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders;

- (void)downloadFaild:(KS3DownLoad *)aDownload didFailWithError:(NSError *)error;

- (void)downloadFinished:(KS3DownLoad *)aDownload filePath:(NSString *)filePath;

- (void)downloadProgressChange:(KS3DownLoad *)aDownload progress:(double)newProgress;

@end
