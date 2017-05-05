//
//  KS3UploadManager.h
//  Pods
//
//  Created by Sun Peng on 2017/4/27.
//
//

#import <Foundation/Foundation.h>

@class KS3Client;
@class KS3Request;
@class KS3Response;
@class KS3UploadRequest;
@class KS3Upload;

#define kKB 1024
#define kMB 1048576

typedef void (^KS3UploadErrorHandler)(KS3Upload *upload, NSError *error);
typedef void (^KS3UploadCompletionHandler)(KS3Upload *upload, KS3Response *response);
typedef void (^KS3UploadProgressHandler)(NSString *key, double percent);
typedef BOOL (^KS3UploadCancellationSignal)(NSString *key);
typedef NSString* (^KS3AuthCalculateHandler)(KS3Request *request);

@interface KS3UploadManager : NSObject

- (instancetype)initWithClient:(KS3Client *)client authHandler:(KS3AuthCalculateHandler)authHandler;

+ (instancetype)sharedInstanceWithClient:(KS3Client *)client authHandler:(KS3AuthCalculateHandler)authHandler;

- (void)putData:(NSData *)data
        request:(KS3UploadRequest *)request
      blockSize:(NSInteger)size
       progress:(KS3UploadProgressHandler)progressHandler
   cancelSignal:(KS3UploadCancellationSignal)cancelSignal
       complete:(KS3UploadCompletionHandler)completionHandler
          error:(KS3UploadErrorHandler)errorHandler;

- (void)resumeUpload:(NSData *)data
              upload:(KS3Upload *)upload
            progress:(KS3UploadProgressHandler)progressHandler
        cancelSignal:(KS3UploadCancellationSignal)cancelSignal
            complete:(KS3UploadCompletionHandler)completionHandler
               error:(KS3UploadErrorHandler)errorHandler;

@end
