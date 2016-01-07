//
//  ObjectViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/17/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#warning Please set correct bucket and object name



#define kBucketName @"kssjw"//@"alert1"//@"bucketcors"//@"alert1"
#define kObjectName @"Count_1.txt"//@"test_download.txt"//@"bug.txt"
#define kDesBucketName @"kssjw2"//@"ggg"//
#define kDesObjectName @"bug_copy.txt"
#define kObjectSpecial1 @"+-.jpg"
#define kObjectSpecial2 @"+-.txt"


//1 a b  + - * ~ ! @  # ^ :中 ～ 文.jpg
#define kTestSpecial1 @"1 a b  + - * ~ ! @  # ^ & :\"中 ～ 文.jpg"//@"1 a b  + - * ~ ! @  # ^ & :\"中 ～ 文.jpg"
#define kTestSpecial2 @"a 1 b  + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial3 @"+ - b  + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial4 @"  1 a b+ - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial5 @"＋ a b  + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial6 @"－ a b  + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial7 @"—— a b  + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial8 @"¥ 1 a b + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial9 @"％ 1 a b + - * ~ ! @  # ^ & :\"中 ～ 文"
#define kTestSpecial10 @"中 ～ 文—— 1 a b  + - * ~ ! @  # ^ & :\"中 ～ 文"

#import "ObjectViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>
#import "KS3Util.h"
#import "AppDelegate.h"
@interface ObjectViewController () <KingSoftServiceRequestDelegate>
@property (nonatomic, strong) NSArray *arrItems;
@property (nonatomic, strong) KS3DownLoad *downloader;

@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (assign, nonatomic) NSInteger partSize;
@property (assign, nonatomic) long long fileSize;
@property (assign, nonatomic) long long partLength;
@property (nonatomic) NSInteger totalNum;
@property (nonatomic) NSInteger uploadNum;
@property (nonatomic, strong) NSString *bucketName;
@property (strong, nonatomic)  KS3MultipartUpload *muilt;

@end

@implementation ObjectViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Object";
    _arrItems = [NSArray arrayWithObjects:
                 @"Get Object",       @"Delete Object", @"Head Object", @"Put Object", @"Put Object Copy", @"Post Object",
                 @"Get Object ACL",   @"Set Object ACL", @"Set Object Grant ACL",
                 @"Multipart Upload", @"Pause Download", @"Abort Upload", nil];
}
#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"bucket identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
        if (indexPath.row == 0) {
            UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(200, 12, 100, 20)];
            progressView.progressViewStyle = UIProgressViewStyleDefault;
            progressView.tag = 99;
            [cell.contentView addSubview:progressView];
        }
    }
    cell.textLabel.text = _arrItems[indexPath.row];
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:99];
            /**
             *  如果是暂停下载，就需要把_downloadConnection的file做为参数传到download方法里面
             */
            dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_SERIAL);

//            dispatch_async(concurrentQueue, ^(){
                _downloader = [[KS3Client initialize] downloadObjectWithBucketName:kBucketName key:@"@#$%^&eourj ％  ％ %  %!!!~~~@)fkds.txt" downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
                    NSLog(@"1212221");
                    
                } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
                    NSLog(@"completed, file path: %@", filePath);
                    
                } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
                    progressView.progress = newProgress;
                    NSLog(@"progress: %f", newProgress);
                    
                } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
                    NSLog(@"failed: %@", error.description);
                }];
            
                // //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
                [_downloader setStrKS3Token:[KS3Util KSYAuthorizationWithHTTPVerb:strAccessKey secretKey:strSecretKey httpVerb:_downloader.httpMethod contentMd5:_downloader.contentMd5 contentType:_downloader.contentType date:_downloader.strDate canonicalizedKssHeader:_downloader.kSYHeader canonicalizedResource:_downloader.kSYResource]];
                
                [_downloader start];

//            });


            
            
            
            
        }
            break;
        case 1:
        {
            KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial1];
            [deleteObjRequest setCompleteRequest];
            [deleteObjRequest setStrKS3Token:[KS3Util getAuthorization:deleteObjRequest]];
            KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
            if (response.httpStatusCode == 204) {
                NSLog(@"Delete object success!");
            }
            else {
                NSLog(@"Delete object error: %@", response.error.description);
            }
        }
            break;
        case 2:
        {
            KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2];
            [headObjRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [headObjRequest setStrKS3Token:[KS3Util getAuthorization:headObjRequest]];
            KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
            NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 200) {
                NSLog(@"Head object success!");
            }
            else {
                NSLog(@"Head object error: %@", response.error.description);
            }
        }
            break;
        case 3:
        {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                KS3AccessControlList *ControlList = [[KS3AccessControlList alloc] init];
                [ControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
                KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
                acl.identifier = @"4567894346";
                acl.displayName = @"accDisplayName";
                [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
                KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName withAcl:ControlList grantAcl:@[acl]];
                NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
                putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
                putObjRequest.filename = @"20150404视频云&标准存储服务产品规划-07.pptx";//@"testtoken-01&.jpg";//[fileName lastPathComponent];
                putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
                [putObjRequest setCompleteRequest];
                //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
                [putObjRequest setStrKS3Token:[KS3Util getAuthorization:putObjRequest]];
                KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
                NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
                if (response.httpStatusCode == 200) {
                    NSLog(@"Put object success");
                }
                else {
                    NSLog(@"Put object failed");
                }

            });
                    }
            break;
        case 4:
        {
            KS3BucketObject *destBucketObj = [[KS3BucketObject alloc] initWithBucketName:kDesBucketName keyName:@"testtoken-11.text"];
            KS3BucketObject *sourceBucketObj = [[KS3BucketObject alloc] initWithBucketName:kBucketName keyName:@"testtoken-11.text"];
            KS3PutObjectCopyRequest *request = [[KS3PutObjectCopyRequest alloc] initWithName:destBucketObj sourceBucketObj:sourceBucketObj];
            [request setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [request setStrKS3Token:[KS3Util getAuthorization:request]];
            KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
            NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 200) {
                NSLog(@"Put object copy success!");
            }
            else {
                NSLog(@"Put object copy error: %@", response.error.description);
            }
        }
            break;
        case 5:
        {
            NSLog(@"暂不对移动端开放！");
        }
            break;
        case 6:
        {
            KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2];
            [getObjectACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [getObjectACLRequest setStrKS3Token:[KS3Util getAuthorization:getObjectACLRequest]];
            KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
            KS3BucketACLResult *result = response.listBucketsResult;
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            
            if (response.httpStatusCode == 200) {
                NSLog(@"Get object acl success!");
                NSLog(@"Object owner ID:          %@",result.owner.ID);
                NSLog(@"Object owner displayName: %@",result.owner.displayName);
                for (KS3Grant *grant in result.accessControlList) {
                    NSLog(@"%@",grant.grantee.ID);
                    NSLog(@"%@",grant.grantee.displayName);
                    NSLog(@"%@",grant.grantee.URI);
                    NSLog(@"_______________________");
                    NSLog(@"%@",grant.permission);
                }
            }
            else {
                NSLog(@"Get object acl error: %@", response.error.description);
            }
        }
            break;
        case 7:
        {
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
            KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2 acl:acl];
            [setObjectACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [setObjectACLRequest setStrKS3Token:[KS3Util getAuthorization:setObjectACLRequest]];
            KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set object acl success!");
            }
            else {
                NSLog(@"Set object acl error: %@", response.error.description);
            }
        }
            break;
        case 8:
        {
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            acl.identifier = kObjectName;
            acl.displayName = @"blues111DisplayName";
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            KS3SetObjectGrantACLRequest *setObjectGrantACLRequest = [[KS3SetObjectGrantACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2 grantAcl:acl];
            [setObjectGrantACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [setObjectGrantACLRequest setStrKS3Token:[KS3Util getAuthorization:setObjectGrantACLRequest]];
            KS3SetObjectGrantACLResponse *response = [[KS3Client initialize] setObjectGrantACL:setObjectGrantACLRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set object grant acl success!");
            }
            else {
                NSLog(@"Set object grant acl error: %@", response.error.description);
            }
        }
            break;
        case 9:
        {
            NSString *strKey = @"testtoken-11.text";//@"+-.txt";
            NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"bugDownload" ofType:@"txt"];
            _partSize = 5;
            _fileHandle = [NSFileHandle fileHandleForReadingAtPath:strFilePath];
            _fileSize = [_fileHandle availableData].length;
            if (_fileSize <= 0) {
                NSLog(@"####This file is not exist!####");
                return ;
            }
            if (!(_partSize > 0 || _partSize != 0)) {
                _partLength = _fileSize;
            }else{
                _partLength = _partSize * 1024.0 * 1024.0;
            }
            _totalNum = (ceilf((float)_fileSize / (float)_partLength));
            [_fileHandle seekToFileOffset:0];
            
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Private];
            KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:kBucketName acl:acl grantAcl:nil];
            [initMultipartUploadReq setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [initMultipartUploadReq setStrKS3Token:[KS3Util getAuthorization:initMultipartUploadReq]];
            _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
            if (_muilt == nil) {
                NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
                return ;
            }
            
            _uploadNum = 1;
            [self uploadWithPartNumber:_uploadNum];
        }
            break;
        case 10:
        {
            [_downloader stop];
        }
            break;
        case 11:
        {
            KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
            [request setCompleteRequest];
//             使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [request setStrKS3Token:[KS3Util getAuthorization:request]];
            KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 204) {
                NSLog(@"Abort multipart upload success!");
            }
            else {
                NSLog(@"error: %@", response.error.description);
            }
        }
            break;
        default:
            break;
    }
}

- (void)uploadWithPartNumber:(NSInteger)partNumber
{
    long long partLength = _partSize * 1024.0 * 1024.0;
    NSData *data = nil;
    if (_uploadNum == _totalNum) {
        data = [_fileHandle readDataToEndOfFile];
    }else {
        data = [_fileHandle readDataOfLength:(NSUInteger)partLength];
        [_fileHandle seekToFileOffset:partLength*(_uploadNum)];
    }
    
    KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt partNumber:(int32_t)partNumber data:data generateMD5:NO];
    req.delegate = self;
    req.contentLength = data.length;
    req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
    [req setCompleteRequest];
     //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    [req setStrKS3Token:[KS3Util getAuthorization:req]];
    [[KS3Client initialize] uploadPart:req];
}



#pragma mark - Delegate

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    _uploadNum ++;
    if (_totalNum < _uploadNum) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        [req2 setCompleteRequest];
         //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req2 setStrKS3Token:[KS3Util getAuthorization:req2]];
        
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        
        
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        //req参数设置完一定要调这个函数
        [req setCompleteRequest];
         //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req setStrKS3Token:[KS3Util getAuthorization:req]];
        
        KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
        NSLog(@"%@",[[NSString alloc] initWithData:resp.body encoding:NSUTF8StringEncoding]);
        if (resp.httpStatusCode != 200) {
            NSLog(@"#####complete multipart upload failed!!! code: %d#####", resp.httpStatusCode);
        }
        
    }
    else {
        [self uploadWithPartNumber:_uploadNum];
    }
}

- (void)request:(KS3Request *)request didFailWithError:(NSError *)error
{
    NSLog(@"upload error: %@", error);
}

- (void)request:(KS3Request *)request didReceiveResponse:(NSURLResponse *)response
{
    // **** TODO:
}

- (void)request:(KS3Request *)request didReceiveData:(NSData *)data
{
    /**
     *  Never call this method, because it's upload
     *
     *  @return <#return value description#>
     */
}

-(void)request:(KS3Request *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    long long alreadyTotalWriten = (_uploadNum - 1) * _partLength + totalBytesWritten;
    double progress = alreadyTotalWriten / (float)_fileSize;
    NSLog(@"upload progress: %f", progress);
}

@end
