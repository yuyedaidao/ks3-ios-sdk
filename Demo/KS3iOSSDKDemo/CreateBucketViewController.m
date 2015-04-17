//
//  CreateBucketViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "CreateBucketViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>

@interface CreateBucketViewController ()

@property (nonatomic, strong) IBOutlet UITextField *nameField;

@end

@implementation CreateBucketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"创建Bucket";
}

- (IBAction)clickCreateBtn:(id)sender
{
    NSString *strBucketName = _nameField.text;
    KS3CreateBucketRequest *createBucketReq = [[KS3CreateBucketRequest alloc] initWithName:strBucketName];
//    NSDictionary *dicParams = [self dicParamsWithReq:createBucketReq];
//    
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
//            [createBucketReq setStrKS3Token:strToken];
//            KS3CreateBucketResponse *response = [[KS3Client initialize] createBucket:createBucketReq];
//            if (response.httpStatusCode == 200) {
//                NSLog(@"Create bucket success!");
//            }
//            else {
//                NSLog(@"error: %@", response.error.localizedDescription);
//            }
//        }
//        else {
//            NSLog(@"#### 获取token失败，error: %@", connectionError);
//        }
//    }];
    KS3CreateBucketResponse *response = [[KS3Client initialize] createBucket:createBucketReq];
    if (response.httpStatusCode == 200) {
        NSLog(@"Create bucket success!");
    }
    else {
        NSLog(@"error: %@", response.error.localizedDescription);
    }
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
