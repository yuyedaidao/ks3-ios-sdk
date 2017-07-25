## KS3 SDK使用文档
### 简介
#### 金山标准存储服务
金山标准存储服务（Kingsoft Standard Storage Service），简称KS3，是金山云为开发者提供无限制、多备份、分布式的低成本存储空间解决方案。KS3 SDK for iOS替开发者解决了授权、存储资源管理以及上传下载等复杂问题，提供基于iOS平台的简单易用API，让开发者方便地构建基于KS3服务的移动应用。
> 更好的了解KS3，请咨询[文档中心][1]

#### 概念和术语
##### AccessKeyID、AccessKeySecret
使用KS3，您需要KS3颁发给您的AccessKeyID（长度为20个字符的ASCII字符串）和AccessKeySecret（长度为40个字符的ASCII字符串）。AccessKeyID用于标识客户的身份，AccessKeySecret作为私钥形式存放于客户服务器不在网络中传递。AccessKeySecret通常用作计算请求签名的密钥，用以保证该请求是来自指定的客户。使用AccessKeyID进行身份识别，加上AccessKeySecret进行数字签名，即可完成应用接入与认证授权。
##### Service
KS3提供给用户的虚拟存储空间，在这个虚拟空间中，每个用户可拥有一个到多个Bucket。

##### Bucket
Bucket是存放Object的容器，所有的Object都必须存放在特定的Bucket中。每个用户最多可以创建20个Bucket，每个Bucket中可以存放无限多个Object。Bucket不能嵌套，每个Bucket中只能存放Object，不能再存放Bucket，Bucket下的Object是一个平级的结构。Bucket的名称全局唯一且命名规则与DNS命名规则相同：

* 仅包含小写英文字母（a-z），数字，点（.），中线，即： abcdefghijklmnopqrstuvwxyz0123456789.-
* 必须由字母或数字开头
* 长度在3和255个字符之间
* 不能是IP的形式，类似192.168.0.1
* 不能以kss开头

##### Object
在KS3中，用户操作的基本数据单元是Object。单个Object允许存储0\~1TB的数据。 Object 包含key和data。其中，key是Object的名字；data是Object 的数据。key为UTF-8编码，且编码后的长度不得超过1024个字节。

##### ACL
**ACL**(Access Control List)目前支持{READ, WRITE, FULL\_CONTROL}三种权限，通过一个授权列表的形式来指明不同访问者对指定资源的访问权限。

**Canned ACL**（Canned Access Control List）目前支持{PRIVATE，PUBLIC\_READ，PUBLIC\_READ\_WRITE}三种权限。通过对Bucket或Object设置Canned ACL，可以设置该资源对所有访问者的通用访问权限。

对于BUCKET的拥有者，总是FULL\_CONTROL。可以设置匿名用户为READ，WRITE, 或者FULL\_CONTROL权限。

对于BUCKET来说，READ是指罗列bucket中文件的功能。WRITE是指可以上传、删除BUCKET中的文件。FULL\_CONTROL则包含所有操作。

对于OBJECT来说，READ是指可以查看或者下载文件。WRITE无意义。FULL\_CONTROL则包含所有操作。

当使用更改指定资源访问权限的API时（如：setACL、setObjectACL），可以以下任意一种方式指明该资源的访问权限:

**AccessControlList形式:**
 ```

	    KS3SetGrantACLRequest *request = [[KS3SetGrantACLRequest alloc] initWithName:@"your-bucket-name"];
	        KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
	        [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
	        acl.identifier = @"user-identifier";
	        acl.displayName = @"user-displayName";
	        request.acl = acl;
	        [request setCompleteRequest];
	        KS3SetGrantACLResponse *response = [[KS3Client initialize] setGrantACL:request];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Set grant acl success!");
	        }
	        else {
	            NSLog(@"Set grant acl error: %@", response.error.description);
	        }
 ```

**CannedAccessControlList:**
 ```

	    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
	        [acl setContronAccess:KingSoftYun_Permission_Private];
 ```

##### 请求签名
方法: 在请求中加入名为 Authorization 的 Header，值为签名值。形如：
Authorization: KSS P3UPCMORAFON76Q6RTNQ:vU9XqPLcXd3nWdlfLWIhruZrLAM=

*签名生成规则*
```

	    Authorization = “KSS YourAccessKeyID:Signature”

	    Signature = Base64(HMAC-SHA1(YourAccessKeyIDSecret, UTF-8-Encoding-Of( StringToSign ) ) );

	    StringToSign = HTTP-Verb + "\n" +
	           Content-MD5 + "\n" +
	           Content-Type + "\n" +
	           Date + "\n" +
	           CanonicalizedKssHeaders +
	           CanonicalizedResource;
```

##### 必要的说明
对于使用token方式初始化SDK的用户，需要使用另外一种方式去调用API。做法如下：
>
因为token是用户自己去获取，所以要在用户获取到token之后，用它初始化KS3Request的strKS3Token属性设置，那么在获取token之前就需要先把要请求的API的KS3Request初始化一个对应的实例，然后再用这个获得了token的实例去调用相应的API即可。以获取账号下所有bucket为例（listBuckets:）：

```
[listBucketRequest setCompleteRequest];
NSDictionary \*dicParams = [self dicParamsWithReq:listBucketRequest];
NSURL \*tokenUrl = [NSURL URLWithString:@"http://0.0.0.0:11911"];
NSMutableURLRequest \*tokenRequest = [[NSMutableURLRequest alloc] initWithURL:tokenUrl
	                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
	                                                         timeoutInterval:10];
NSData \*dataParams = [NSJSONSerialization dataWithJSONObject:dicParams options:NSJSONWritingPrettyPrinted error:nil];
[tokenRequest setURL:tokenUrl];
[tokenRequest setHTTPMethod:@"POST"];
[tokenRequest setHTTPBody:dataParams];
[NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError \*connectionError) {
	if (connectionError == nil) {
	    NSString *strToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	    NSLog(@"#### 获取token成功! #### token: %@", strToken);
	    listBucketRequest.strKS3Token = strToken;
	    _arrBuckets = [[KS3Client initialize] listBuckets:(KS3ListBucketsRequest *)listBucketRequest];
	    [_bucketListTable reloadData];
	}
	else {
	    NSLog(@"#### 获取token失败，error: %@", connectionError);
	}
}];

- (NSDictionary *)dicParamsWithReq:(KS3Request *)request {
	NSDictionary \*dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
		                       request.httpMethod,  @"http_method",
		                       request.contentMd5,  @"content_md5",
		                       request.contentType, @"content_type",
		                       request.strDate,     @"date",
		                       request.kSYHeader,   @"headers",
		                       request.kSYResource, @"resource", nil];
	return dicParams;
}

```

用户向自己的app server请求token需要提供httpMethod，contentMd5，contentType，strDate，header，resource这6个字段给app server，然后app server根据上述签名规则，利用AccessKeyID及AccessKeySecret计算出签名并正确返回给SDK。上述方法中的contentMd5, contentType, header参数可为空。若为空，则SDK会使用空字符串("")替代, 但strDate和resource不能为空。

为保证请求时间的一致性，需要App客户端及业务服务期保证各自的时间正确性，否则用错误的时间尝试请求，会返回403Forbidden错误。

方法参数说明：

contentMd5 表示请求内容数据的MD5值, 使用Base64编码
contentType 表示请求内容的类型
strDate 表示此次操作的时间,且必须为 HTTP1.1 中支持的 GMT 格式，客户端应务必保证本地时间正确性
header 表示HTTP请求中的以x-kss开头的Header组合
resource 表示用户访问的资源

### 开发前准备
#### SDK使用准备

- 申请AccessKeyID、AccessKeySecret

#### SDK配置

SDK以静态库和动态库的形式呈现，支持bitcode。请将*KS3YunSDK.framework*添加到项目工程中。
动态库位置：Framework/DynamicFramework/KS3YunSDK.framework.
静态库位置：Framework/StaticFramework/KS3YunSDK.framework.  
KS3SDKDemo默认为静态库。
静态库配置：最低支持iOS6.0，6MB左右，在app工程的Build Setting -\> Other link lags 加入-all\_load，
动态库配置：最低支持iOS8.0，2MB左右，若Xcode版本6+，请Target-\>General-\>Embedded Binaries加上KS3YunSDK.framework。原因是苹果在iOS8.0以后允许使用三方动态库上线，如需兼容iOS8.0以下app上线，请使用静态库，。

#### 加载SDK常见问题

a.使用静态库，真机运行出现Application install failed.The application does not have a valid signature。
解决：请在Target-\>General-\>Embedded Binaries中删除对应的KS3YunSDK.framework.
b.使用动态库，运行出现dyld: Library not loaded: XXXXXX Reason:image not found 。
解决：请在Target-\>General-\>Embedded Binaries加上KS3YunSDK.framework
c.使用静态库，在分块上传出现[KS3Response multipartUpload] 找不到方法
解决：请在在app工程的Build Setting -\> Other link lags 加入-all\_load。

#### 运行环境
静态库支持iOS 6.0+
动态库支持iOS 8.0+

### 安全性
#### 使用场景
由于在App端明文存储AccessKeyID、AccessKeySecret是极不安全的，因此推荐的使用场景如下图所示：

![][image-1]

**使用方式**
设置对应接口所需的request中相应的**callbackUrl**，**callbackBody**和**callbackParams**即可。

**参数说明**

**callBackUrl**: 回调url地址

**callBackBody**: 回调参数支持魔法变量、自定义参数以及常量

**customParams**:自定义参数，必须以前缀kss-开头


**魔法变量说明：**
<table>
  <tr>
    <th>参数</th>
    <th>说明</th>
    <th>备注</th>
  </tr>
  <tr>
    <td>bucket</td>
    <td>文件上传的Bucket</td>
    <td>Utf-8编码</td>
  </tr>
  <tr>
    <td>key</td>
    <td>文件的名称</td>
    <td>Utf-8编码</td>
  </tr>
  <tr>
    <td>etag</td>
    <td>文件Md5值经过base64处理</td>
  </tr>
 <tr>
    <td>objectSize</td>
    <td>文件大小</td>
    <td>以字节标识</td>
  </tr>
 <tr>
    <td>mimeType</td>
    <td>文件类型</td>
  </tr>
 <tr>
    <td>createTime</td>
    <td>文件创建时间</td>
    <td>Unix时间戳表示，1420629372，精确到秒</td>
  </tr>
</table>

**Callback使用范例**：

```

	    KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName];
	    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
	    putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
	    putObjRequest.filename = [fileName lastPathComponent];
	    putObjRequest.callbackBody = @"objectKey=${key}&etag=${etag}&location=${kss-location}&name=${kss-price}";
	    putObjRequest.callbackUrl = @"http://127.0.0.1:19090/";// success
	    putObjRequest.callbackParams = [NSDictionary dictionaryWithObjectsAndKeys:
	                                    @"BeiJing", @"kss-location",
	                                    @"$Ten",    @"kss-price",
	                                    @"error",   @"kss", nil];// **** last                                         key-value is test error
	    [putObjRequest setCompleteRequest];                      
	    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];

```

#### KS3Client初始化
- 利用AccessKeyID、AccessKeySecret初始化（不安全，仅建议测试时使用）

对应的初始化代码如下：

```

	    [[KS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];

```

- 利用token进行请求，每次需要调用SDK的API时都需要使用请求一次token，然后用这个token初始化KS3Request的strKS3Token，再进行API请求（推荐使用）

对应的代码如下：

```
	[listBucketRequest setCompleteRequest];
	NSDictionary *dicParams = [self dicParamsWithReq:listBucketRequest];
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
	        _arrBuckets = [[KS3Client initialize] listBuckets:(KS3ListBucketsRequest *)listBucketRequest];
	        [_bucketListTable reloadData];
	    }
	    else {
	        NSLog(@"#### 获取token失败，error: %@", connectionError);
	    }
	}];
```


### SDK介绍及使用
#### 核心类介绍
- KS3Client 封装接入Web Service的一系列操作，提供更加便利的接口以及回调。

> 为方便开发者使用，SDK在REST API接口返回值基础上进行了封装，具体更多封装类详情请见
> [SDK-REST API:][2]

#### 资源管理操作
* [List Buckets][3] 列出客户所有的Bucket信息
* [Create Bucket][4] 创建一个新的Bucket
* [Delete Bucket][5] 删除指定Bucket
* [Get Bucket ACL][6] 获取Bucket的ACL
* [Put Bucket ACL][7] 设置Bucket的ACL
* [Head Bucket][8] 查询是否已经存在指定Bucket
* [Get Object][9] 下载Object数据
* [Head Object][10] 查询是否已经存在指定Object
* [Delete Object][11] 删除指定Object
* [Get Object ACL][12] 获得Bucket的acl
* [Put Object ACL][13] 上传object的acl
* [List Objects][14] 列举Bucket内的Object
* [Put Object][15] 上传Object数据
* [Put Object Copy][16] 拷贝源Bucket里面的Object到目的Bucket的Object
* [Initiate Multipart Upload][17] 调用这个接口会初始化一个分块上传
* [Upload Part][18] 上传分块
* [List Parts][19] 罗列出已经上传的块
* [Abort Multipart Upload][20] 取消分块上传
* [Complete Multipart Upload][21] 组装所有分块上传的文件
* [Multipart Upload Example Code 1][22] 分片上传代码示例1
* [Multipart Upload Example Code 2][23] 分片上传代码示例2
* [Upload Manager][25] 基于分块上传的简单上传接口

#### Service操作

##### List Buckets：

*列出客户所有的 Bucket 信息*

**方法名：**

\- (NSArray *)listBuckets:(KS3ListBucketsRequest *)listBucketsRequest;

**参数说明：**  

* listBucketRequest：获取Bucket列表的KS3ListBucketsRequest对象

**返回结果：**

* 客户所有的bucket列表，列表中每个元素是KS3Bucket对象

**代码示例：**
```

	NSArray *arrBuckets = [[KS3Client initialize] listBuckets:listBucketRequest];
```

#### Bucket操作

##### Create Bucket：

*创建一个新的Bucket*

**方法名：**

\- (KS3CreateBucketResponse *)createBucket:(KS3CreateBucketRequest *)createBucketRequest;

**参数说明：**

* createBucketRequest：创建Bucket的KS3CreateBucketRequest请求

**返回结果：**

* 创建Bucket的HTTP请求响应

**KS3CreateBucketResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3CreateBucketRequest *createBucketReq = [[KS3CreateBucketRequest alloc] initWithName:strBucketName];
	    [createBucketReq setCompleteRequest];
	    KS3CreateBucketResponse *response = [[KS3Client initialize] createBucket:createBucketReq];
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Create bucket success!");
	    }
	    else {
	        NSLog(@"error: %@", response.error.localizedDescription);
	    }
```

##### Delete Bucket:

*删除指定Bucket*

**方法名：**

\- (KS3DeleteBucketResponse *)deleteBucket:(KS3DeleteBucketRequest *)deleteBucketRequest;

**参数说明：**

* deleteBucketRequest ：删除Bucket的KS3DeleteBucketRequest请求

**返回结果：**

* 删除Bucket的HTTP请求响应


**KS3DeleteBucketResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，204表示成功但是返回内容为空，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示删除一个不存在的Bucket，409表示删除一个不为空的Bucket

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```
	    KS3DeleteBucketRequest *deleteBucketReq = [[KS3DeleteBucketRequest alloc] initWithName:@"uuu"];
	    [deleteBucketReq setCompleteRequest];
	    KS3DeleteBucketResponse *response = [[KS3Client initialize] deleteBucket:deleteBucketReq];
	    if (response.httpStatusCode == 204) { // **** 没有返回任何内容
	        NSLog(@"Delete bucket success!");
	    }
	    else {
	        NSLog(@"Delete bucket error: %@", response.error.description);
	    }
```

##### Get Bucket ACL:

*获取Bucket的ACL*

**方法名：**

\- (KS3GetACLResponse \*)getACL:(KS3GetACLRequest \*)getACLRequest

**参数说明：**

* getACLRequest：获取Bucket ACL的KS3GetACLRequest对象

**返回结果：**

* 获取Bucket ACL的HTTP请求响应\*

**KS3GetACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示获取一个不存在Bucket的ACL

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3GetACLRequest *getACLRequest = [[KS3GetACLRequest alloc] initWithName:@"your-bucket-name"];
	    [getACLRequest setCompleteRequest];
	    KS3GetACLResponse *response = [[KS3Client initialize] getACL:getACLRequest];        
	    KS3BucketACLResult *result = response.listBucketsResult;
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Get bucket acl success!");

	        NSLog(@"Bucket owner ID:          %@",result.owner.ID);
	        NSLog(@"Bucket owner displayName: %@",result.owner.displayName);

	        for (KS3Grant *grant in result.accessControlList) {
	            NSLog(@"%@",grant.grantee.ID);
	            NSLog(@"%@",grant.grantee.displayName);
	            NSLog(@"%@",grant.grantee.URI);
	            NSLog(@"%@",grant.permission);
	        }
	    }
	    else {
	        NSLog(@"Get bucket acl error: %@", response.error.description);
	    }
```

##### Put Bucket ACL:

*设置Bucket的ACL，以AccessControlList*

**方法名：**

\- (KS3SetGrantACLResponse \*)setGrantACL:(KS3SetGrantACLRequest \*)setGrantACLRequest;

**参数说明：**

* setGrantACLRequest：设置Bucket Grant ACL的KS3SetGrantACLRequest对象

**返回结果：**

* 设置Bucket Grant ACL的HTTP请求响应

**KS3SetGrantACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，但会清空原有ACL权限，只保留当前设置，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示给一个不存在的Bucket设置ACL

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3SetGrantACLRequest *setGrantACLRequest = [[KS3SetGrantACLRequest alloc] initWithName:kBucketName];
	    KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
	    acl.identifier = @"4567894346";
	    acl.displayName = @"accDisplayName";
	    [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
	    setGrantACLRequest.acl = acl;
	    [setGrantACLRequest setCompleteRequest];
	    KS3SetGrantACLResponse *response = [[KS3Client initialize] setGrantACL:setGrantACLRequest];
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Set bucket grant acl success!");
	    }
	    else {
	        NSLog(@"Set bucket grant acl error: %@", response.error.description);
	    }

```

*设置Bucket的ACL，以CannedAccessControlList形式*

**方法名：**

\- (KS3SetACLResponse \*)setACL:(KS3SetACLRequest \*)getACLRequest;

**参数说明：**

* getACLRequest：设置Bucket ACL的KS3SetACLRequest对象

**返回结果：**

* 设置Bucket ACL的HTTP请求响应\*

**KS3SetACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，但会清空原有ACL权限，只保留当前设置，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示给一个不存在的Bucket设置ACL

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3SetACLRequest *setBucketACLReq = [[KS3SetACLRequest alloc] initWithName:kBucketName];
	    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
	    [acl setContronAccess:KingSoftYun_Permission_Public_Read];
	    setBucketACLReq.acl = acl;
	    [setBucketACLReq setCompleteRequest];
	    KS3SetACLResponse *response = [[KS3Client initialize] setBucketACL:setBucketACLReq];
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Set bucket acl success!");
	    }
	    else {
	        NSLog(@"Set bucket acl error: %@", response.error.description);
	    }

```

##### Head Bucket：

*查询是否已经存在指定Bucket*

**方法名：**

\- (KS3HeadBucketResponse \*)headBucket:(KS3HeadBucketRequest \*)headBucketRequest;

**参数说明：**

* headBucketRequest:查询是否已存在指定的Bucket的KS3HeadBucketRequest请求

**返回结果：**

* 查询是否已存在指定的Bucket的HTTP请求响应

**KS3HeadBucketResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示请求一个不存在的Bucket

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3HeadBucketRequest *request = [[KS3HeadBucketRequest alloc] initWithName:kBucketName];
	    [request setCompleteRequest];
	    KS3HeadBucketResponse *response = [[KS3Client initialize] headBucket:request];
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Head bucket success!");
	    }
	    else {
	        NSLog(@"Head bucket error: %@", response.error.description);
	    }

```

#### Object操作

##### Get Object：

*下载该Object数据*  

**方法名：**

\- (KS3DownLoad *)downloadObjectWithBucketName:(NSString *)bucketName
	                                      key:(NSString *)key
	                            tokenDelegate:(id)tokenDelegate
	                       downloadBeginBlock:(KSS3DownloadBeginBlock)downloadBeginBlock
	                  downloadFileCompleteion:(kSS3DownloadFileCompleteionBlock)downloadFileCompleteion
	              downloadProgressChangeBlock:(KSS3DownloadProgressChangeBlock)downloadProgressChangeBlock
	                              failedBlock:(KSS3DownloadFailedBlock)failedBlock;

**参数说明：**

* strBucketName：指定的Bucket名称
* key：指定的Object名称
* tokenDelegate：设置token的delegate
* downloadBeginBlock：表示下载开始的block
* downloadFileCompleteion：表示下载完成后的block
* downloadProgressChangeBlock:表示下载中的block
* failedBlock：表示错误处理的block

**返回结果：**

* 下载Object的KS3DownLoad对象

**代码示例：**
```

	    _downloader = [[KS3Client initialize] downloadObjectWithBucketName:kBucketName key:kObjectName tokenDelegate:self downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
	            NSLog(@"1212221");

	        } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
	            NSLog(@"completed, file path: %@", filePath);

	        } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
	            progressView.progress = newProgress;
	            NSLog(@"progress: %f", newProgress);

	        } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
	            NSLog(@"failed: %@", error.description);
	        }];
	        [_downloader start];

```

##### Head Object：

*查询是否已经存在指定Object*

**方法名：**

\- (KS3HeadObjectResponse \*)headObject:(KS3HeadObjectRequest \*)headObjectRequest;

**参数说明：**

* headObjectRequest：查询Object是否存在的KS3HeadObjectRequest对象

**返回结果：**

* 查询指定Object是否存在的HTTP请求响应

**KS3HeadObjectResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示指定的Bucket或者Object不存在

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文


**代码示例：**
```
	        KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectName];
	        [headObjRequest setCompleteRequest];
	        KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Head object success!");
	        }
	        else {
	            NSLog(@"Head object error: %@", response.error.description);
	        }
```

##### Delete Object：

*删除指定Object*

**方法名：**

\- (KS3DeleteObjectResponse \*)deleteObject:(KS3DeleteObjectRequest \*)deleteObjectRequest;

**参数说明：**

* deleteObjectRequest：删除Object的KS3DeleteObjectRequest对象

**返回结果：**

* 删除指定Object是否存在的HTTP请求响应

**KS3DeleteObjectResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，204表示成功但返回内容为空,400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示删除一个不存在的Bucket或Object

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```
	        KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName withKeyName:kObjectName];
	        [deleteObjRequest setCompleteRequest];
	        KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Delete object success!");
	        }
	        else {
	            NSLog(@"Delete object error: %@", response.error.description);
	        }
```

##### Get Object ACL：

*获得Object的acl*

**方法名：**

\- (KS3GetObjectACLResponse \*)getObjectACL:(KS3GetObjectACLRequest \*)getObjectACLRequest;

**参数说明：**

* getObjectACLRequest：获取Object ACL的KS3GetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**KS3GetObjectACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示获取一个不存在Object的ACL

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```
	        KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName];
	        [getObjectACLRequest setCompleteRequest];
	        KS3GetObjectACLResponse *response = [[KS3Client initialize] getObjectACL:getObjectACLRequest];
	        KS3BucketACLResult *result = response.listBucketsResult;
	        if (response.httpStatusCode == 200) {

	            NSLog(@"Object owner ID:          %@",result.owner.ID);
	            NSLog(@"Object owner displayName: %@",result.owner.displayName);

	            for (KS3Grant *grant in result.accessControlList) {
	                NSLog(@"%@",grant.grantee.ID);
	                NSLog(@"%@",grant.grantee.displayName);
	                NSLog(@"%@",grant.grantee.URI);
	                NSLog(@"%@",grant.permission);
	            }
	        }
	        else {
	            NSLog(@"Get object acl error: %@", response.error.description);
	        }

```

##### Put Object ACL:

*上传object的acl，以CannedAccessControlList形式*

**方法名：**

\- (KS3SetObjectACLResponse \*)setObjectACL:(KS3SetObjectACLRequest \*)setObjectACLRequest;

**参数说明：**

* setObjectACLRequest：设置Object ACL的KS3SetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**KS3SetObjectACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示给一个不存在的Obejct设置ACL，

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	        KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
	        [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
	        KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName acl:acl];
	        [setObjectACLRequest setCompleteRequest];
	        KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Set object acl success!");
	        }
	        else {
	            NSLog(@"Set object acl error: %@", response.error.description);
	        }
```

*上传object的acl，以AccessControlList形式*

**方法名：**

\- (KS3SetObjectGrantACLResponse \*)setObjectGrantACL:(KS3SetObjectGrantACLRequest \*)setObjectGrantACLRequest;

**参数说明：**

* setObjectGrantACLRequest：设置Object Grant ACL的KS3SetObjectGrantACLRequest对象

**返回结果：**

* 获取Object Grant ACL的HTTP请求响应

**KS3SetObjectGrantACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示给一个不存在的Obejct设置ACL

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
	    acl.identifier = kObjectName;
	    acl.displayName = @"blues111DisplayName";
	    [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
	    KS3SetObjectGrantACLRequest *setObjectGrantACLRequest = [[KS3SetObjectGrantACLRequest alloc] initWithName:kBucketName withKeyName:kObjectName grantAcl:acl];
	    [setObjectGrantACLRequest setCompleteRequest];
	    KS3SetObjectGrantACLResponse *response = [[KS3Client initialize] setObjectGrantACL:request];
	    if (response.httpStatusCode == 200) {
	        NSLog(@"Set object grant acl success!");
	    }
	    else {
	        NSLog(@"Set object grant acl error: %@", response.error.description);
	    }
```

##### List Objects：

*列举Bucket内的Object*

**方法名：**

\- (KS3ListObjectsResponse \*)listObjects:(KS3ListObjectsRequest \*)listObjectsRequest;

**参数说明：**

* listObjectsRequest：列举指定的Bucket内所有Object的KS3ListObjectsRequest对象，它可以设置prefix，marker，maxKeys，delimiter四个指定的属性。prefix：限定返回的Object名字都以制定的prefix前缀开始。类型：字符串默认：无；marker：从一个指定的名字marker开始列出Object的名字。类型：字符串默认值：无；maxKeys：设定返回的Object名字数量，返回的数量有可能比设定的少，但是绝不会比设定的多，如果还存在没有返回的Object名字，返回的结果包含<IsTruncated>true</IsTruncated>。类型：字符串默认：10000；delimiter：delimiter是用来对Object名字进行分组的一个字符。包含指定的前缀到第一次出现的delimiter字符的所有Object名字作为一组结果CommonPrefix。类型：字符串默认值：无

**返回结果：**

* 列举指定Bucket内所有Object的HTTP请求响应

**KS3SetObjectGrantACLResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误，404表示Bucket不存在

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

5. listBucketsResult：成功时返回的指定Bucket下所有的Object ummary信息实体类，包含一个Ks3ObjectSummary的容器及其他信息

**代码示例：**
````

	    KS3ListObjectsRequest *listObjectRequest = [[KS3ListObjectsRequest alloc] initWithName:kBucketName];
	    [listObjectRequest setCompleteRequest];
	    KS3ListObjectsResponse *response = [[KS3Client initialize] listObjects:listObjectRequest];
	    _result = response.listBucketsResult;
	    _arrObjects = response.listBucketsResult.objectSummaries;

	    for (KS3ObjectSummary *objectSummary in _arrObjects) {
	        NSLog(@"%@",objectSummary.Key);
	        NSLog(@"%@",objectSummary.owner.ID);
	    }
	    NSLog(@"%@",_result.bucketName);
	    NSLog(@"%ld",_result.objectSummaries.count);
	    NSLog(@"%ld",_result.commonPrefixes.count);

	    NSLog(@"KS3ListObjectsResponse %d",response.httpStatusCode);
````

##### Put Object：

*上传Object数据*

**方法名：**

\- (KS3PutObjectResponse \*)putObject:(KS3PutObjectRequest \*)putObjectRequest;


**参数说明：**

* putObjectRequest：上传指定的Object的KS3PutObjectRequest对象。它需要设置指定的Bucket的名称和Object的名称

**返回结果：**

* 上传指定的Object的HTTP请求响应

**KS3PutObjectResponse响应包括以下内容**

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	        KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:kBucketName];
	        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
	        putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
	        putObjRequest.filename = [fileName lastPathComponent];
	        putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
	        [putObjRequest setCompleteRequest];
	        KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Put object success");
	        }
	        else {
	            NSLog(@"Put object failed");
	        }

```

##### Put Object Copy：

*拷贝源Bucket里面的Object到目的Bucket的Object*

**方法名：**

\- (KS3PutObjectCopyResponse \*)putObjectCopy:(KS3PutObjectCopyRequest \*)putObjectCopyRequest;


**参数说明：**

* putObjectCopyRequest：拷贝源Bucket里面的Object到目的Bucket的Object的KS3PutObjectCopyRequest对象。它需要设置指定的源Bucket的名称，源Object的名称，目的Bucket的名称和目的Object的名称

**返回结果：**

* 拷贝源Bucket里面的Object到目的Bucket的Object的HTTP请求响应

KS3PutObjectResponse响应包括以下内容

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	        KS3BucketObject *destBucketObj = [[KS3BucketObject alloc] initWithBucketName:kDesBucketName keyName:kDesObjectName];
	        KS3BucketObject *sourceBucketObj = [[KS3BucketObject alloc] initWithBucketName:kBucketName keyName:kObjectName];
	        KS3PutObjectCopyRequest *request = [[KS3PutObjectCopyRequest alloc] initWithName:destBucketObj sourceBucketObj:sourceBucketObj];
	        [request setCompleteRequest];
	        KS3PutObjectCopyResponse *response = [[KS3Client initialize] putObjectCopy:request];
	        if (response.httpStatusCode == 200) {
	            NSLog(@"Put object copy success!");
	        }
	        else {
	            NSLog(@"Put object copy error: %@", response.error.description);
	        }

```

##### Initiate Multipart Upload：

*调用这个接口会初始化一个分块上传，KS3 Server会返回一个upload id, upload id 用来标识属于当前object的具体的块，并且用来标识完成分块上传或者取消分块上传*

**方法名：**

- (KS3MultipartUpload *)initiateMultipartUploadWithRequest:(KS3InitiateMultipartUploadRequest *)request;


**参数说明：**

* request：初始化分块上传的KS3InitiateMultipartUploadRequest对象

**返回结果：**

* 初始化分块上传的HTTP响应，KS3MultipartUpload类型的对象里面包含了指定的Object名称，Bucket名称，此次上传的Upload ID，Object的Owner，初始化日期\*


**代码示例：**
```
	KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:kBucketName];
	[initMultipartUploadReq setCompleteRequest];
	KS3MultipartUpload *muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];

```

##### Upload Part：

*初始化分块上传后，上传分块接口。Part number 是标识每个分块的数字，介于0-10000之间。除了最后一块，每个块必须大于等于5MB，最后一块没有这个限制。*

**方法名：**

\- (KS3UploadPartResponse \*)uploadPart:(KS3UploadPartRequest \*)uploadPartRequest;

**参数说明：**

* uploadPartRequest：上传块的KS3UploadPartRequest对象，它需要指定上传的Object名称，指定的Bucket的名称，分块的块号，此块的数据

**返回结果：**

* 块上传的HTTP请求响应

KS3UploadPartResponse响应包括以下内容

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
	    req.delegate = self;
	    req.data = data;
	    req.partNumber = (int32_t)partNumber;
	    req.contentLength = data.length;
	    req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
	    [req setCompleteRequest];
	    KS3UploadPartResponse *response = [[KS3Client initialize] uploadPart:req];

```

##### List Parts:

*罗列出已经上传的块*

**方法名：**

\- (KS3ListPartsResponse \*)listParts:(KS3ListPartsRequest \*)listPartsRequest;

**参数说明：**

* listPartsRequest：罗列已经上传的块的KS3ListPartsRequest对象，它包含指定的Object的名称，此次上传的Upload ID，maxParts，它表示块大小限制，类型：字符串，默认值：None，partNumberMarker，它表示块号标记，将返回大于此块号的分块，类型：字符串，默认值：None

**返回结果：**

* 罗列已经上传的块的HTTP请求响应，它包含了类型为KS3ListPartsResult的请求的结果，它包含指定的Bucket名称，指定的Object名称，此次上传的Upload ID，partNumberMarker，它表示块号标记，将返回大于此块号的分块，maxParts，它表示块大小限制，isTruncated，它表示是否取完分块，Owner它表示创建分块上传的用户

KS3ListPartsResponse响应包括以下内容

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
	    [req2 setCompleteRequest];
	    KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];

```

##### Abort Multipart Upload:

*取消分块上传。*

**方法名：**

\- (KS3AbortMultipartUploadResponse \*)abortMultipartUpload:(KS3AbortMultipartUploadRequest \*)abortMultipartRequest;

**参数说明：**

* abortMultipartRequest：取消分块上传的KS3AbortMultipartUploadRequest对象，它需要使用KS3MultipartUpload对象来初始化，初始化包括指定的Bucket名称，Object的名称，分块上传的Upload ID

**返回结果：**

* 取消上传的HTTP请求响应

KS3AbortMultipartUploadResponse响应包括以下内容

1. httpStatusCode：Http请求返回的状态码，204表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	        KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
	        [request setCompleteRequest];
	        KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
	        if (response.httpStatusCode == 204) {
	            NSLog(@"Abort multipart upload success!");
	        }
	        else {
	            NSLog(@"error: %@", response.error.description);
	        }

```

##### Complete Multipart Upload:

*组装之前上传的块，然后完成分块上传。通过你提供的xml文件，进行分块组装。在xml文件中，块号必须使用升序排列。必须提供每个块的ETag值。*

**方法名：**

\- (KS3CompleteMultipartUploadResponse \*)completeMultipartUpload:(KS3CompleteMultipartUploadRequest \*)completeMultipartUploadRequest;

**参数说明：**

* completeMultipartUploadRequest：组装上传所有块的KS3CompleteMultipartUploadRequest对象，它包含指定的Bucket名称，Object名称，此次上传的Upload ID，需要组装的所有块的信息数据

**返回结果：**

* 组装所有块的HTTP请求响应

KS3CompleteMultipartUploadResponse响应包括以下内容

1. httpStatusCode：Http请求返回的状态码，200表示请求成功，400表示客户端请求错误，403表示签名错误或本地日期时间错误

2. responseHeader:Http请求响应报头

3. error：错误信息

4. body：响应正文

**代码示例：**
```

	    KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
	    KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
	    for (KS3Part *part in response2.listResult.parts) {
	        [req addPartWithPartNumber:part.partNumber withETag:part.etag];
	    }
	    [req setCompleteRequest];
	    [[KS3Client initialize] completeMultipartUpload:req];
	    if (resp.httpStatusCode != 200) {
	        NSLog(@"#####complete multipart upload failed!!! code: %d#####", resp.httpStatusCode);
	    }

```

##### Multipart Upload Example Code：

*分片上传代码示例*

````

	    NSString *strKey = @"upload_release.txt";
	    NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"bugDownload" ofType:@"txt"];
	    _partSize = 5;
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

	    KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:kBucketName];
	    [initMultipartUploadReq setCompleteRequest];
	    _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
	    if (_muilt == nil) {
	        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
	        return ;
	    }

	    _uploadNum = 1;
	    [self uploadWithPartNumber:_uploadNum];

	    // **** 分块上传文件的块
	    - (void)uploadWithPartNumber:(NSInteger)partNumber
	    {
	        long long partLength = _partSize * 1024.0 * 1024.0;
	        NSData *data = nil;
	        if (_uploadNum == _totalNum) {
	            data = [_fileHandle readDataToEndOfFile];
	        }else {
	            data = [_fileHandle readDataOfLength:(NSUInteger)partLength];
	            [_fileHandle seekToFileOffset:partLength*(_uploadNum)];
	        }

	        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
	        req.delegate = self;
	        req.data = data;
	        req.partNumber = (int32_t)partNumber;
	        req.contentLength = data.length;
	        req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
	        [req setCompleteRequest];
	        [[KS3Client initialize] uploadPart:req];
	    }

	    // **** 分块上传的回调，每块上传结束后都会被调用
	    - (void)request:(KingSoftServiceRequest *)request didCompleteWithResponse:(KingSoftServiceResponse *)response {
	        _uploadNum ++;
	        if (_totalNum < _uploadNum) {
	            KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
	            [req2 setCompleteRequest];
	            KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
	            KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
	            for (KS3Part *part in response2.listResult.parts) {
	                [req addPartWithPartNumber:part.partNumber withETag:part.etag];
	            }
	            [req setCompleteRequest];
	            KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
	            if (resp.httpStatusCode != 200) {
	                NSLog(@"#####complete multipart upload failed!!! code: %d#####", resp.httpStatusCode);
	            }
	        }
	        else {
	            [self uploadWithPartNumber:_uploadNum];
	        }
	    }
	    - (void)request:(KingSoftServiceRequest *)request didFailWithError:(NSError *)error {
	        NSLog(@"error: %@", error.description);
	    }

````


##### Upload Manager
分块上传接口可以实现断点续传等功能，但是由于使用比较复杂，SDK提供了一个封装后的接口——Ks3UploadManager。

使用本接口首先需要初始化一个KS3UploadManager实例。


```
    self.uploadManager = [KS3UploadManager sharedInstanceWithClient:[KS3Client initialize] authHandler:nil];
```

KS3UploadManager接受唯一参数是`authHandler`，此handler用于处理鉴权串签名，每次请求都会用本次请求的信息调用`authHandler`，handler方法内，请求鉴权服务器拿到签名串返回即可。

authHandler如果为`nil`，则需要在客户端设置AK、SK（这种方式不推荐）。设置方法为：`[[KS3Client initialize] setCredentials:[[KS3Credentials alloc] initWithAccessKey:"YOUR_KS3_ACCESS_KEY" withSecretKey:"YOUR_KS3_SECRET_KEY"]];`。

实例创建好后，可以调用上传方法：

```
    // 读取文件信息
    NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"7.6M" ofType:@"mov"];
    NSData *data = [NSData dataWithContentsOfFile:strFilePath];

    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:KingSoftYun_Permission_Public_Read];

    // 创建一次开始分块的请求
    KS3UploadRequest *uploadRequest = [[KS3UploadRequest alloc] initWithKey:@"uploadmanager/sample.mov" inBucket:kUploadBucketName acl:acl grantAcl:nil];
    [uploadRequest setCompleteRequest];
    [uploadRequest setStrKS3Token:[KS3Util getAuthorization:uploadRequest]];

    // 开始上传
    [self.uploadManager putData:data
                        request:uploadRequest
                      blockSize:1 * kMB
                       progress:^(NSString *key, double percent) {
                           NSLog(@"objectKey: %@, progress %lf", key, percent);
                       } cancelSignal:^BOOL(NSString *key) {
                           return false; // 修改这里进行取消
                       } complete:^(KS3Upload *upload, KS3Response *response) {
                           NSLog(@"uploadId: %@, response %@", upload.uploadId, response);
                       } error:^(KS3Upload *upload, NSError *error) {
                           NSLog(@"uploadId: %@, error: %@", upload.uploadId, error);
                       }];
```

目前此接口只支持使用NSData作为参数进行上传。


## 其它
> 完整示例，请见 [KS3-iOS-SDK-Demo][24]

#### 版权所有 （C）金山云科技有限公司
#### Copyright (C) Kingsoft Cloud All rights reserved.


[1]:	http://ks3.ksyun.com/doc/
[2]:	http://ks3.ksyun.com/doc/index.html
[3]:	#list-buckets
[4]:	#create-bucket
[5]:	#delete-bucket
[6]:	#get-bucket-acl
[7]:	#put-bucket-acl
[8]:	#head-bucket
[9]:	#get-object
[10]:	#head-object
[11]:	#delete-object
[12]:	#get-object-acl
[13]:	#put-object-acl
[14]:	#list-objects
[15]:	#put-object
[16]:	#put-object-copy
[17]:	#initiate-multipart-upload
[18]:	#upload-part
[19]:	#list-parts
[20]:	#abort-multipart-upload
[21]:	#complete-multipart-upload
[22]:	#multipart-upload-example-code-1
[23]:	#multipart-upload-example-code-2
[24]:	https://github.com/ks3sdk/ks3-ios-sdk/tree/master/KS3SDKDemo/KS3SDKDemo-Token
[25]:	#upload-manager

[image-1]:	http://androidsdktest21.kss.ksyun.com/ks3-android-sdk-authlistener.png
