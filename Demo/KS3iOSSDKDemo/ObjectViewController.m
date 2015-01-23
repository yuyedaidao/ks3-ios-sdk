//
//  ObjectViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/17/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#warning Please set correct bucket and object name
#define kBucketName @"acc"//@"bucketcors"//@"alert1"
#define kObjectName @"Count_1.txt"//@"bug.txt"
#define kDesBucketName @"ggg"//@"blues111"
#define kDesObjectName @"bug_copy.txt"

#import "ObjectViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>

@interface ObjectViewController () <KingSoftServiceRequestDelegate>
@property (nonatomic, strong) NSArray *arrItems;
@property (nonatomic, strong) KS3DownLoad *downloader;
@property (nonatomic) NSInteger partInter;
@property (strong, nonatomic)  KS3MultipartUpload *muilt;
@property (nonatomic) NSInteger upLoadCount;
@property (nonatomic, strong) KS3FileUploader *uploader;

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
            KS3GetObjectRequest *request = [[KS3GetObjectRequest alloc] initWithName:@"acc"];
            request.key = kObjectName;
            request.responseContentLanguage = @"mi, zh";
            KS3GetObjectResponse *response = [[KS3Client initialize] getObject:request];
            NSString *str = [[NSString  alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 200) {
                NSLog(@"success!");
            }
            else {
                NSLog(@"error");
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:99];
                    /**
             *  如果是暂停下载，就需要把_downloadConnection的file做为参数传到download方法里面
             */
            _downloader = [[KS3Client initialize] downloadObjectWithBucketName:kBucketName key:kObjectName downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
                NSLog(@"1212221");
                
            } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
                NSLog(@"completed, file path: %@", filePath);
                
            } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
                progressView.progress = newProgress;
                NSLog(@"progress: %f", newProgress);
                
            } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
                NSLog(@"failed: %@", error.description);
            }];
        }
            break;
        case 1:
        {
            KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName];
            deleteObjRequest.key = @"photo_hor.jpeg";
            KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
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
            KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:kBucketName];
            headObjRequest.key = kObjectName;
            KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
            
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
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
            //一定要实现委托方法 (这种情况如果实现委托，返回的reponse一般返回为nil，具体获取返回对象需要到委托方法里面获取，如果不实现委托，reponse不会为nil
            KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName];
//            putObjRequest.delegate = self;
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
            putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
            putObjRequest.filename = [fileName lastPathComponent];
<<<<<<< HEAD
            KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
            
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
=======
            
            putObjRequest.callbackBody = @"objectKey=${key}&etag=${etag}&location=${kss-location}&name=${kss-price}";
            putObjRequest.callbackUrl = @"http://127.0.0.1:19090/";// success
//            putObjRequest.callbackUrl = @"http://127.0.0.1:190910";// failed
//            putObjRequest.callbackUrl = @"http://127.0.0.1:190910";// timeout
            putObjRequest.callbackParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"BeiJing", @"kss-location",
                                            @"$Ten",    @"kss-price",
                                            @"error",   @"kss", nil];
//            [[KS3Client initialize] putObject:putObjRequest];
            KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
            NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            if (response.httpStatusCode == 200) {
                NSLog(@"Put object success");
            }
            else {
                NSLog(@"Put object failed");
            }
>>>>>>> 5bf61d6e39230b00c8c24035991faae08a3a60e1
        }
            break;
        case 4:
        {
            KS3PutObjectCopyRequest *request = [[KS3PutObjectCopyRequest alloc] initWithName:kDesBucketName];
            request.key = kDesObjectName;
            request.strSourceBucket = kBucketName;
            request.strSourceObject = kObjectName;
            KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
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
            KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:kBucketName];
            getObjectACLRequest.key = kObjectName;
            KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
            KS3BucketACLResult *result = response.listBucketsResult;
            
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
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
            KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName];
            setObjectACLRequest.key = kObjectName;
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
            setObjectACLRequest.acl = acl;
            KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
            NSLog(@"------%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            NSLog(@"%d",[response httpStatusCode]);
            NSLog(@"%@",[response responseHeader]);
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
            KS3SetObjectGrantACLRequest *setObjectGrantACLRequest = [[KS3SetObjectGrantACLRequest alloc] initWithName:kBucketName];
            setObjectGrantACLRequest.key = kObjectName;
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            acl.identifier = kObjectName;
            acl.displayName = @"blues111DisplayName";
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            setObjectGrantACLRequest.acl = acl;
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
#warning "blues111" is your the bucket you want to operate, "bugDownload.txt" is the object name you want to upload, "500.txt" is file name in cloud
            /**
             *  大于100M的文件可以使用文件分块上传 如果需要使用文件分块上传则必须实现代理方法 在委托方法里完成块的拼装（本demo为了测试，则上传了小文件，方便开发者下载demo）
             */
//            _upLoadCount = 0;
//            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"bugDownload" ofType:@"txt"]];
//            long long fileLength = [[fileHandle availableData] length];
//            long long partLength = 5*1024.0*1024.0;
//            _partInter = (ceilf((float)fileLength / (float)partLength));
//            NSLog(@"%lld",fileLength);
//            NSLog(@"%lld",partLength);
//            NSLog(@"%ld",_partInter);
//            [fileHandle seekToFileOffset:0];
//            _muilt = [[KS3Client initialize] initiateMultipartUploadWithKey:@"10000.txt" withBucket:kBucketName];
//            for (NSInteger i = 0; i < _partInter; i ++) {
//                NSData *data = nil;
//                if (i == _partInter - 1) {
//                    data = [fileHandle readDataToEndOfFile];
//                }else {
//                    data = [fileHandle readDataOfLength:partLength];
//                    [fileHandle seekToFileOffset:partLength*(i+1)];
//                }
//                KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
//                req.delegate = self;
//                req.data = data;
//                req.partNumber = (int32_t)i+1;
//                req.contentLength = data.length;
//                [[KS3Client initialize] uploadPart:req];
//            }
            _uploader = [[KS3FileUploader alloc] initWithBucketName:kBucketName];
            _uploader.strFilePath = [[NSBundle mainBundle] pathForResource:@"bugDownload" ofType:@"txt"];
            _uploader.strKey = @"10000000.txt";
            _uploader.partSize = 5; // **** unit: MB, must larger than 5
            
            _uploader.callbackBody = @"objectKey=${key}&etag=${etag}&location=${kss-location}&name=${kss-price}";
            _uploader.callbackUrl = @"http://127.0.0.1:19090/";// success
//            _uploader.callbackUrl = @"http://127.0.0.1:190910";// failed
//            _uploader.callbackUrl = @"http://127.0.0.1:190910";// timeout
            _uploader.callbackParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"BeiJing", @"kss-location",
                                        @"$Ten",    @"kss-price",
                                        @"error",   @"kss", nil];
            
            [_uploader startUploadWithProgressChangeBlock:^(KS3FileUploader *uploader, double progress) {
                NSLog(@"progress: %f", progress);
            } completeBlock:^(KS3FileUploader *uploader) {
                NSLog(@"complete");
            } failedBlock:^(KS3FileUploader *uploader, NSString *strUploadId, NSInteger partNumber, NSError *error) {
                NSLog(@"failed!");
            }];
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

#pragma mark - KingSoftServiceRequestDelegate
- (void)request:(KS3ServiceRequest *)request didCompleteWithResponse:(KS3ServiceResponse *)response
{
    _upLoadCount++;
    NSLog(@"################################## %ld",_upLoadCount);
    if (_partInter == _upLoadCount) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        NSLog(@"upload id: %@", _muilt.uploadId);
        NSLog(@"body: %@", [[NSString alloc] initWithData:response2.body encoding:NSUTF8StringEncoding]);
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        KS3CompleteMultipartUploadResponse *res = [[KS3Client initialize] completeMultipartUpload:req];
        NSLog(@"complete res body: %@", [[NSString alloc] initWithData:res.body encoding:NSUTF8StringEncoding]);
    }
}

- (void)request:(KS3ServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error.description);
}

- (void)request:(KS3ServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceive response");
}

- (void)request:(KS3ServiceRequest *)request didReceiveData:(NSData *)data
{
    NSLog(@"didReceive data");
}

-(void)request:(KS3ServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    // progress
}

@end
