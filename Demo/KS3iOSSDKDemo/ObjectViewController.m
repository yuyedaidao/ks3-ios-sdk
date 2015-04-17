//
//  ObjectViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/17/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#warning Please set correct bucket and object name
#define kBucketName @"acc"//@"alert1"//@"bucketcors"//@"alert1"
#define kObjectName @"Count_1.txt"//@"test_download.txt"//@"bug.txt"
#define kDesBucketName @"blues11"//@"ggg"//
#define kDesObjectName @"bug_copy.txt"

#import "ObjectViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>

@interface ObjectViewController () <KingSoftServiceRequestDelegate, DownloadTokenDelegate>
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

- (void)strTokenWithParams:(NSDictionary *)dicParams {
    NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
    NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
                                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                 timeoutInterval:10];
    NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
    [tokenRequest setURL:tokenUrl];
    [tokenRequest setHTTPMethod:@"POST"];
    [tokenRequest setHTTPBody:dataParams];
    [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"#### 获取token成功! #### token: %@", strToken);
            [_downloader setStrKS3Token:strToken];
        }
        else {
            NSLog(@"#### 获取token失败，error: %@", connectionError);
        }
    }];
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
            _downloader = [[KS3Client initialize] downloadObjectWithBucketName:kBucketName key:kObjectName tokenDelegate:self downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
                NSLog(@"1212221");
                
            } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
                NSLog(@"completed, file path: %@", filePath);
                
            } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
                progressView.progress = newProgress;
                NSLog(@"progress: %f", newProgress);
                
            } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
                NSLog(@"failed: %@", error.description);
            }];
            [_downloader start];
        }
            break;
        case 1:
        {
            KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName withKeyName:@"test.jpg"];
//            deleteObjRequest.key = @"test.jpg";
//            NSDictionary *dicParams = [self dicParamsWithReq:deleteObjRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    deleteObjRequest.strKS3Token = strToken;
//                    KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
//                    if (response.httpStatusCode == 204) {
//                        NSLog(@"Delete object success!");
//                    }
//                    else {
//                        NSLog(@"Delete object error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
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
            KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectName];
//            headObjRequest.key = kObjectName;
//            NSDictionary *dicParams = [self dicParamsWithReq:headObjRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    headObjRequest.strKS3Token = strToken;
//                    KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Head object success!");
//                    }
//                    else {
//                        NSLog(@"Head object error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
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
            KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName withAcl:nil grantAcl:nil];
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
            putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
            putObjRequest.filename = [fileName lastPathComponent];
            putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
            
//            putObjRequest.callbackBody = @"objectKey=${key}&etag=${etag}&location=${kss-location}&name=${kss-price}";
//            putObjRequest.callbackUrl = @"http://127.0.0.1:19090/";// success
////            putObjRequest.callbackUrl = @"http://127.0.0.1:190910";// failed
////            putObjRequest.callbackUrl = @"http://127.0.0.1:190910";// timeout
//            putObjRequest.callbackParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                            @"BeiJing", @"kss-location",
//                                            @"$Ten",    @"kss-price",
//                                            @"error",   @"kss", nil];
//            [[KS3Client initialize] putObject:putObjRequest];
            
//            NSDictionary *dicParams = [self dicParamsWithReq:putObjRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    putObjRequest.strKS3Token = strToken;
//                    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Put object success");
//                    }
//                    else {
//                        NSLog(@"Put object failed");
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Put object success");
            }
            else {
                NSLog(@"Put object failed");
            }
        }
            break;
        case 4:
        {
            KS3BucketObject *destBucketObj = [[KS3BucketObject alloc] initWithBucketName:kDesBucketName keyName:kDesObjectName];
            KS3BucketObject *sourceBucketObj = [[KS3BucketObject alloc] initWithBucketName:kBucketName keyName:kObjectName];
            KS3PutObjectCopyRequest *request = [[KS3PutObjectCopyRequest alloc] initWithName:destBucketObj sourceBucketObj:sourceBucketObj];
//            request.key = kDesObjectName;
//            request.strSourceBucket = kBucketName;
//            request.strSourceObject = kObjectName;
            
//            NSDictionary *dicParams = [self dicParamsWithReq:request];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    request.strKS3Token = strToken;
//                    KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Put object copy success!");
//                    }
//                    else {
//                        NSLog(@"Put object copy error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
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
            KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName];
//            getObjectACLRequest.key = kObjectName;
            
//            NSDictionary *dicParams = [self dicParamsWithReq:getObjectACLRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    getObjectACLRequest.strKS3Token = strToken;
//                    KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
//                    KS3BucketACLResult *result = response.listBucketsResult;
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Get object acl success!");
//                        NSLog(@"Object owner ID:          %@",result.owner.ID);
//                        NSLog(@"Object owner displayName: %@",result.owner.displayName);
//                        for (KS3Grant *grant in result.accessControlList) {
//                            NSLog(@"%@",grant.grantee.ID);
//                            NSLog(@"%@",grant.grantee.displayName);
//                            NSLog(@"%@",grant.grantee.URI);
//                            NSLog(@"_______________________");
//                            NSLog(@"%@",grant.permission);
//                        }
//                    }
//                    else {
//                        NSLog(@"Get object acl error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
            KS3BucketACLResult *result = response.listBucketsResult;
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
            KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName acl:acl];
//            setObjectACLRequest.key = kObjectName;
//            setObjectACLRequest.acl = acl;
            
//            NSDictionary *dicParams = [self dicParamsWithReq:setObjectACLRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    setObjectACLRequest.strKS3Token = strToken;
//                    KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Set object acl success!");
//                    }
//                    else {
//                        NSLog(@"Set object acl error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
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
            KS3SetObjectGrantACLRequest *setObjectGrantACLRequest = [[KS3SetObjectGrantACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName grantAcl:acl];
//            setObjectGrantACLRequest.key = kObjectName;
            
//            setObjectGrantACLRequest.acl = acl;
            
//            NSDictionary *dicParams = [self dicParamsWithReq:setObjectGrantACLRequest];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    setObjectGrantACLRequest.strKS3Token = strToken;
//                    KS3SetObjectGrantACLResponse *response = [[KS3Client initialize] setObjectGrantACL:setObjectGrantACLRequest];
//                    if (response.httpStatusCode == 200) {
//                        NSLog(@"Set object grant acl success!");
//                    }
//                    else {
//                        NSLog(@"Set object grant acl error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
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
            NSString *strKey = @"upload_release.txt";
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
            
            KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:kBucketName acl:nil grantAcl:nil];
//            NSDictionary *dicParams = [self dicParamsWithReq:initMultipartUploadReq];
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    initMultipartUploadReq.strKS3Token = strToken;
//                    _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
//                    if (_muilt == nil) {
//                        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
//                        return ;
//                    }
//                    
//                    _uploadNum = 1;
//                    [self uploadWithPartNumber:_uploadNum];
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
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
//            NSDictionary *dicParams = [self dicParamsWithReq:request];
//            
//            NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//            NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                         timeoutInterval:10];
//            NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//            [tokenRequest setURL:tokenUrl];
//            [tokenRequest setHTTPMethod:@"POST"];
//            [tokenRequest setHTTPBody:dataParams];
//            [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                if (connectionError == nil) {
//                    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                    request.strKS3Token = strToken;
//                    KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
//                    if (response.httpStatusCode == 204) {
//                        NSLog(@"Abort multipart upload success!");
//                    }
//                    else {
//                        NSLog(@"error: %@", response.error.description);
//                    }
//                }
//                else {
//                    NSLog(@"#### 获取token失败，error: %@", connectionError);
//                }
//            }];
            KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
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
    
    KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
    req.delegate = self;
    req.data = data;
    req.partNumber = (int32_t)partNumber;
    req.contentLength = data.length;
    req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
//    NSDictionary *dicParams = [self dicParamsWithReq:req];
//    NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//    NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                 timeoutInterval:10];
//    NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//    [tokenRequest setURL:tokenUrl];
//    [tokenRequest setHTTPMethod:@"POST"];
//    [tokenRequest setHTTPBody:dataParams];
//    [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError == nil) {
//            NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"#### 获取token成功! #### token: %@", strToken);
//            req.strKS3Token = strToken;
//            [[KS3Client initialize] uploadPart:req];
//        }
//        else {
//            NSLog(@"#### 获取token失败，error: %@", connectionError);
//        }
//    }];
    [[KS3Client initialize] uploadPart:req];
}

- (NSDictionary *)dicParamsWithReq:(KS3Request *)request {
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               request.httpMethod,  @"http_method",
                               request.contentMd5,  @"content_md5",
                               request.contentType, @"content_type",
                               request.strDate,     @"date",
                               request.kSYHeader,   @"headers",
                               request.kSYResource, @"resource", nil];
    return dicParams;
}


#pragma mark - Delegate

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    _uploadNum ++;
    if (_totalNum < _uploadNum) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
//        NSDictionary *dicParams = [self dicParamsWithReq:req2];
//        NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//        NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                     timeoutInterval:10];
//        NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//        [tokenRequest setURL:tokenUrl];
//        [tokenRequest setHTTPMethod:@"POST"];
//        [tokenRequest setHTTPBody:dataParams];
//        [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            if (connectionError == nil) {
//                NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                req2.strKS3Token = strToken;
//                KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
//                
//                KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
//                for (KS3Part *part in response2.listResult.parts) {
//                    [req addPartWithPartNumber:part.partNumber withETag:part.etag];
//                }
//                //                req.callbackUrl = _callbackUrl;
//                //                req.callbackBody = _callbackBody;
//                //                req.callbackParams = _callbackParams;
//                NSDictionary *dicParams = [self dicParamsWithReq:req];
//                NSURL *tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
//                NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
//                                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                                             timeoutInterval:10];
//                NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
//                [tokenRequest setURL:tokenUrl];
//                [tokenRequest setHTTPMethod:@"POST"];
//                [tokenRequest setHTTPBody:dataParams];
//                [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                    if (connectionError == nil) {
//                        NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                        NSLog(@"#### 获取token成功! #### token: %@", strToken);
//                        req.strKS3Token = strToken;
//                        KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
//                        if (resp.httpStatusCode != 200) {
//                            NSLog(@"#####complete multipart upload failed!!! code: %d#####", resp.httpStatusCode);
//                        }
//                    }
//                    else {
//                        NSLog(@"#### 获取token失败，error: %@", connectionError);
//                    }
//                }];
//            }
//            else {
//                NSLog(@"#### 获取token失败，error: %@", connectionError);
//            }
//        }];
        
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        
        KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
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
