# KS3 SDK for iOS

## 安装

通过 CocoaPods

```ruby
pod "Ks3SDK", "~> 2.0.0"
```

## 使用方法

首先需要初始化KS3Client。可以利用AccessKeyID、AccessKeySecret初始化（由于AccessKeySecret要放在客户端，因此不安全，仅建议测试时使用），代码如下：

```Objective-C

    [[KS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];

```

第二种方式利用token进行请求，每次需要调用SDK的API时都需要使用请求一次token，然后用这个token初始化KS3Request的strKS3Token，再进行API请求（推荐使用），对应的代码如下：

```Objective-C

	[YourAppServer sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    if (connectionError == nil) {
	        NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	        ks3Request.strKS3Token = strToken; // 设置Token
	        [[KS3Client initialize] listBuckets:(KS3ListBucketsRequest *)listBucketRequest]; // 调用KS3 API接口
            // 剩余处理
	    }
	    else {
            // 错误处理
	    }
	}];

```

服务端签名计算方法参考：[API接口文档](https://docs.ksyun.com/read/latest/65/_book/index.html)

API详细使用方法参考 [使用文档](https://github.com/ks3sdk/ks3-ios-sdk/blob/master/Docs/Usage.md)

## 示例代码
* 完整的demo 见 KS3SDKDemo 目录下的代码

## 代码许可
Apache License, Version 2.0。详情见 [License 文件](https://github.com/ks3sdk/ks3-ios-sdk/blob/master/master/LICENSE).
