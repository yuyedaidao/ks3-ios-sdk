//
//  VideoViewController.m
//  KS3SDKDemo-Token
//
//  Created by Marlon Chan on 16/6/27.
//  Copyright © 2016年 Jack Wong. All rights reserved.
//

#define mUserDefaults       [NSUserDefaults standardUserDefaults]
//上传
#define kUploadBucketName @"gzz-beijing"   //上传所用的bucketName
#define kUploadBucketKey @"wz/7.6M.mov"  //上传时用到的bucket里文件的路径，此为在wz目录下7.6M.mov


#import "VideoViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>
#import "KS3Util.h"
//#import "AppDelegate.h"

@interface VideoViewController () <KingSoftServiceRequestDelegate>

@property (nonatomic, strong) NSArray *arrItems;
@property (assign, nonatomic) long long fileSize;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Video";
    _arrItems = [NSArray arrayWithObjects:@"视频转码(utp)", @"视频截图(adp)",  nil];
    
}


- (void)beginSingleUpload
{
    KS3AccessControlList *ControlList = [[KS3AccessControlList alloc] init];
    [ControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
    KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kUploadBucketName withAcl:ControlList grantAcl:nil];
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"7.6M" ofType:@"mov"];
    putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
    _fileSize = putObjRequest.data.length;
    
    putObjRequest.delegate = self;
    putObjRequest.filename = kUploadBucketKey;
    //            putObjRequest.callbackUrl = @"http://123.59.36.81/index.php/api/photos/callback";
    //            putObjRequest.callbackBody = @"location=${kss-location}&name=${kss-name}&uid=8888";
    //            putObjRequest.callbackParams = @{@"kss-location": @"china_location", @"kss-name": @"lulu_name"};+
    putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
    
    //视频转码命令
    NSString* utpCommand =[NSString stringWithFormat:@"tag=avop&f=flv&res=x480&as=1&vbr=128k|tag=saveas&bucket=%@&object=%@",kUploadBucketName, [[@"result.flv" dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]] ;
    putObjRequest.kSYHeader = [putObjRequest.kSYHeader stringByAppendingString:[@"kss-async-process:" stringByAppendingString:utpCommand]];
    putObjRequest.kSYHeader = [NSString stringWithFormat:@"%@\n",putObjRequest.kSYHeader];
    putObjRequest.kSYHeader = [@"kss-notifyurl:" stringByAppendingString: @"http://10.4.2.38:19090/"];
    putObjRequest.kSYHeader = [NSString stringWithFormat:@"%@\n",putObjRequest.kSYHeader];

    [putObjRequest setCompleteRequest];
    
    //生产环境应从Appserver获取token后设置token，此处使用Ak sk计算token模拟
    [putObjRequest setStrKS3Token:[KS3Util getAuthorization:putObjRequest]];
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
    
    
    //putObjRequest若没设置代理，则是同步的下方判断，
    //putObjRequest若设置了代理，则走上传代理回调,
    if (putObjRequest.delegate == nil) {
        NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
        if (response.httpStatusCode == 200) {
            NSLog(@"Put object success");
        }
        else {
            NSLog(@"Put object failed");
        }
    }
    
}



#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: //utp
        {
            [self beginSingleUpload];
            
        }
            break;
        case 1: //adp
        {
            
        }
            break;
        default:
            break;
    }
}


#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"Video identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    cell.textLabel.text = _arrItems[indexPath.row];
    return cell;
}


#pragma mark - request delegate

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    
    if ([request isKindOfClass:[KS3PutObjectRequest class]]) {
        if (response.httpStatusCode == 200) {
            NSLog(@"请求成功");
        }else
        {
            NSLog(@"请求失败");
        }
        
        return;
    }
}

- (void)request:(KS3Request *)request didFailWithError:(NSError *)error
{
    NSLog(@"upload error: %@", error);
}

- (void)request:(KS3Request *)request didReceiveResponse:(NSURLResponse *)response
{
    NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
    if ( (statusCode>= 200 && statusCode <300) || statusCode == 304) {
        NSLog(@"Put object success");
    }
    else {
        NSLog(@"Put object failed");
    }
    
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
    
    
    UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:199];
    UIButton *button = (UIButton *)[self.view viewWithTag:200];
    
    if ([request isKindOfClass:[KS3PutObjectRequest class]]) {
        
        long long alreadyTotalWriten = totalBytesWritten;
        double progress = alreadyTotalWriten * 1.0  / _fileSize;
        NSLog(@"upload progress: %f", progress);
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
