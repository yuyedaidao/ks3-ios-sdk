//
//  KS3YunSDK_LogTests.m
//  KS3YunSDK
//
//  Created by JackWong on 15/6/3.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KS3YunSDK.h"
#import "KSYHardwareInfo.h"
#import "KS3Util.h"
#import "KSYMacroDefinition.h"

@interface KS3YunSDK_LogTests : XCTestCase <KingSoftServiceRequestDelegate>{
    XCTestExpectation *muiltException;
}
@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (assign, nonatomic) NSInteger partSize;
@property (assign, nonatomic) long long fileSize;
@property (assign, nonatomic) long long partLength;
@property (nonatomic) NSInteger totalNum;
@property (nonatomic) NSInteger uploadNum;
@property (nonatomic, strong) NSString *bucketName;
@property (strong, nonatomic)  KS3MultipartUpload *muilt;
@end

@implementation KS3YunSDK_LogTests

- (void)setUp {
    [super setUp];
    [[KS3Client initialize] connectWithAccessKey:strLogTestAccessKey withSecretKey:strLogTestSecretKey];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        
    }];
}
//#pragma mark --PutObject
//TODO: PutObject
- (void)testPutObject
{
    KS3AccessControlList *ControlList = [[KS3AccessControlList alloc] init];
    [ControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
    KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
    acl.identifier = @"4567894346";
    acl.displayName = @"accDisplayName";
    [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
    KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:@"acc"
                                                                           withAcl:ControlList
                                                                          grantAcl:@[acl]];
//    NSURL *fileName = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"png"];
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"test.png"];
//    NSLog(@"%@",fileName);
    NSLog(@"filePath: -- %@",filePath);
    XCTAssertNotNil(filePath);
    putObjRequest.data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    XCTAssertNotNil(putObjRequest.data);
    putObjRequest.filename = @"test-006.jpg";//kTestSpecial10;//[fileName lastPathComponent];
    //            putObjRequest.callbackUrl = @"http://123.59.36.81/index.php/api/photos/callback";
    //            putObjRequest.callbackBody = @"location=${kss-location}&name=${kss-name}&uid=8888";
    //            putObjRequest.callbackParams = @{@"kss-location": @"china_location", @"kss-name": @"lulu_name"};
    putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
    [putObjRequest setCompleteRequest];
    
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
    NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
    NSLog(@"responseHeader --- -%@",response.responseHeader);
    if (response.httpStatusCode == 200) {
        NSLog(@"Put object success");
    }
    else {
        NSLog(@"%@",[response.error description]);
        NSLog(@"Put object failed");
    }
    
    NSLog(@"----%@",response.exception.message);
    NSLog(@"-----%@",response.exception.errorCode);
    XCTAssertNil(response.exception);
    XCTAssertEqual(response.httpStatusCode, 200);
}

- (void)testDownLoad
{
    
    [[KS3Client initialize] downloadObjectWithBucketName:@"ggg" key:@"Test.jpg"  downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
        NSLog(@"start");
    } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
        NSLog(@"%@",filePath);
        
    } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
        NSLog(@"%f",newProgress);
        
    } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
        NSLog(@"%@",[error description]);
        XCTFail(@"filed");
        
    }];
}

- (void)testIninUpLoad
{
//    muiltException = [self expectationWithDescription:@"muiltException"];
    NSString *strKey = @"ksynvshengpai111000111.text";//@"+-.txt";
    NSString *strFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"test.png"];
     XCTAssertNotNil(strFilePath);
    _partSize = 5;
    _fileHandle = [NSFileHandle fileHandleForReadingAtPath:strFilePath];
    XCTAssertNotNil(_fileHandle);
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
     muiltException = [self expectationWithDescription:@"aaa"];
    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:KingSoftYun_Permission_Private];
    KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:@"acc" acl:acl grantAcl:nil];
    [initMultipartUploadReq setCompleteRequest];
    _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
    if (_muilt == nil) {
        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
        return ;
    }
    
    _uploadNum = 1;
    long long partLength = _partSize * 1024.0 * 1024.0;
    NSData *data = nil;
    if (_uploadNum == _totalNum) {
        data = [_fileHandle readDataToEndOfFile];
    }else {
        data = [_fileHandle readDataOfLength:(NSUInteger)partLength];
        [_fileHandle seekToFileOffset:partLength*(_uploadNum)];
    }
//    
//    for (NSInteger i = 0; i < _totalNum; i ++) {
//        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt partNumber:(int32_t)_uploadNum data:data generateMD5:NO];
//        req.delegate = self;
//        req.contentLength = data.length;
//        req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
//        [req setCompleteRequest];
//        [[KS3Client initialize] uploadPart:req];
//    }
    [self waitForExpectationsWithTimeout:100.0 handler:^(NSError *error) {
        
    }];
}

- (void)uploadWithPartNumber:(NSInteger)partNumber
{
   
 
}

#pragma mark - Delegate
- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    _uploadNum ++;
    if (_totalNum < _uploadNum) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        [req2 setCompleteRequest];
        
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        
        
        
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        //        req.callbackUrl = @"http://123.59.36.81/index.php/api/photos/callback";
        //        req.callbackBody = @"location=${kss-location}&name=${kss-name}&uid=8888";
        //        req.callbackParams = @{@"kss-location": @"china_location", @"kss-name": @"lulu_name"};
        //        req参数设置完一定要调这个函数
        [req setCompleteRequest];
        KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
        if (resp.httpStatusCode != 200) {
            NSLog(@"#####complete multipart upload failed!!! code: %d#####", resp.httpStatusCode);
        }
        [muiltException fulfill];
        
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
