//
//  KS3YunSDKTests.m
//  KS3YunSDKTests
//
//  Created by JackWong on 12/18/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KS3YunSDK.h>

NSString *const strAccessKey = @"IYh4GQWndtnQvmCJWFL4";
NSString *const strSecretKey = @"1+RBTrWaeT6LaixUV5SGPFpeTa/wZEeZlGzYaZfr";

@interface KS3YunSDKTests : XCTestCase

@end

@implementation KS3YunSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    [[KS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testAll
{
    [self testLisetBuckets];
    [self testCreateBucket];
    [self testHeadObject];
}

- (void)testLisetBuckets
{
    KS3ListBucketsRequest *listBucketRequest = [[KS3ListBucketsRequest alloc] init];
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               listBucketRequest.httpMethod,  @"http_method",
                               listBucketRequest.contentMd5,  @"content_md5",
                               listBucketRequest.contentType, @"content_type",
                               listBucketRequest.strDate,     @"date",
                               listBucketRequest.kSYHeader,   @"headers",
                               listBucketRequest.kSYResource, @"resource", nil];
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
            listBucketRequest.strKS3Token = strToken;
            NSArray *bucketArray = [[KS3Client initialize] listBuckets:listBucketRequest];
            for (KS3Bucket *bucket in bucketArray ) {
                NSLog(@"%@",bucket.creationDate);
                NSLog(@"%@",bucket.name);
            }
        }
        else {
            NSLog(@"#### 获取token失败，error: %@", connectionError);
        }
    }];
}

- (void)testCreateBucket
{
    KS3CreateBucketRequest *req = [[KS3CreateBucketRequest alloc] initWithName:@"gggg"];
    KS3CreateBucketResponse *response = [[KS3Client initialize] createBucket:req];
    NSLog(@"%@",response.description);
    NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
    NSLog(@"%d",response.httpStatusCode);
    XCTAssertEqual(200, response.httpStatusCode);
}

- (void)testDeleteBucket
{
    KS3DeleteBucketRequest *req = [[KS3DeleteBucketRequest alloc] initWithName:@"ggg"];
    KS3DeleteBucketResponse *response = [[KS3Client initialize] deleteBucket:req];
    XCTAssertEqual(204, response.httpStatusCode);
}

- (void)testGetBucketAcl
{
    KS3GetACLRequest *getBucketAclReq = [[KS3GetACLRequest alloc] initWithName:@"ggg"];
    NSDictionary *dicParams = [self dicParamsWithReq:getBucketAclReq];
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
            getBucketAclReq.strKS3Token = strToken;
            KS3GetACLResponse *response = [[KS3Client initialize] getBucketACL:getBucketAclReq];
            KS3BucketACLResult *result = response.listBucketsResult;
            XCTAssert(response.httpStatusCode == 200);
            if (response.httpStatusCode == 200) {
                NSLog(@"Get bucket acl success!");
                
                NSLog(@"Bucket owner ID:          %@",result.owner.ID);
                NSLog(@"Bucket owner displayName: %@",result.owner.displayName);
                
                for (KS3Grant *grant in result.accessControlList) {
                    XCTAssertNotNil(grant.permission);
                    XCTAssertNotNil(grant.grantee);
                }
            }
            else {
                NSLog(@"Get bucket acl error: %@", response.error.description);
            }
        }
        else {
            NSLog(@"#### 获取token失败，error: %@", connectionError);
        }
    }];
}

- (void)testSetBucktAcl
{
    KS3SetACLRequest *setBucketACLReq = [[KS3SetACLRequest alloc] initWithName:@"ggg" accessACL:nil];
    NSDictionary *dicParams = [self dicParamsWithReq:setBucketACLReq];
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
            setBucketACLReq.strKS3Token = strToken;
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Private];
            setBucketACLReq.acl = acl;
            KS3SetACLResponse *response = [[KS3Client initialize] setBucketACL:setBucketACLReq];
            XCTAssert(response.httpStatusCode == 200);
        }
        else {
            NSLog(@"#### 获取token失败，error: %@", connectionError);
        }
    }];
}

- (void)testGetBucketLogging
{
    KS3GetBucketLoggingRequest *getBucketLoggingReq = [[KS3GetBucketLoggingRequest alloc] initWithName:@"testCreateBucket-WF1"];
    NSDictionary *dicParams = [self dicParamsWithReq:getBucketLoggingReq];
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
            getBucketLoggingReq.strKS3Token = strToken;
            KS3GetBucketLoggingResponse *response = [[KS3Client initialize] getBucketLogging:getBucketLoggingReq];
            XCTAssert(response.httpStatusCode == 200);
        }
        else {
            NSLog(@"#### 获取token失败，error: %@", connectionError);
        }
    }];
}

- (void)testPutObject
{
    KS3PutObjectRequest *req = [[KS3PutObjectRequest alloc] initWithName:@"ggg" withAcl:nil grantAcl:nil];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Test" ofType:@"jpg"];
    req.data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    req.filename = [path lastPathComponent];
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:req];
    //    KSS3PutObjectResponse *response = [[KS3Client initialize] putObjectWithBucketName:@"testCreateBucket-WF1"];
    NSLog(@"- = -= - =- = -= -%@",[response.error description]);
    NSLog(@"-=-=-=-=--=-=--=-=%@",[[NSString alloc] initWithData:[response body]  encoding:NSUTF8StringEncoding]);
    XCTAssertEqual(200, response.httpStatusCode);
}

- (void)testPutObjectCopy
{
    KS3BucketObject *destBucketObj = [[KS3BucketObject alloc] initWithBucketName:@"ggg" keyName:@"test_copy.txt"];
    KS3BucketObject *sourceBucketObj = [[KS3BucketObject alloc] initWithBucketName:@"acc" keyName:@"Count_1.txt"];
    KS3PutObjectCopyRequest *req = [[KS3PutObjectCopyRequest alloc] initWithName:destBucketObj sourceBucketObj:sourceBucketObj];
    KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:req];
    XCTAssertEqual(200, response.httpStatusCode);
}

- (void)testHeadObject
{
    KS3HeadObjectRequest *req = [[KS3HeadObjectRequest alloc] initWithName:@"ggg" withKeyName:@"Test.jpg"];
    KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:req];
    NSLog(@"%d",response.httpStatusCode);
    NSLog(@"- = -= - =- = -= -%@",[response.error description]);
    NSLog(@"-=-=-=-=--=-=--=-=%@",[[NSString alloc] initWithData:[response body]  encoding:NSUTF8StringEncoding]);
    XCTAssertEqual(200, response.httpStatusCode);
}
- (void)testDeleteObject{
    KS3DeleteObjectRequest *req = [[KS3DeleteObjectRequest alloc] initWithName:@"ggg" withKeyName:@"Test.jpg"];
    KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:req];
    NSLog(@"- = -= - =- = -= -%d",response.httpStatusCode);
    XCTAssertEqual(204, response.httpStatusCode);
}

- (void)testGetObjectACL
{
    KS3GetObjectACLRequest *req = [[KS3GetObjectACLRequest alloc] initWithName:@"ggg" withKeyName:@"Test.jpg"];
    KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:req];
    NSLog(@"-=-=-=-=--=-=--=-=%@",[[NSString alloc] initWithData:[response body]  encoding:NSUTF8StringEncoding]);
    
    XCTAssertEqual(200, response.httpStatusCode);
    NSArray *controlListArray = response.listBucketsResult.accessControlList;
    for (KS3Grant *grant in controlListArray) {
        NSLog(@"%@",grant.permission);
        XCTAssertNotNil(grant.permission);
        XCTAssertNotNil(grant.grantee);
    }
}

- (void)testSetObjectACL
{
    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
    KS3SetObjectACLRequest *req = [[KS3SetObjectACLRequest alloc] initWithName:@"ggg" withKeyName:@"Test.jpg" acl:acl];
    KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:req];
    NSLog(@"%@",[response.error description]);
    NSLog(@"-----%@",[[NSString alloc] initWithData:[response body]  encoding:NSUTF8StringEncoding]);
    XCTAssertEqual(200, [response httpStatusCode]);
}

- (void)testListObject
{
    KS3ListObjectsRequest  *req = [[KS3ListObjectsRequest alloc] initWithName:@"ggg"] ;
    //    req.prefix = @"r32/tew3";
    //    req.delimiter = @"c";
    //    req.maxKeys = 5;
//    NSLog(@"-=-=-=-=--=-=--=-=%@",[[KS3Client initialize] listObjects:req]);
    NSLog(@"-=-=-=-=--=-=--=-=%@",[[NSString alloc] initWithData:[[[KS3Client initialize] listObjects:req] body]  encoding:NSUTF8StringEncoding]);
}
- (void)testBucketLogging
{
//    KS3SetBucketLoggingRequest *req = [[KS3SetBucketLoggingRequest alloc] initWithName:@"acc"];
//    KS3SetBucketLoggingResponse *response = [[KS3Client initialize] setBucketLogging:req];
//    XCTAssertEqual(200, [response httpStatusCode]);
}

- (void)testFKUpload
{
//    NSInteger _upLoadCount = 0;
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"500M" ofType:@"txt"]];
//    long long fileLength = [[fileHandle availableData] length];
//    long long partLength = 100*1024.0*1024.0;
//    NSInteger partNumber = (ceilf((float)fileLength / (float)partLength));
//    NSLog(@"%lld",fileLength);
//    NSLog(@"%lld",partLength);
//    NSLog(@"%ld",(long)partNumber);
//    [fileHandle seekToFileOffset:0];
//    KS3MultipartUpload *muilt = [[KS3Client initialize] initiateMultipartUploadWithKey:@"500.txt" withBucket:@"testCreateBucket-WF1"];
//    for (NSInteger i = 0; i < partNumber; i ++) {
//        NSData *data = nil;
//        if (i == partNumber - 1) {
//            data = [fileHandle readDataToEndOfFile];
//        }else {
//            data = [fileHandle readDataOfLength:(NSUInteger)partLength];
//            [fileHandle seekToFileOffset:partLength*(i+1)];
//        }
//        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:muilt];
//        req.data = data;
//        req.partNumber = (int32_t)i+1;
//        req.contentLength = data.length;
//        KS3UploadPartResponse *response11 = [[KS3Client initialize] uploadPart:req];
//        XCTAssertEqual(200, response11.httpStatusCode);
//        if (response11) {
//            _upLoadCount++;
//            if (partNumber == _upLoadCount) {
//                NSLog(@"%ld",(long)partNumber);
//                NSLog(@"%ld",(long)_upLoadCount);
//                KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:muilt];
//                KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
//                XCTAssertEqual(200, response2.httpStatusCode);
//                KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:muilt];
//                NSLog(@"%@",response2.listResult.parts);
//                for (KS3Part *part in response2.listResult.parts) {
//                    [req addPartWithPartNumber:part.partNumber withETag:part.etag];
//                }
//                XCTAssertEqual(200, [((KS3CompleteMultipartUploadResponse *)[[KS3Client initialize] completeMultipartUpload:req]) httpStatusCode]);
//            }
//        }
//    }
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
        
    }];
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

@end
