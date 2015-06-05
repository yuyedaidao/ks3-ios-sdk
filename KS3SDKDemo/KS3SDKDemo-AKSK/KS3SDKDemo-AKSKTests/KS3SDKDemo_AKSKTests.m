//
//  KS3SDKDemo_AKSKTests.m
//  KS3SDKDemo-AKSKTests
//
//  Created by JackWong on 15/4/28.
//  Copyright (c) 2015年 Jack Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KS3YunSDK/KS3YunSDK.h>

@interface KS3SDKDemo_AKSKTests : XCTestCase

@end

@implementation KS3SDKDemo_AKSKTests

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
    
//    NSLog(@"-----%@",[KSYHardwareInfo checkNetworkType]);
    
    @try {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ksss.ksyun.com"]];
        NSError *error = nil;
        NSURLResponse *response = [[NSURLResponse alloc] init];
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"%@",[error description]);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
//        NSLog(@"%@",);
//        NSString *networkinfo = [KSYHardwareInfo getMobileNetworkInfo];
//        NSLog(@"---------%@",networkinfo);

    }];
}



@end
