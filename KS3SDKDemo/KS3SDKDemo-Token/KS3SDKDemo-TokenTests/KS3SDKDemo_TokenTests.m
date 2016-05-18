//
//  KS3SDKDemo_TokenTests.m
//  KS3SDKDemo-TokenTests
//
//  Created by JackWong on 15/4/28.
//  Copyright (c) 2015年 Jack Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "../../../Framework/StaticFramework/KS3YunSDK.framework/Headers/KS3YunSDK.h"

@interface KS3SDKDemo_TokenTests : XCTestCase

@end

@implementation KS3SDKDemo_TokenTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    NSURL *tokenUrl = [NSURL URLWithString:@"http://127.0.0.1:3000/token"];
    NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
                                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                 timeoutInterval:10];
    NSData *dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
    [tokenRequest setURL:tokenUrl];
    [tokenRequest setHTTPMethod:@"POST"];
    [tokenRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [tokenRequest setHTTPBody:dataParams];
    [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"#### 获取token成功! #### token: %@", strToken);
            XCTAssertNotNil(strToken);
            
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


@end
