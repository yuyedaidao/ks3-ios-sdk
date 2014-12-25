//
//  BucketViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#warning Please set correct bucket name
#define kBucketName @"alert1"

#import "BucketViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>

@interface BucketViewController ()

@property (nonatomic, strong) NSArray *arrItems;

@end

@implementation BucketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Bucket";
    _arrItems = [NSArray arrayWithObjects:
                 @"Create Bucket",      @"Delete Bucket", @"Head Bucket",
                 @"Get Bucket ACL",     @"Set Bucket ACL", @"Set Bucket Grant ACL",
                 @"Get Bucket Logging", @"Set Bucket Logging",
                 @"Get All Objects In Bucket", nil];
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
    }
    cell.textLabel.text = _arrItems[indexPath.row];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"";
    switch (indexPath.row) {
        case 0:
        {
            strIdentifier = @"Create Bucket Identifier";
            [self performSegueWithIdentifier:strIdentifier sender:nil];
        }
            break;
        case 1:
        {
            KS3DeleteBucketResponse *response = [[KS3Client initialize] deleteBucketWithName:@"uuu"];
            if (response.httpStatusCode == 204) { // **** 没有返回任何内容
                NSLog(@"Delete bucket success!");
            }
            else {
                NSLog(@"Delete bucket error: %@", response.error.description);
            }
        }
            break;
        case 2:
        {
            KS3HeadBucketRequest *request = [[KS3HeadBucketRequest alloc] initWithName:kBucketName];
            KS3HeadBucketResponse *responsee = [[KS3Client initialize] headBucket:request];
            if (responsee.httpStatusCode == 200) {
                NSLog(@"Head bucket success");
            }
            else {
                NSLog(@"Head bucket error: %@", responsee.error.description);
            }
        }
            break;
        case 3:
        {
            KS3GetACLResponse *response = [[KS3Client initialize] getBucketACL:kBucketName];
            KS3BucketACLResult *result = response.listBucketsResult;
            if (response.httpStatusCode == 200) {
                NSLog(@"Get bucket acl success!");
                
                NSLog(@"Bucket owner ID:          %@",result.owner.ID);
                NSLog(@"Bucket owner displayName: %@",result.owner.displayName);
                
                for (KS3Grant *grant in result.accessControlList) {
                    NSLog(@"%@",grant.grantee.ID);
                    NSLog(@"%@",grant.grantee.displayName);
                    NSLog(@"%@",grant.grantee.URI);
                    NSLog(@"_______________________");
                    NSLog(@"%@",grant.permission);
                }
            }
            else {
                NSLog(@"Get bucket acl error: %@", response.error.description);
            }
        }
            break;
        case 4:
        {
            KS3SetACLRequest *setACLRequest = [[KS3SetACLRequest alloc] initWithName:kBucketName];
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Public_Read];
            setACLRequest.acl = acl;
            KS3SetACLResponse *response = [[KS3Client initialize] setACL:setACLRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set bucket acl success!");
            }
            else {
                NSLog(@"Set bucket acl error: %@", response.error.description);
            }
        }
            break;
        case 5:
        {
            KS3SetGrantACLRequest *setGrantACLRequest = [[KS3SetGrantACLRequest alloc] initWithName:kBucketName];
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            acl.identifier = @"4567894346";
            acl.displayName = @"accDisplayName";
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            setGrantACLRequest.acl = acl;
            KS3SetGrantACLResponse *response = [[KS3Client initialize] setGrantACL:setGrantACLRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set bucket grant acl success!");
            }
            else {
                NSLog(@"Set bucket grant acl error: %@", response.error.description);
            }
        }
            break;
        case 6:
        {
            KS3GetBucketLoggingResponse *response = [[KS3Client initialize] getBucketLoggingWithName:kBucketName];
            if (response.httpStatusCode == 200) {
                NSLog(@"Get bucket logging success!");
            }
            else {
                NSLog(@"Get bucket logging error: %@", response.error.description);
            }
        }
            break;
        case 7:
        {
            NSLog(@"移动端暂不支持");
        }
            break;
        case 8:
            strIdentifier = @"Get All Objects In Bucket Identifier";
            [self performSegueWithIdentifier:strIdentifier sender:nil];
            break;
        default:
            break;
    }
}


@end
