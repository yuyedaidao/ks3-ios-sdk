//
//  CreateBucketViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "CreateBucketViewController.h"
#import <KS3YunSDK.h>

#import "KS3Util.h"
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
    [createBucketReq setCompleteRequest];
     //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    [createBucketReq setStrKS3Token:[KS3Util getAuthorization:createBucketReq]];
    KS3CreateBucketResponse *response = [[KS3Client initialize] createBucket:createBucketReq];
    if (response.httpStatusCode == 200) {
        NSLog(@"Create bucket success!");
    }
    else {
        NSLog(@"error: %@", response.error.localizedDescription);
    }
}


@end
