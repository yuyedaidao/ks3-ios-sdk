//
//  KS3UploadManager.m
//  Pods
//
//  Created by Sun Peng on 2017/4/27.
//
//

#import "KS3UploadManager.h"
#import "KS3Request.h"
#import "KS3Response.h"
#import "KS3Client.h"
#import "KS3UploadRequest.h"
#import "KS3Upload.h"
#import "KS3ListPartsRequest.h"
#import "KS3ServiceRequest.h"
#import "KS3InitiateMultipartUploadResponse.h"
#import "KS3UploadPartRequest.h"
#import "KS3SDKUtil.h"
#import "KS3AuthUtils.h"
#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3CompleteMultipartUploadResponse.h"
#import "KS3ListPartsResponse.h"
#import "KS3Part.h"

#define kMinBlockSize  5 * kMB
#define kMaxBlockSize  512 * kMB

@interface KS3UploadManager()

@property (nonatomic, strong) KS3Client *client;
@property (nonatomic, strong) KS3AuthCalculateHandler authHandler;

@property (nonatomic, strong) NSMutableDictionary *uploadRecorder;
@property (nonatomic, strong) NSMutableDictionary *dataRecorder;
@property (nonatomic, strong) NSMutableDictionary *progressRecorder;
@property (nonatomic, strong) NSMutableDictionary *progressHandlers;
@property (nonatomic, strong) NSMutableDictionary *cancelSignalHandlers;
@property (nonatomic, strong) NSMutableDictionary *completeHandlers;
@property (nonatomic, strong) NSMutableDictionary *errorHandlers;

@end

@interface KS3UploadManager () <KingSoftServiceRequestDelegate>
@end

@implementation KS3UploadManager

- (instancetype)initWithClient:(KS3Client *)client authHandler:(KS3AuthCalculateHandler)authHandler {
    if (self = [super init]) {
        self.client = client;
        self.authHandler = authHandler;

        self.uploadRecorder = [[NSMutableDictionary alloc] init];
        self.dataRecorder = [[NSMutableDictionary alloc] init];
        self.progressRecorder = [[NSMutableDictionary alloc] init];
        self.progressHandlers = [[NSMutableDictionary alloc] init];
        self.cancelSignalHandlers = [[NSMutableDictionary alloc] init];
        self.completeHandlers = [[NSMutableDictionary alloc] init];
        self.errorHandlers = [[NSMutableDictionary alloc] init];
    }

    return self;
}

+(instancetype)sharedInstanceWithClient:(KS3Client *)client authHandler:(KS3AuthCalculateHandler)authHandler {
    static KS3UploadManager *sharedManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithClient:client authHandler:authHandler];
    });

    return sharedManager;
}

- (void)putData:(NSData *)data
        request:(KS3UploadRequest *)request
      blockSize:(NSInteger)size
       progress:(KS3UploadProgressHandler)progressHandler
   cancelSignal:(KS3UploadCancellationSignal)cancelSignal
       complete:(KS3UploadCompletionHandler)completionHandler
          error:(KS3UploadErrorHandler)errorHandler {
    NSInteger contentLength = data.length;

    NSInteger blockLength = size;

    if (size < kMinBlockSize) {
        size = kMinBlockSize;
    }
    if (size > kMaxBlockSize) {
        size = kMaxBlockSize;
    }

    NSInteger partCount = (ceilf((float)contentLength / (float)size));

    // Step 1 initiate Multipart Upload
    KS3InitiateMultipartUploadResponse *initiateMultipartUploadResponse = [self.client initiateMultipartUploadWithRequestAndResponse:request];
    KS3MultipartUpload *multipartUpload = initiateMultipartUploadResponse.multipartUpload;
    if (!multipartUpload) {
        errorHandler(nil, initiateMultipartUploadResponse.error);
        NSLog(@"Initiate multipart upload failed..");
        return;
    }

    KS3Upload *upload = [[KS3Upload alloc] init];
    upload.key = multipartUpload.key;
    upload.bucket = multipartUpload.bucket;
    upload.uploadId = multipartUpload.uploadId;
    upload.storageClass = multipartUpload.storageClass;
    upload.initiator = multipartUpload.initiator;
    upload.initiated = multipartUpload.initiated;
    upload.blockSize = size;
    upload.partCount = partCount;
    upload.contentLength = contentLength;

    [self registerUpload:upload data:data progressHandler:progressHandler cancelSignal:cancelSignal completeHandler:completionHandler errorHandler:errorHandler];

    // Step 2 kick first part upload
    // later parts will be uploaded in delegate methods
    [self upload:upload.uploadId part:1];
}

- (void)resumeUpload:(NSData *)data
              upload:(KS3Upload *)upload
            progress:(KS3UploadProgressHandler)progressHandler
        cancelSignal:(KS3UploadCancellationSignal)cancelSignal
            complete:(KS3UploadCompletionHandler)completionHandler
               error:(KS3UploadErrorHandler)errorHandler {
    [self registerUpload:upload data:data progressHandler:progressHandler cancelSignal:cancelSignal completeHandler:completionHandler errorHandler:errorHandler];
    NSString *uploadId = upload.uploadId;
    NSString *objectKey = upload.key;

    //list一下所有上传过的块
    KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:upload];
    [req2 setCompleteRequest];

    //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    if (self.authHandler) {
        [req2 setStrKS3Token:self.authHandler(req2)];
    } else {
        [req2 setStrKS3Token:[self authorizationForRequest:req2]];
    }


    KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];

    NSLog(@"response.listResult.parts.count =%lu",(unsigned long)[response2.listResult.parts count]);

    //从这块开始上传,list结果的最后一块
    NSNumber *uploadedPart = [NSNumber numberWithInteger:((KS3Part *)[response2.listResult.parts lastObject]).partNumber];
    [self.progressRecorder setObject:uploadedPart forKey:uploadId];

    //进度补齐
    long long alreadyTotalWriten = uploadedPart.integerValue * upload.blockSize ;
    double progress = 1.0 * alreadyTotalWriten / upload.contentLength;
    progressHandler(objectKey, progress);

    [self upload:uploadId part:uploadedPart.integerValue + 1];
}

#pragma mark - Register methods
- (void)registerUpload:(KS3Upload *)upload data:(NSData *)data
       progressHandler:(KS3UploadProgressHandler)progressHandler
          cancelSignal:(KS3UploadCancellationSignal)cancelSignal
       completeHandler:(KS3UploadCompletionHandler)completionHandler
          errorHandler:(KS3UploadErrorHandler)errorHandler {
    NSString *uploadId = upload.uploadId;
    [self.uploadRecorder setObject:upload forKey:uploadId];
    [self.dataRecorder setObject:data forKey:uploadId];
    [self.progressRecorder setObject:[NSNumber numberWithInteger:0] forKey:uploadId];
    [self.progressHandlers setObject:progressHandler forKey:uploadId];
    [self.cancelSignalHandlers setObject:cancelSignal forKey:uploadId];
    [self.completeHandlers setObject:completionHandler forKey:uploadId];
    [self.errorHandlers setObject:errorHandler forKey:uploadId];
}

- (void)removeUpload:(KS3Upload *)upload {
    NSString *uploadId = upload.uploadId;
    [self.uploadRecorder removeObjectForKey:uploadId];
    [self.dataRecorder removeObjectForKey:uploadId];
    [self.progressRecorder removeObjectForKey:uploadId];
    [self.progressHandlers removeObjectForKey:uploadId];
    [self.cancelSignalHandlers removeObjectForKey:uploadId];
    [self.completeHandlers removeObjectForKey:uploadId];
    [self.errorHandlers removeObjectForKey:uploadId];
}

#pragma mark - Data Helper
- (NSData *)dataWithRange:(NSData *)data range:(NSRange)range {
    NSRange totalRange = NSMakeRange(0, data.length);
    NSRange intersectRange = NSIntersectionRange(range, totalRange);
    return [data subdataWithRange:intersectRange];
}

#pragma mark - Upload methods
- (void)upload:(NSString *)uploadId part:(NSInteger) part
{
    @autoreleasepool {
        KS3Upload *multipartUpload = [self.uploadRecorder objectForKey:uploadId];

        NSRange dataRange = NSMakeRange((part - 1) * multipartUpload.blockSize, multipartUpload.blockSize);
        NSData *content = [self.dataRecorder objectForKey:uploadId];
        NSData *partData = [self dataWithRange:content range:dataRange];

        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:multipartUpload partNumber:(int32_t)part  data:partData generateMD5:NO];
        req.delegate = self;
        req.contentLength = partData.length;
        req.contentMd5 = [KS3SDKUtil base64md5FromData:partData];
        [req setCompleteRequest];

        if (self.authHandler) {
            [req setStrKS3Token:self.authHandler(req)];
        } else {
            [req setStrKS3Token:[self authorizationForRequest:req]];
        }

        [[KS3Client initialize] uploadPart:req];
    }
}

#pragma mark - Auth Utils
- (NSString *)authorizationForRequest:(KS3Request *)request {
    return [KS3AuthUtils KSYAuthorizationWithAccessKey:self.client.credentials.accessKey
                                             secretKey:self.client.credentials.secretKey
                                              httpVerb:request.httpMethod
                                            contentMd5:request.contentMd5
                                           contentType:request.contentType
                                               strDate:request.strDate
                                canonicalizedKssHeader:request.kSYHeader
                                 canonicalizedResource:request.kSYResource];
}

#pragma mark - 上传的回调方法
- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    if ([request isKindOfClass:[KS3UploadPartRequest class]]) {
        KS3UploadPartRequest *uploadPartRequest = (KS3UploadPartRequest *)request;
        NSString *uploadId = uploadPartRequest.uploadId;

        if (response.httpStatusCode != 200) {
            KS3UploadErrorHandler errorHandler = [self.errorHandlers objectForKey:uploadId];
            if (errorHandler) {
                errorHandler([self.uploadRecorder objectForKey:uploadId], [NSError errorWithDomain:NSURLErrorDomain code:response.httpStatusCode userInfo:@{@"mesage" : [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]}] );
            }
            return;
        }

        NSNumber *progress = [self.progressRecorder objectForKey:uploadId];
        KS3Upload *upload = [self.uploadRecorder objectForKey:uploadId];
        progress = [NSNumber numberWithInteger:progress.integerValue + 1];
        [self.progressRecorder setObject:progress forKey:uploadId];

        // 所有块上传完成
        if (progress.integerValue >= upload.partCount) {
            KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:upload];
            [req2 setCompleteRequest];

            if (self.authHandler) {
                [req2 setStrKS3Token:self.authHandler(req2)];
            } else {
                [req2 setStrKS3Token:[self authorizationForRequest:req2]];
            }

            KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
            KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:upload];

            NSLog(@"%@",response2.listResult.parts);
            for (KS3Part *part in response2.listResult.parts) {
                [req addPartWithPartNumber:part.partNumber withETag:part.etag];
            }
            //req参数设置完一定要调这个函数
            [req setCompleteRequest];

            if (self.authHandler) {
                [req setStrKS3Token:self.authHandler(req)];
            } else {
                [req setStrKS3Token:[self authorizationForRequest:req]];
            }

            KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
            NSString *bodyStr = [[NSString alloc]initWithData:resp.body encoding:NSUTF8StringEncoding];
            if (resp.httpStatusCode != 200) {
                NSLog(@"#####complete multipart upload failed!!! code: %d#####，body = %@", resp.httpStatusCode,bodyStr);

                KS3UploadErrorHandler errorHandler = [self.errorHandlers objectForKey:uploadId];
                errorHandler(upload, [NSError errorWithDomain:NSURLErrorDomain code:response.httpStatusCode userInfo:@{@"mesage" : [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]}]);
            }else if (resp.httpStatusCode == 200) {
                NSLog(@"分块上传成功!!");

                KS3UploadCompletionHandler handler = [self.completeHandlers objectForKey:uploadId];
                handler([self.uploadRecorder objectForKey:uploadId], resp);
            }

            [self removeUpload:upload];
        }
        else {
            [self upload:uploadId part:progress.integerValue + 1];
        }
    }

}

- (void)request:(KS3Request *)request didFailWithError:(NSError *)error
{
    NSLog(@"upload error: %@", error);
    if ([request respondsToSelector:@selector(uploadId)]) {
        NSString *uploadId = [request performSelector:@selector(uploadId)];
        KS3UploadErrorHandler handler = [self.errorHandlers objectForKey:uploadId];
        KS3Upload *upload = [self.uploadRecorder objectForKey:uploadId];
        if (handler) {
            handler(upload, error);
        }
    }
}

- (void)request:(KS3Request *)request didReceiveResponse:(NSURLResponse *)response
{
}

- (void)request:(KS3Request *)request didReceiveData:(NSData *)data
{
}

-(void)request:(KS3Request *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if ([request isKindOfClass:[KS3UploadPartRequest class]]) {
        KS3UploadPartRequest *uploadPartRequest = (KS3UploadPartRequest *)request;
        NSString *uploadId = uploadPartRequest.uploadId;
        NSString *objectKey = uploadPartRequest.key;

        KS3UploadProgressHandler progressHandler = [self.progressHandlers objectForKey:uploadId];
        KS3UploadCancellationSignal signal = [self.cancelSignalHandlers objectForKey:uploadId];
        if (signal(objectKey)) {
            [request cancel];

            progressHandler(uploadPartRequest.key, 0);
            return;
        }

        KS3Upload *upload = [self.uploadRecorder objectForKey:uploadId];
        NSInteger uploadPart = [[self.progressRecorder objectForKey:uploadId] integerValue];
        long long alreadyTotalWriten = uploadPart * upload.blockSize + totalBytesWritten;
        double progress = 1.0 * alreadyTotalWriten / upload.contentLength;
        if (progress > 1.0) {
            NSLog(@"WTF???");
        }
        NSLog(@"upload progress: %f", progress);

        progressHandler(objectKey, progress);
    }
}

@end
