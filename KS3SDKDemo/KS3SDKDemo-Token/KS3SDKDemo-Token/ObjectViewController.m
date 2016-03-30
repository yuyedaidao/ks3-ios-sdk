//
//  ObjectViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/17/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//



/*
   KS3 API文档：http://ks3.ksyun.com/doc/index.html
  开发前请阅读： KS3 - iOS -SDK 文档地址 https://github.com/ks3sdk/ks3-ios-sdk
   KS3 存储控制台地址 http://www.ksyun.com/user/login?
 
  上传下载几点概念术语必读：

 AccessKey（访问秘钥）、SecretKey
     使用KS3，您需要KS3颁发给您的AccessKey（长度为20个字符的ASCII字符串）和SecretKey（长度为40个字符的ASCII字符串）。AccessKey用于标识客户的身份，SecretKey作为私钥形式存放于客户服务器不在网络中传递。SecretKey通常用作计算请求签名的密钥，用以保证该请求是来自指定的客户。使用AccessKey进行身份识别，加上SecretKey进行数字签名，即可完成应用接入与认证授权。AK/SK在AppDelegate.m 里配置，模拟app服务器返回token
 
 Bucket（存储空间）
     Bucket是存放Object的容器，所有的Object都必须存放在特定的Bucket中。每个用户最多可以创建20个Bucket，每个Bucket中可以存放无限多个Object。Bucket不能嵌套，每个Bucket中只能存放Object，不能再存放Bucket，Bucket下的Object是一个平级的结构。Bucket的名称全局唯一且命名规则与DNS命名规则相同：
     仅包含小写英文字母（a-z），数字，点（.），中线，即： abcdefghijklmnopqrstuvwxyz0123456789.-
     必须由字母或数字开头
     长度在3和255个字符之间
     不能是IP的形式，类似192.168.0.1
     不能以kss开头
 
 Object（对象，文件）
     在KS3中，用户操作的基本数据单元是Object。单个Object允许存储0~5TB的数据。 Object 包含key和data。其中，key是Object的名字；data是Object 的数据。key为UTF-8编码，且编码后的长度不得超过1024个字节。
 
 Key（文件名）
     即Object的名字，key为UTF-8编码，且编码后的长度不得超过1024个字节。Key中可以带有斜杠，当Key中带有斜杠的时候，将会自动在控制台里组织成目录结构。
 
 ACL（访问控制权限）
     对Bucket和Object相关访问的控制策略，例如允许匿名用户公开访问等。
     目前ACL支持READ, WRITE, FULL_CONTROL三种权限。对于bucket的拥有者,总是FULL_CONTROL。可以授予所有用户(包括匿名用户)或指定用户READ， WRITE, 或者FULL_CONTROL权限。
     目前提供了三种预设的ACL.分别是private、public-read和public-read-write。public-read表示为所有用户授予READ权限，public-read-write表示为所有用户授予WRITE权限.使用的时候通过在header中添加x-kss-acl实现。
     对于BUCKET来说，READ是指罗列Bucket中的文件、罗列Bucket中正在进行的分块上传、罗列某个分块上传已经上传的块。WRITE是指可以上传，删除BUCKET中文件的功能。FULL_CONTROL则包含所有操作。可以通过PUT Bucket acl接口设置。
     对于Object来说，READ是指查看或者下载文件的功能。WRITE无意义。FULL_CONTROL则包含所有操作。可以通过PUT Object acl设置。
 
 * 创建bucket时需要选择Region,如遇到上传卡住或超时，请修改替换工程中对应的外网域名，SDK默认杭州
     Region中文名称	           外网域名	                                      内网域名
     中国（杭州）	        kss.ksyun.com	                             kss-internal.ksyun.com
     中国（北京）	        ks3-cn-beijing.ksyun.com	         ks3-cn-beijing-internal.ksyun.com
     美国（圣克拉拉）	ks3-us-west-1.ksyun.com           ks3-us-west-1-internal.ksyun.com
     中国（香港）	        ks3-cn-hk-1.ksyun.com	             ks3-cn-hk-1-internal.ksyun.com
 
 */

#warning Please set correct bucket and object name

//Demo下载文件的地址：http://ecloud.kssws.ks-cdn.com/test2/Test.pdf

//上传
#define kBucketName @"acc"//@"alert1"//@"bucketcors"//@"alert1"
#define kUploadBucketName @"ks3testupload"   //上传所用的bucketName
#define kUploadBucketKey @"7.6M.mov"  //上传时用到的bucket里文件的路径，此为在根目录下7.6M.mov

//下载
#define kDownloadBucketName @"ecloud"//下载所用的bucketName
#define kDownloadBucketKey @"test2/Test.pdf"   //下载的地址拼接
#define kDownloadSize 21131496   //Demo下载文件的大小，根据业务需求，显示进度条时用到，需要记录


#define kObjectName @"Count_1.txt"//@"test_download.txt"//@"bug.txt"
#define kDesBucketName @"blues11"//@"ggg"//
#define kDesObjectName @"bug_copy.txt"
#define kObjectSpecial1 @"+-.jpg"
#define kObjectSpecial2 @"+-.txt"

#define mScreenWidth          ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight         ([UIScreen mainScreen].bounds.size.height)
#define FileBlockSize 5*1024*1024   //一块大小
#import "ObjectViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>
#import "KS3Util.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ObjectViewController () <KingSoftServiceRequestDelegate>
@property (nonatomic, strong) NSArray *arrItems;
@property (nonatomic, strong) KS3DownLoad *downloader;

@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (assign, nonatomic) NSInteger partSize;
@property (assign, nonatomic) long long fileSize;
@property (assign, nonatomic) long long partLength;
@property (nonatomic) NSInteger totalNum;
@property (nonatomic) NSInteger uploadNum;
@property (nonatomic, strong) NSString *bucketName;
@property (strong, nonatomic)  KS3MultipartUpload *muilt;

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
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:@"删除已下载" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(deleteFinishedFile) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn] ;
    
    //向模拟器相册，存储一段测试视频，用于模拟相册分块上传
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"SavedVideo"] == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SavedVideo"];
        NSString *path = [[NSBundle mainBundle]pathForResource:@"7.6M" ofType:@"mov"];
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error){
        NSLog(@"本地保存失败");
    }else {
        NSLog(@"本地保存成功");
    }
}

- (void)deleteFinishedFile
{
    NSString *strHost = [NSString stringWithFormat:@"http://%@.ks3-cn-beijing.ksyun.com/%@", kDownloadBucketName, kDownloadBucketKey];
    NSString  *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];;
    //文件临时文件地址，计算百分比
    NSString *  temporaryPath = [filePath stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.%@",[strHost MD5Hash],@"pdf"]];
    if ( [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil]) {
        UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:99];
        UIButton *stopBtn = (UIButton *)[self.view viewWithTag:100];
        progressView.progress = 0;
        [stopBtn setTitle:@"开始" forState:UIControlStateNormal];
        stopBtn.selected = NO;
    }else
    {
        NSLog(@"移除失败");
    }
    
    
}

#pragma mark TouchEvents
- (void)downloadBtnClicked:(UIButton *)btn
{
    if ([btn.titleLabel.text isEqualToString:@"完成"]) {
        NSLog(@"文件下载完成，请删除重试");
        return;
    }
    
    btn.selected =! btn.selected;
    if (btn.selected ) {
        [btn setTitle:@"暂停 " forState:UIControlStateNormal];
        [self beginDownload];
        
    }else
    {
        [btn setTitle:@"继续 " forState:UIControlStateNormal];
        [self stopDownload];
    }
}



- (void)uploadBtnClicked:(UIButton *)btn
{
    btn.selected =! btn.selected;
    if (btn.selected) {
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [self beginUpload];
    }else
    {
        [btn setTitle:@"开始" forState:UIControlStateNormal];
        [self cancelUpload];
    }
}

#pragma mark 相册方法

/*获取alasset的方法
 
      url:相册URL开头是alasset-的地址，由Alasset类里defaultRepresentation属性的url获得;
 */
- (ALAsset *)getAlassetFromAlassetURL:(NSURL *)url
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    __block ALAsset *assets ;
    dispatch_semaphore_t sem= dispatch_semaphore_create(0);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(concurrentQueue, ^{
        
        [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            //本地存储的上传文件
            assets = asset;
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            NSLog(@"读取AssetURL出错,%@",error.localizedDescription);
            dispatch_semaphore_signal(sem);
        }];

    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return assets;
}

/*
 这里，枚举模拟器相册所有的视频，模拟器只有一个只能获得开头传入的7.6M视频，
具体工程使用时根据具体逻辑，获取到Alasset即可
 */
- (ALAsset *)getAlasset
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    __block ALAsset *assets ;
    dispatch_semaphore_t sem= dispatch_semaphore_create(0);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(concurrentQueue, ^{
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        assets = result;
                        dispatch_semaphore_signal(sem);
                        return ;
                    }
                }];
                dispatch_semaphore_signal(sem);
            }else
            {
                //                NSLog(@"group为空，枚举失败");
            }
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            
            NSLog(@"请到设置->隐私->照片中开启,访问照片库的权限");
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return assets;
}

//从相册获取分块数据用于上传，bid 是_partNum - 1
- (NSData *)getAlassetBlockData:(NSInteger)bid  withAlasset:(ALAsset *)assets{
    @autoreleasepool {
        BOOL endOfStreamReached = NO;
        NSUInteger currentOffset = bid * FileBlockSize;   //当前偏移量
        NSError    *error;
        NSMutableData *mData = [[NSMutableData alloc]init];
        while (! endOfStreamReached)
        {
            NSInteger maxLength = 256*1024;
            uint8_t readBuffer [maxLength];
            NSInteger bytesRead = [assets.defaultRepresentation getBytes:readBuffer fromOffset:currentOffset  length:maxLength error:&error];
            if (bytesRead <= 0)
            {
                //读取完了或者读取地址不正确，导致读取为空
                endOfStreamReached = YES;
                if (mData.length > 0) {
                    return mData;
                }
            } else
            {
                [mData appendBytes:readBuffer length:bytesRead];
                currentOffset += bytesRead;
                //正在读取,满5M则本地存储分块
                if (mData.length >= FileBlockSize)
                {
                    return mData;
                }
            }
        }
        return mData;
    }
}

#pragma mark 上传方法
//开始分块上传文件
- (void)beginUpload
{
    NSString *strKey = kUploadBucketKey;   //key 为在bucket下的路径，demo中为根目录下7.6M.mov路径
    _partSize = 5;    //  文件大于5M为最小5M一块

    
    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:KingSoftYun_Permission_Private];
    KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:kUploadBucketName acl:acl grantAcl:nil];
    [initMultipartUploadReq setCompleteRequest];
#warning  1.使用token签名时从Appserver获取token后设置token，这里用token方式依然用到AKSK是为了模拟从服务器获取Token 2.使用Ak sk则忽略，不需要调用
    [initMultipartUploadReq setStrKS3Token:[KS3Util getAuthorization:initMultipartUploadReq]];
    _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
    if (_muilt == nil) {
        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
        return ;
    }
#warning 选择相册还是普通方式
    _muilt.uploadType = kUploadAlasset;   //从相册读
    
    //根据文件路径不一样，有如下两种上传
    if (_muilt.uploadType == kUploadNormal) { //如果是沙盒或者工程里的文件
        //工程里，沙盒里，是沙盒路径
        NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"7.6M" ofType:@"mov"];
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:strFilePath];
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
    }else
    {
        //如果是相册里的，从这传
        ALAssetRepresentation *assetD = [self getAlasset].defaultRepresentation;
        _fileSize = assetD.size;
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
    }
    
    _uploadNum = 1;
    [self uploadWithPartNumber:_uploadNum];
}


- (void)uploadWithPartNumber:(NSInteger)partNumber
{
    @autoreleasepool {
        NSData *data = nil;
        if (_muilt.uploadType == kUploadAlasset) {
            //相册信息
            data = [self getAlassetBlockData:partNumber - 1 withAlasset:[self getAlasset]];
        }else
        {
            //沙盒路径
            
            if (_uploadNum == _totalNum) {
                data = [_fileHandle readDataToEndOfFile];
            }else {
                data = [_fileHandle readDataOfLength:(NSUInteger)_partLength];
                [_fileHandle seekToFileOffset:_partLength*(_uploadNum)];
            }
        }
        
        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt partNumber:(int32_t)partNumber data:data generateMD5:NO];
        req.delegate = self;
        req.contentLength = data.length;
        req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
        [req setCompleteRequest];
        //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req setStrKS3Token:[KS3Util getAuthorization:req]];
        [[KS3Client initialize] uploadPart:req];
    }
}
//取消上传，调用abort 接口，终止上传，修改进度条即可
- (void)cancelUpload
{
    if (_muilt == nil) {
        NSLog(@"请先创建上传,再调用Abort");
        return;
    }
    _muilt.isCanceled = YES;
    
    KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
    [request setCompleteRequest];
    //             使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    [request setStrKS3Token:[KS3Util getAuthorization:request]];
    KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
    NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
    if (response.httpStatusCode == 204) {
        NSLog(@"Abort multipart upload success!");
    }
    else {
        NSLog(@"error: %@", response.error.description);
    }
}


#pragma mark 下载方法

/*开始下载，
 1.如果本地文件已存在，则下载完成
 2.本地文件不存在，从0下载
 3.本地有临时下载文件，则从原先进度继续下载
 */
- (void)beginDownload
{
    UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:99];
    UIButton *stopBtn = (UIButton *)[self.view viewWithTag:100];
    /**
     *  如果是暂停下载，就需要把_downloadConnection的file做为参数传到download方法里面
     */
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(concurrentQueue, ^(){
        _downloader = [[KS3Client initialize] downloadObjectWithBucketName:kDownloadBucketName key:kDownloadBucketKey downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
            NSLog(@"开始下载,responseHeaders:%@",responseHeaders);
            
        } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [stopBtn setTitle:@"完成" forState:UIControlStateNormal];
                NSLog(@"completed, file path: %@", filePath);
            });
        } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressView.progress = newProgress;
                NSLog(@"progress: %f", newProgress);
            });
            
            
        } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
            NSLog(@"failed: %@", error.description);
        }];
        
        // //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [_downloader setStrKS3Token:[KS3Util KSYAuthorizationWithHTTPVerb:strAccessKey secretKey:strSecretKey httpVerb:_downloader.httpMethod contentMd5:_downloader.contentMd5 contentType:_downloader.contentType date:_downloader.strDate canonicalizedKssHeader:_downloader.kSYHeader canonicalizedResource:_downloader.kSYResource]];
        
        [_downloader start];
        
        
    });
    
}

//暂停下载，支持断点续传，下次开启程序，进度条的恢复需要计算一下，demo里define kDownloadSize了文件大小
- (void)stopDownload
{
    [_downloader stop];
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
            UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(mScreenWidth * .35 , 20, mScreenWidth * .5, 20)];
            progressView.progressViewStyle = UIProgressViewStyleDefault;
            progressView.tag = 99;
            
            //计算下载临时文件的大小,临时文件是经过MD5Hash的文件名
            NSString *strHost = [NSString stringWithFormat:@"http://%@.ks3-cn-beijing.ksyun.com/%@", kDownloadBucketName, kDownloadBucketKey];
            NSString  *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];;
            //文件临时文件地址，计算百分比
            NSString *  temporaryPath=[filePath stringByAppendingPathComponent: [strHost MD5Hash]];
            NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:temporaryPath];
            unsigned long long   offset = [fileHandle seekToEndOfFile];
            progressView.progress = offset * 1.0 / kDownloadSize;
            [cell.contentView addSubview:progressView];
            
            UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(mScreenWidth - 50, 10, 40, 20)];
            [stopBtn setTitle:@"开始" forState:UIControlStateNormal];
            stopBtn.titleLabel.font  = [UIFont systemFontOfSize:14];
            [stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            stopBtn .tag = 100;
            [stopBtn addTarget:self action:@selector(downloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:stopBtn];
            
        }
        if (indexPath.row == 9) {
            UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(mScreenWidth * .4 , 20, mScreenWidth * .45, 20)];
            progressView.progressViewStyle = UIProgressViewStyleDefault;
            progressView.tag = 199;
            [cell.contentView addSubview:progressView];
            
            UIButton *uploadBtn = [[UIButton alloc]initWithFrame:CGRectMake(mScreenWidth - 50, 10, 40, 20)];
            [uploadBtn setTitle:@"开始" forState:UIControlStateNormal];
            uploadBtn.titleLabel.font  = [UIFont systemFontOfSize:14];
            [uploadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            uploadBtn .tag = 200;
            [uploadBtn addTarget:self action:@selector(uploadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:uploadBtn];
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
            //放在点击事件里，downloadBtnClicked
            
        }
            break;
        case 1:
        {
            KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial1];
            [deleteObjRequest setCompleteRequest];
            [deleteObjRequest setStrKS3Token:[KS3Util getAuthorization:deleteObjRequest]];
            KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
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
            KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2];
            [headObjRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [headObjRequest setStrKS3Token:[KS3Util getAuthorization:headObjRequest]];
            KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
            NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
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
            
            KS3AccessControlList *ControlList = [[KS3AccessControlList alloc] init];
            [ControlList setContronAccess:KingSoftYun_Permission_Public_Read_Write];
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            acl.identifier = @"4567894346";
            acl.displayName = @"accDisplayName";
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName withAcl:ControlList grantAcl:@[acl]];
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
            putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
            putObjRequest.filename = @"#####!!!@@######@@@11@@@ a b  + - * ~ ! @  # ^ :中 ～ 文.jpg";//[fileName lastPathComponent];
            putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
            [putObjRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [putObjRequest setStrKS3Token:[KS3Util getAuthorization:putObjRequest]];
            KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
            NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
            if (response.httpStatusCode == 200) {
                NSLog(@"Put object success");
            }
            else {
                NSLog(@"Put object failed");
            }
        }
            break;
        case 4:
        {
            KS3BucketObject *destBucketObj = [[KS3BucketObject alloc] initWithBucketName:kDesBucketName keyName:@"111111111 a b  + - * ~ ! @  # ^ :中 ～ 文.jpg"];
            KS3BucketObject *sourceBucketObj = [[KS3BucketObject alloc] initWithBucketName:kBucketName keyName:@"1111 a b  + - * ~ ! @  # ^ :中 ～ 文.jpg"];
            KS3PutObjectCopyRequest *request = [[KS3PutObjectCopyRequest alloc] initWithName:destBucketObj sourceBucketObj:sourceBucketObj];
            [request setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [request setStrKS3Token:[KS3Util getAuthorization:request]];
            KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
            NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
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
            KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2];
            [getObjectACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [getObjectACLRequest setStrKS3Token:[KS3Util getAuthorization:getObjectACLRequest]];
            KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
            KS3BucketACLResult *result = response.listBucketsResult;
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            
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
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
            KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2 acl:acl];
            [setObjectACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [setObjectACLRequest setStrKS3Token:[KS3Util getAuthorization:setObjectACLRequest]];
            KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
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
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            acl.identifier = kObjectName;
            acl.displayName = @"blues111DisplayName";
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            KS3SetObjectGrantACLRequest *setObjectGrantACLRequest = [[KS3SetObjectGrantACLRequest alloc] initWithName:kBucketName withKeyName:kObjectSpecial2 grantAcl:acl];
            [setObjectGrantACLRequest setCompleteRequest];
             //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [setObjectGrantACLRequest setStrKS3Token:[KS3Util getAuthorization:setObjectGrantACLRequest]];
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
        //放在点击事件里，uploadBtnClicked
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
            [request setCompleteRequest];
//             使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
            [request setStrKS3Token:[KS3Util getAuthorization:request]];
            KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
              NSString *str = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
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

#pragma mark - Delegate

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    _uploadNum ++;
    if (_totalNum < _uploadNum) {
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        [req2 setCompleteRequest];
         //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req2 setStrKS3Token:[KS3Util getAuthorization:req2]];
        
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        //req参数设置完一定要调这个函数
        [req setCompleteRequest];
         //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req setStrKS3Token:[KS3Util getAuthorization:req]];
        KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
        NSString *bodyStr = [[NSString alloc]initWithData:resp.body encoding:NSUTF8StringEncoding];
        if (resp.httpStatusCode != 200) {
            NSLog(@"#####complete multipart upload failed!!! code: %d#####，body = %@", resp.httpStatusCode,bodyStr);
        }else if (resp.httpStatusCode == 200)
        {
            NSLog(@"Upload Success!!");
        }
        
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
    UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:199];
    if (_muilt.isCanceled ) {
        [request cancel];
        
        progressView.progress = 0;
        return;
    }
    
    long long alreadyTotalWriten = (_uploadNum - 1) * _partLength + totalBytesWritten;
    double progress = alreadyTotalWriten / (float)_fileSize;
    NSLog(@"upload progress: %f", progress);
#warning upload progress Callback
    progressView.progress = progress;
    if (progress == 1) {
        [_fileHandle closeFile];
    }
}

@end
