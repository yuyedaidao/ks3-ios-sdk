##KS3 SDK for iOS
---

###简介
####金山标准存储服务
金山标准存储服务（Kingsoft Standard Storage Service），简称KS3，是金山云为开发者提供无限制、多备份、分布式的低成本存储空间解决方案。KS3 SDK for iOS替开发者解决了授权、存储资源管理以及上传下载等复杂问题，提供基于iOS平台的简单易用API，让开发者方便地构建基于KS3服务的移动应用。
>更好的了解KS3，请咨询[文档中心](http://ks3.ksyun.com/doc/)

####概念和术语
#####AccessKeyID、AccessKeySecret
使用KS3，您需要KS3颁发给您的AccessKeyID（长度为20个字符的ASCII字符串）和AccessKeySecret（长度为40个字符的ASCII字符串）。AccessKeyID用于标识客户的身份，AccessKeySecret作为私钥形式存放于客户服务器不在网络中传递。AccessKeySecret通常用作计算请求签名的密钥，用以保证该请求是来自指定的客户。使用AccessKeyID进行身份识别，加上AccessKeySecret进行数字签名，即可完成应用接入与认证授权。
#####Service
KS3提供给用户的虚拟存储空间，在这个虚拟空间中，每个用户可拥有一个到多个Bucket。

#####Bucket
Bucket是存放Object的容器，所有的Object都必须存放在特定的Bucket中。每个用户最多可以创建20个Bucket，每个Bucket中可以存放无限多个Object。Bucket不能嵌套，每个Bucket中只能存放Object，不能再存放Bucket，Bucket下的Object是一个平级的结构。Bucket的名称全局唯一且命名规则与DNS命名规则相同：

* 仅包含小写英文字母（a-z），数字，点（.），中线，即： abcdefghijklmnopqrstuvwxyz0123456789.-
* 必须由字母或数字开头
* 长度在3和255个字符之间
* 不能是IP的形式，类似192.168.0.1
* 不能以kss开头

#####Object
在KS3中，用户操作的基本数据单元是Object。单个Object允许存储0~1TB的数据。 Object 包含key和data。其中，key是Object的名字；data是Object 的数据。key为UTF-8编码，且编码后的长度不得超过1024个字节。

#####ACL
**ACL**(Access Control List)目前支持{READ, WRITE, FULL\_CONTROL}三种权限，通过一个授权列表的形式来指明不同访问者对指定资源的访问权限。

**Canned ACL**（Canned Access Control List）目前支持{PRIVATE，PUBLIC\_READ，PUBLIC\_READ\_WRITE}三种权限。通过对Bucket或Object设置Canned ACL，可以设置该资源对所有访问者的通用访问权限。

对于BUCKET的拥有者，总是FULL\_CONTROL。可以设置匿名用户为READ，WRITE, 或者FULL\_CONTROL权限。

对于BUCKET来说，READ是指罗列bucket中文件的功能。WRITE是指可以上传、删除BUCKET中的文件。FULL\_CONTROL则包含所有操作。

对于OBJECT来说，READ是指可以查看或者下载文件。WRITE无意义。FULL_CONTROL则包含所有操作。

当使用更改指定资源访问权限的API时（如：setACL、setObjectACL），可以以下任意一种方式指明该资源的访问权限:

**AccessControlList形式**：
 ```

		KS3SetGrantACLRequest *request = [[KS3SetGrantACLRequest alloc] initWithName:@"your-bucket-name"];
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            acl.identifier = @"user-identifier";
            acl.displayName = @"user-displayName";
            request.acl = acl;
            KS3SetGrantACLResponse *response = [[KS3Client initialize] setGrantACL:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set grant acl success!");
            }
            else {
                NSLog(@"Set grant acl error: %@", response.error.description);
            }
 ```

**CannedAccessControlList**：
 ```

		KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Private];
 ```

#####请求签名
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


###开发前准备
####SDK使用准备

- 申请AccessKeyID、AccessKeySecret

####SDK配置
SDK以动态库的形式呈现。请将*KS3iOSSDK.framework*添加到项目工程中。如果开发工具是Xcode6，请在*project->target->General*中的‘Embedded Binaries‘中添加*KS3iOSSDK.framework*

####运行环境
支持iOS5及以上版本

###安全性
####使用场景
由于在App端明文存储AccessKeyID、AccessKeySecret是极不安全的，因此推荐的使用场景如下图所示：

![](http://androidsdktest21.kssws.ks-cdn.com/ks3-android-sdk-authlistener.png)

####KS3Client初始化
- 利用AccessKeyID、AccessKeySecret初始化

对应的初始化代码如下：

```

	    [[KS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];

```

###SDK介绍及使用
####核心类介绍
- KS3Client 封装接入Web Service的一系列操作，提供更加便利的接口以及回调。

>为方便开发者使用，SDK在REST API接口返回值基础上进行了封装，具体更多封装类详情请见
>[SDK-REST API:](http://ks3.ksyun.com/doc/index.html)

####资源管理操作
* [List Buckets](#list-buckets) 列出客户所有的Bucket信息
* [Create Bucket](#create-bucket) 创建一个新的Bucket
* [Delete Bucket](#delete-bucket) 删除指定Bucket
* [Get Bucket ACL](#get-bucket-acl) 获取Bucket的ACL
* [Put Bucket ACL](#put-bucket-acl) 设置Bucket的ACL
* [Head Bucket](#head-bucket) 查询是否已经存在指定Bucket
* [Get Object](#get-object) 下载Object数据
* [Head Object](#head-object) 查询是否已经存在指定Object
* [Delete Object](#delete-object) 删除指定Object
* [Get Object ACL](#get-object-acl) 获得Bucket的acl
* [Put Object ACL](#put-object-acl) 上传object的acl
* [List Objects](#list-objects) 列举Bucket内的Object
* [Put Object](#put-object) 上传Object数据
* [Initiate Multipart Upload](#initiate-multipart-upload) 调用这个接口会初始化一个分块上传
* [Upload Part](#upload-part) 上传分块
* [List Parts](#list-parts) 罗列出已经上传的块
* [Abort Multipart Upload](#abort-multipart-upload) 取消分块上传
* [Complete Multipart Upload](#complete-multipart-upload) 组装所有分块上传的文件
* [Multipart Upload Example Code](#multipart-upload-example-code) 分片上传代码示例

####Service操作

#####List Buckets：

*列出客户所有的 Bucket 信息*

**方法名：** 

\- (NSArray \*)listBuckets;

**参数说明：**  

* 无

**返回结果：**

* 客户所有的bucket列表，列表中每个元素是KS3Bucket对象  

**代码示例：**
```

	NSArray *arrBuckets = [[KS3Client initialize] listBuckets];
		   
```

####Bucket操作

#####Create Bucket： 

*创建一个新的Bucket*

**方法名：** 

\- (KS3CreateBucketResponse \*)createBucketWithName:(NSString \*)bucketName;

**参数说明：**

* bucketName：指定的Bucket名称

**返回结果：**

* 创建Bucket的HTTP请求响应

**代码示例：**
```

		KS3CreateBucketResponse *response = [[KS3Client initialize] createBucketWithName:@"your-bucket-name"];
```

#####Delete Bucket:

*删除指定Bucket*

**方法名：** 

\- (KS3DeleteBucketResponse \*)deleteBucketWithName:(NSString \*)bucketName;

**参数说明：**

* bucketName ：指定的Bucket名称

**返回结果：**

* 删除Bucket的HTTP请求响应

**代码示例：**
```

		KS3DeleteBucketResponse *response = [[KS3Client initialize] deleteBucketWithName:@"your-bucket-name"];
```

#####Get Bucket ACL:

*获取Bucket的ACL*

**方法名：** 

\- (KS3GetACLResponse \*)getACL:(KS3GetACLRequest \*)getACLRequest

**参数说明：**

* getACLRequest：获取Bucket ACL的KS3GetACLRequest对象

**返回结果：**

* 获取Bucket ACL的HTTP请求响应

**代码示例：**
```

		KS3GetACLRequest *getACLRequest = [[KS3GetACLRequest alloc] initWithName:@"your-bucket-name"];
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

#####Put Bucket ACL:

*设置Bucket的ACL，以AccessControlList*

**方法名：** 

\- (KS3SetGrantACLResponse \*)setGrantACL:(KS3SetGrantACLRequest \*)setGrantACLRequest;

**参数说明：**

* setGrantACLRequest：设置Bucket Grant ACL的KS3SetGrantACLRequest对象

**返回结果：**

* 设置Bucket Grant ACL的HTTP请求响应

**代码示例：**
```

		KS3SetGrantACLRequest *request = [[KS3SetGrantACLRequest alloc] initWithName:@"your-bucket-name"];
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            acl.identifier = @"user-identifier";
            acl.displayName = @"user-displayName";
            request.acl = acl;
            KS3SetGrantACLResponse *response = [[KS3Client initialize] setGrantACL:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set grant acl success!");
            }
            else {
                NSLog(@"Set grant acl error: %@", response.error.description);
            }

```

*设置Bucket的ACL，以CannedAccessControlList形式*

**方法名：** 

\- (KS3SetACLResponse \*)setACL:(KS3SetACLRequest \*)getACLRequest;

**参数说明：**

* getACLRequest：设置Bucket ACL的KS3SetACLRequest对象

**返回结果：**

* 设置Bucket ACL的HTTP请求响应

**代码示例：**
```

		KS3SetACLRequest *setACLRequest = [[KS3SetACLRequest alloc] initWithName:@"your-bucket-name"];
        KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
        [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
        setACLRequest.acl = acl;
        KS3SetACLResponse *response = [[KS3Client initialize] setACL:setACLRequest];
        if (response.httpStatusCode == 200) {
	        NSLog(@"Set bucket acl success!");
        }
        else {
	        NSLog(@"Set bucket acl error: %@", response.error.description);
        }

```

#####Head Bucket：

*查询是否已经存在指定Bucket*

**方法名：** 

\- (KS3HeadBucketResponse \*)headBucket:(KS3HeadBucketRequest \*)headBucketRequest;

**参数说明：**

* headBucketRequest:查询是否已存在指定的Bucket的KS3HeadBucketRequest请求

**返回结果：**

* 查询是否已存在指定的Bucket的HTTP请求响应

**代码示例：**
```

		KS3HeadBucketRequest *request = [[KS3HeadBucketRequest alloc] initWithName:@"your-bucket-name"];
            KS3HeadBucketResponse *response = [[KS3Client initialize] headBucket:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Head bucket success!");
            }
            else {
                NSLog(@"Head bucket error: %@", response.error.description);
            }

```

####Object操作

#####Get Object：

*下载该Object数据*  

**方法名：** 

\- (KS3DownLoad \*)downloadObjectWithBucketName:(NSString \*)strBucketName key:(NSString \*)strObject downloadBeginBlock:(KS3DownloadBeginBlock)downloadBeginBlock downloadFileCompleteion:(KS3DownloadFileCompleteionBlock)downloadFileCompleteion downloadProgressChangeBlock:(KS3DownloadProgressChangeBlock)downloadProgressChangeBlock failedBlock:(KS3DownloadFailedBlock)failedBlock;

**参数说明：**

* strBucketName：指定的Bucket名称
* strObjName：指定的Object名称
* downloadBeginBlock：表示下载开始的block
* downloadFileCompleteion：表示下载完成后的block
* downloadProgressChangeBlock:表示下载中的block
* failedBlock：表示错误处理的block

**返回结果：**

* 下载Object的KS3DownLoad对象

**代码示例：**
```

		[[KS3Client initialize] downloadObjectWithBucketName:@"your-bucket-name" key:@"object-name" downloadBeginBlock:^(KS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
                
            } downloadFileCompleteion:^(KS3DownLoad *aDownload, NSString *filePath) {
                
            } downloadProgressChangeBlock:^(KS3DownLoad *aDownload, double newProgress) {
                progressView.progress = newProgress;
                
            } failedBlock:^(KS3DownLoad *aDownload, NSError *error) {
                
            }];

```

#####Head Object：

*查询是否已经存在指定Object*

**方法名：** 

\- (KS3HeadObjectResponse \*)headObject:(KS3HeadObjectRequest \*)headObjectRequest;

**参数说明：**

* headObjectRequest：查询Object是否存在的KS3HeadObjectRequest对象

**返回结果：**

* 查询指定Object是否存在的HTTP请求响应

**代码示例：**
```

		KS3HeadObjectRequest *headObjRequest = [[KS3HeadObjectRequest alloc] initWithName:@"your-bucket-name"];
            headObjRequest.key = @"object-name";
            KS3HeadObjectResponse *response = [[KS3Client initialize] headObject:headObjRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Head object success!");
            }
            else {
                NSLog(@"Head object error: %@", response.error.description);
            }
```

#####Delete Object：

*删除指定Object*

**方法名：** 

\- (KS3DeleteObjectResponse \*)deleteObject:(KS3DeleteObjectRequest \*)deleteObjectRequest;

**参数说明：**

* deleteObjectRequest：删除Object的KS3DeleteObjectRequest对象

**返回结果：**

* 删除指定Object是否存在的HTTP请求响应

**代码示例：**
```

		KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:@"your-bucket-name"];
            deleteObjRequest.key = @"object-name";
            KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Delete object success!");
            }
            else {
                NSLog(@"Delete object error: %@", response.error.description);
            }
```

#####Get Object ACL：

*获得Object的acl*

**方法名：** 

\- (KS3GetObjectACLResponse \*)getObjectACL:(KS3GetObjectACLRequest \*)getObjectACLRequest;

**参数说明：**

* getObjectACLRequest：获取Object ACL的KS3GetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**代码示例：**
```

		KS3GetObjectACLRequest  *getObjectACLRequest = [[KS3GetObjectACLRequest alloc] initWithName:@"your-bucket-name"];
            getObjectACLRequest.key = @"object-name";
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

#####Put Object ACL:

*上传object的acl，以CannedAccessControlList形式*

**方法名：** 

\- (KS3SetObjectACLResponse \*)setObjectACL:(KS3SetObjectACLRequest \*)setObjectACLRequest;

**参数说明：**

* setObjectACLRequest：设置Object ACL的KS3SetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**代码示例：**
```

		KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:@"your-bucket-name"];
            setObjectACLRequest.key = strObjectName;
            KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Private];
            setObjectACLRequest.acl = acl;
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

**代码示例：**
```

		KS3SetObjectGrantACLRequest *request = [[KS3SetObjectGrantACLRequest alloc] initWithName:@"your-bucket-name"];
            request.key = @"object-name";
            KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            acl.identifier = @"user-identifier";
            acl.displayName = @"user-displayName";
            request.acl = acl;
            KS3SetObjectGrantACLResponse *response = [[KS3Client initialize] setObjectGrantACL:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set object grant acl success!");
            }
            else {
                NSLog(@"Set object grant acl error: %@", response.error.description);
            }
```

#####List Objects：

*列举Bucket内的Object*

**方法名：** 

\- (KS3ListObjectsResponse \*)listObjects:(KS3ListObjectsRequest \*)listObjectsRequest;

**参数说明：**

* listObjectsRequest：列举指定的Bucket内所有Object的KS3ListObjectsRequest对象，它可以设置prefix，marker，maxKeys，delimiter四个指定的属性。prefix：限定返回的Object名字都以制定的prefix前缀开始。类型：字符串默认：无；marker：从一个指定的名字marker开始列出Object的名字。类型：字符串默认值：无；maxKeys：设定返回的Object名字数量，返回的数量有可能比设定的少，但是绝不会比设定的多，如果还存在没有返回的Object名字，返回的结果包含<IsTruncated>true</IsTruncated>。类型：字符串默认：10000；delimiter：delimiter是用来对Object名字进行分组的一个字符。包含指定的前缀到第一次出现的delimiter字符的所有Object名字作为一组结果CommonPrefix。类型：字符串默认值：无

**返回结果：**

* 列举指定Bucket内所有Object的HTTP请求响应

**代码示例：**
````

		KS3ListObjectsRequest *listObjectRequest = [[KS3ListObjectsRequest alloc] initWithName:@"your-bucket-name"];
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

#####Put Object：

*上传Object数据*

**方法名：** 

\- (KS3PutObjectResponse \*)putObject:(KS3PutObjectRequest \*)putObjectRequest;


**参数说明：**

* putObjectRequest：上传指定的Object的KS3PutObjectRequest对象。它需要设置指定的Bucket的名称和Object的名称

**返回结果：**

* 上传指定的Object的HTTP请求响应

**代码示例：**
```

	/* 一定要实现委托方法 (这种情况如果实现委托，返回的reponse一般返回为nil，具体获取返回对象需要到委托方法里面获取，如果不实现委托，reponse不会为nil*/
		KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:@"your-bucket-name"];
            putObjRequest.delegate = self;
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
            putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
            putObjRequest.filename = [fileName lastPathComponent];
            [[KS3Client initialize] putObject:putObjRequest];

```

#####Initiate Multipart Upload：
 
*调用这个接口会初始化一个分块上传，KS3 Server会返回一个upload id, upload id 用来标识属于当前object的具体的块，并且用来标识完成分块上传或者取消分块上传*

**方法名：** 

\- (KS3MultipartUpload \*)initiateMultipartUploadWithKey:(NSString \*)theKey withBucket:(NSString \*)theBucket;


**参数说明：**

* theKey：指定的Object名称
* theBucket：指定的Bucket名称

**返回结果：**

* 初始化分块上传的HTTP响应，KS3MultipartUpload类型的对象里面包含了指定的Object名称，Bucket名称，此次上传的Upload ID，Object的Owner，初始化日期

**代码示例：**
```

	KS3MultipartUpload *muilt = [[KS3Client initialize] initiateMultipartUploadWithKey:@"object-name" withBucket:@"your-bucket-name"];

```

#####Upload Part：

*初始化分块上传后，上传分块接口。Part number 是标识每个分块的数字，介于0-10000之间。除了最后一块，每个块必须大于等于5MB，最后一块没有这个限制。*

**方法名：** 

\- (KS3UploadPartResponse \*)uploadPart:(KS3UploadPartRequest \*)uploadPartRequest;

**参数说明：**

* uploadPartRequest：上传块的KS3UploadPartRequest对象，它需要指定上传的Object名称，指定的Bucket的名称，分块的块号，此块的数据

**返回结果：**

* 块上传的HTTP请求响应

**代码示例：**
```

		KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
                req.delegate = self;
                req.data = data;
                req.partNumber = partNumber;
                req.contentLength = data.length;
                KS3UploadPartResponse *response = [[KS3Client initialize] uploadPart:req];

```

#####List Parts:

*罗列出已经上传的块*

**方法名：** 

\- (KS3ListPartsResponse \*)listParts:(KS3ListPartsRequest \*)listPartsRequest;

**参数说明：**

* listPartsRequest：罗列已经上传的块的KS3ListPartsRequest对象，它包含指定的Object的名称，此次上传的Upload ID，maxParts，它表示块大小限制，类型：字符串，默认值：None，partNumberMarker，它表示块号标记，将返回大于此块号的分块，类型：字符串，默认值：None

**返回结果：**

* 罗列已经上传的块的HTTP请求响应，它包含了类型为KS3ListPartsResult的请求的结果，它包含指定的Bucket名称，指定的Object名称，此次上传的Upload ID，partNumberMarker，它表示块号标记，将返回大于此块号的分块，maxParts，它表示块大小限制，isTruncated，它表示是否取完分块，Owner它表示创建分块上传的用户

**代码示例：**
```

		KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];

```

#####Abort Multipart Upload:

*取消分块上传。*

**方法名：** 

\- (KS3AbortMultipartUploadResponse \*)abortMultipartUpload:(KS3AbortMultipartUploadRequest \*)abortMultipartRequest;

**参数说明：**

* abortMultipartRequest：取消分块上传的KS3AbortMultipartUploadRequest对象，它需要使用KS3MultipartUpload对象来初始化，初始化包括指定的Bucket名称，Object的名称，分块上传的Upload ID

**返回结果：**

* 取消上传的HTTP请求响应

**代码示例：**
```

		KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
            KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
            if (response.httpStatusCode == 204) {
                NSLog(@"Abort multipart upload success!");
            }
            else {
                NSLog(@"error: %@", response.error.description);
            }
		
```

#####Complete Multipart Upload:

*组装之前上传的块，然后完成分块上传。通过你提供的xml文件，进行分块组装。在xml文件中，块号必须使用升序排列。必须提供每个块的ETag值。*

**方法名：** 

\- (KS3CompleteMultipartUploadResponse \*)completeMultipartUpload:(KS3CompleteMultipartUploadRequest \*)completeMultipartUploadRequest;

**参数说明：**

* completeMultipartUploadRequest：组装上传所有块的KS3CompleteMultipartUploadRequest对象，它包含指定的Bucket名称，Object名称，此次上传的Upload ID，需要组装的所有块的信息数据

**返回结果：**

* 组装所有块的HTTP请求响应

**代码示例：**
```

		KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        for (KS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        [[KS3Client initialize] completeMultipartUpload:req];

```

#####Multipart Upload Example Code:

*分片上传代码示例*

````

		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"]];
        long long fileLength = [[fileHandle availableData] length];
        long long partLength = 5*1024.0*1024.0;
        _partInter = (ceilf((float)fileLength / (float)partLength));
        [fileHandle seekToFileOffset:0];
            
        _muilt = [[KS3Client initialize] initiateMultipartUploadWithKey:@"object-name" withBucket:@"your-bucket-name"];
        for (NSInteger i = 0; i < _partInter; i ++) {
	        NSData *data = nil;
	         if (i == _partInter - 1) {
	         	data = [fileHandle readDataToEndOfFile];
	         } 
	         else {
	         	data = [fileHandle readDataOfLength:partLength];
	           [fileHandle seekToFileOffset:partLength*(i+1)];
            }
            KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
            req.delegate = self;
            req.data = data;
            req.partNumber = (int32_t)i+1;
            req.contentLength = data.length;
            [[KS3Client initialize] uploadPart:req];
        }
                
        // **** 分块上传的回调，每块上传结束后都会被调用
		- (void)request:(KingSoftServiceRequest *)request didCompleteWithResponse:(KingSoftServiceResponse *)response {
    		_upLoadCount++;
    		if (_partInter == _upLoadCount) {
        		KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        		KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        		KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        		NSLog(@" - - - - - %@",response2.listResult.parts);
        		for (KS3Part *part in response2.listResult.parts) {
            		[req addPartWithPartNumber:part.partNumber withETag:part.etag];
        		}
        		[[KS3Client initialize] completeMultipartUpload:req];
    		}
		}
		- (void)request:(KingSoftServiceRequest *)request didFailWithError:(NSError *)error {
    		NSLog(@"error: %@", error.description);
     	}

````

##其它
>完整示例，请见 [KS3-iOS-SDK-Demo](http://www.ksyun.com/doc/4358412.html) 

####  版权所有 （C）金山云科技有限公司  
####  Copyright (C) Kingsoft Cloud All rights reserved.
