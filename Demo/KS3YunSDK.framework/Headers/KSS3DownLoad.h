//
//  MSDownLoad.h
//  MusicSample
//
//  Created by JackWong on 14-1-9.
//  Copyright (c) 2014年 JackWong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KingSoftS3Client.h"


@class KingSoftCredentials;

@protocol KSS3DownloadDelegate;
@interface KSS3DownLoad : NSObject
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
- (id)initWithUrl:(NSString *)aUrl credentials:(KingSoftCredentials *)credentials;
@property (nonatomic, weak) id<KSS3DownloadDelegate> delegate;

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

@protocol KSS3DownloadDelegate<NSObject>

- (void)downloadBegin:(KSS3DownLoad *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders;

- (void)downloadFaild:(KSS3DownLoad *)aDownload didFailWithError:(NSError *)error;

- (void)downloadFinished:(KSS3DownLoad *)aDownload filePath:(NSString *)filePath;

- (void)downloadProgressChange:(KSS3DownLoad *)aDownload progress:(double)newProgress;

@end
