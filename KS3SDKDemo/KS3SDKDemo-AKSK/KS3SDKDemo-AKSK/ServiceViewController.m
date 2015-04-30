//
//  ServiceViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "ServiceViewController.h"

@interface ServiceViewController ()

@property (nonatomic, strong) NSArray *arrItems;

@end

@implementation ServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Service";
    _arrItems = [NSArray arrayWithObjects:@"List Buckets", nil];
}

#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"service identifier";
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
            strIdentifier = @"List Bucket Identifier";
            break;
        default:
            break;
    }
    [self performSegueWithIdentifier:strIdentifier sender:nil];
}

@end
