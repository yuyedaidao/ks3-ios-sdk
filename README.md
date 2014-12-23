#KS3 SDK for iOS使用指南
---

##开发前准备
###SDK使用准备

- 申请AccessKeyID、AccessKeySecret

###SDK配置
SDK以动态库的形式呈现。请将*KS3iOSSDK.framework*添加到项目工程中。如果开发工具是Xcode6，请在*project->target->General*中的‘Embedded Binaries‘中添加*KS3iOSSDK.framework*

###运行环境
支持iOS5及以上版本

##安全性
###使用场景
由于在App端明文存储AccessKeyID、AccessKeySecret是极不安全的，因此推荐的使用场景如下图所示：

![](http://androidsdktest21.kssws.ks-cdn.com/ks3-android-sdk-authlistener.png)

###KingSoftS3Client初始化
- 利用AccessKeyID、AccessKeySecret初始化

对应的初始化代码如下：

```

	    [[KingSoftS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];

```

##SDK介绍及使用
###核心类介绍
- KingSoftS3Client 封装接入Web Service的一系列操作，提供更加便利的接口以及回调。

>为方便开发者使用，SDK在REST API接口返回值基础上进行了封装，具体更多封装类详情请见
>[SDK-REST API:](http://ks3.ksyun.com/doc/index.html)

###资源管理操作
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

###Service操作

####List Buckets：

*列出客户所有的 Bucket 信息*

**方法名：** 

\- (NSArray \*)listBuckets

**参数说明：**  

* 无

**返回结果：**

* 客户所有的bucket列表，列表中每个元素是KSS3Buckket对象  

**代码示例：**
```

	NSArray *arrBuckets = [[KingSoftS3Client initialize] listBuckets];
		   
```

###Bucket操作

####Create Bucket： 

*创建一个新的Bucket*

**方法名：** 

\- (KSS3CreateBucketResponse \*)createBucketWithName:(NSString \*)bucketName

**参数说明：**

* bucketName：指定的Bucket名称

**返回结果：**

* 创建Bucket的HTTP请求响应

**代码示例：**
```

		KSS3CreateBucketResponse *response = [[KingSoftS3Client initialize] createBucketWithName:strBucketName];
```

####Delete Bucket:

*删除指定Bucket*

**方法名：** 

\- (KSS3DeleteBucketResponse \*)deleteBucketWithName:(NSString \*)bucketName;

**参数说明：**

* bucketName ：指定的Bucket名称

**返回结果：**

* 删除Bucket的HTTP请求响应

**代码示例：**
```

		KSS3DeleteBucketResponse *response = [[KingSoftS3Client initialize] deleteBucketWithName:strBucketName];
```

####Get Bucket ACL:

*获取Bucket的ACL*

**方法名：** 

\- (KSS3GetACLResponse \*)getACL:(KSS3GetACLRequest \*)getACLRequest

**参数说明：**

* getACLRequest：获取Bucket ACL的KSS3GetACLRequest对象

**返回结果：**

* 获取Bucket ACL的HTTP请求响应

**代码示例：**
```

		KSS3GetACLRequest *getACLRequest = [[KSS3GetACLRequest alloc] initWithName:@"blues111"];
        KSS3GetACLResponse *response = [[KingSoftS3Client initialize] getACL:getACLRequest];		
        KSS3BucketACLResult *result = response.listBucketsResult;
            if (response.httpStatusCode == 200) {
                NSLog(@"Get bucket acl success!");
                
                NSLog(@"Bucket owner ID:          %@",result.owner.ID);
                NSLog(@"Bucket owner displayName: %@",result.owner.displayName);
                
                for (KSS3Grant *grant in result.accessControlList) {
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

####Put Bucket ACL:

*设置Bucket的ACL，以AccessControlList*

**方法名：** 

\- (KSS3SetGrantACLResponse \*)setGrantACL:(KSS3SetGrantACLRequest \*)setGrantACLRequest;

**参数说明：**

* setGrantACLRequest：设置Bucket Grant ACL的KSS3SetGrantACLRequest对象

**返回结果：**

* 设置Bucket Grant ACL的HTTP请求响应

**代码示例：**
```

		KSS3SetGrantACLRequest *request = [[KSS3SetGrantACLRequest alloc] initWithName:@""];
            KSS3GrantAccessControlList *acl = [[KSS3GrantAccessControlList alloc] init];
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            acl.identifier = @"523678123";
            acl.displayName = @"blues111";
            request.acl = acl;
            KSS3SetGrantACLResponse *response = [[KingSoftS3Client initialize] setGrantACL:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set grant acl success!");
            }
            else {
                NSLog(@"Set grant acl error: %@", response.error.description);
            }

```

*设置Bucket的ACL，以CannedAccessControlList形式*

**方法名：** 

\- (KSS3SetACLResponse \*)setACL:(KSS3SetACLRequest \*)getACLRequest;

**参数说明：**

* getACLRequest：设置Bucket ACL的KSS3SetACLRequest对象

**返回结果：**

* 设置Bucket ACL的HTTP请求响应

**代码示例：**
```

		KSS3SetACLRequest *setACLRequest = [[KSS3SetACLRequest alloc] initWithName:@"blues111"];
        KSS3AccessControlList *acl = [[KSS3AccessControlList alloc] init];
        [acl setContronAccess:KingSoftYun_Permission_Public_Read_Write];
        setACLRequest.acl = acl;
        KSS3SetACLResponse *response = [[KingSoftS3Client initialize] setACL:setACLRequest];
        if (response.httpStatusCode == 200) {
	        NSLog(@"Set bucket acl success!");
        }
        else {
	        NSLog(@"Set bucket acl error: %@", response.error.description);
        }

```

####Head Bucket：

*查询是否已经存在指定Bucket*

**方法名：** 

\- (KSS3HeadBucketResponse \*)headBucket:(KSS3HeadBucketRequest \*)headBucketRequest

**参数说明：**

* headBucketRequest:查询是否已存在指定的Bucket的KSS3HeadBucketRequest请求

**返回结果：**

* 查询是否已存在指定的Bucket的HTTP请求响应

**代码示例：**
```

		KSS3HeadBucketRequest *request = [[KSS3HeadBucketRequest alloc] initWithName:@"blues111"];
            KSS3HeadBucketResponse *response = [[KingSoftS3Client initialize] headBucket:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Head bucket success!");
            }
            else {
                NSLog(@"Head bucket error: %@", response.error.description);
            }

```

###Object操作

####Get Object：

*下载该Object数据*  

**方法名：** 

\- (KSS3DownLoad \*)downloadObjectWithBucketName:(NSString \*)strBucketName key:(NSString \*)strObject downloadBeginBlock:(KSS3DownloadBeginBlock)downloadBeginBlock downloadFileCompleteion:(kSS3DownloadFileCompleteionBlock)downloadFileCompleteion downloadProgressChangeBlock:(KSS3DownloadProgressChangeBlock)downloadProgressChangeBlock failedBlock:(KSS3DownloadFailedBlock)failedBlock;

**参数说明：**

* strBucketName：指定的Bucket名称
* strObjName：指定的Object名称
* downloadBeginBlock：表示下载开始的block
* downloadFileCompleteion：表示下载完成后的block
* downloadProgressChangeBlock:表示下载中的block
* failedBlock：表示错误处理的block

**返回结果：**

* 下载Object的KSS3DownLoad对象

**代码示例：**
```

		[[KingSoftS3Client initialize] downloadObjectWithBucketName:@"photo_hor.jpeg" key:@"alert1" downloadBeginBlock:^(KSS3DownLoad *aDownload, NSURLResponse *responseHeaders) {
                
            } downloadFileCompleteion:^(KSS3DownLoad *aDownload, NSString *filePath) {
                
            } downloadProgressChangeBlock:^(KSS3DownLoad *aDownload, double newProgress) {
                progressView.progress = newProgress;
                
            } failedBlock:^(KSS3DownLoad *aDownload, NSError *error) {
                
            }];

```

####Head Object：

*查询是否已经存在指定Object*

**方法名：** 

\- (KSS3HeadObjectResponse \*)headObject:(KSS3HeadObjectRequest \*)headObjectRequest

**参数说明：**

* headObjectRequest：查询Object是否存在的KSS3HeadObjectRequest对象

**返回结果：**

* 查询指定Object是否存在的HTTP请求响应

**代码示例：**
```

		KSS3HeadObjectRequest *headObjRequest = [[KSS3HeadObjectRequest alloc] initWithName:strBucketName];
            headObjRequest.key = strObjectName;
            KSS3HeadObjectResponse *response = [[KingSoftS3Client initialize] headObject:headObjRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Head object success!");
            }
            else {
                NSLog(@"Head object error: %@", response.error.description);
            }
```

####Delete Object：

*删除指定Object*

**方法名：** 

\- (KSS3DeleteObjectResponse \*)deleteObject:(KSS3DeleteObjectRequest \*)deleteObjectRequest;

**参数说明：**

* deleteObjectRequest：删除Object的KSS3DeleteObjectRequest对象

**返回结果：**

* 删除指定Object是否存在的HTTP请求响应

**代码示例：**
```

		KSS3DeleteObjectRequest *deleteObjRequest = [[KSS3DeleteObjectRequest alloc] initWithName:strBucketName];
            deleteObjRequest.key = strObjectName;
            KSS3DeleteObjectResponse *response = [[KingSoftS3Client initialize] deleteObject:deleteObjRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Delete object success!");
            }
            else {
                NSLog(@"Delete object error: %@", response.error.description);
            }
```

####Get Object ACL：

*获得Object的acl*

**方法名：** 

\- (KSS3GetObjectACLResponse \*)getObjectACL:(KSS3GetObjectACLRequest \*)getObjectACLRequest;

**参数说明：**

* getObjectACLRequest：获取Object ACL的KSS3GetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**代码示例：**
```

		KSS3GetObjectACLRequest  *getObjectACLRequest = [[KSS3GetObjectACLRequest alloc] initWithName:strBucketName];
            getObjectACLRequest.key = strObjectName;
            KSS3GetObjectACLResponse *response = [[KingSoftS3Client initialize] getObjectACL:getObjectACLRequest];
            KSS3BucketACLResult *result = response.listBucketsResult;
            if (response.httpStatusCode == 200) {
                
                NSLog(@"Object owner ID:          %@",result.owner.ID);
                NSLog(@"Object owner displayName: %@",result.owner.displayName);
                
                for (KSS3Grant *grant in result.accessControlList) {
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

####Put Object ACL:

*上传object的acl，以CannedAccessControlList形式*

**方法名：** 

\- (KSS3SetObjectACLResponse \*)setObjectACL:(KSS3SetObjectACLRequest \*)setObjectACLRequest;

**参数说明：**

* setObjectACLRequest：设置Object ACL的KSS3SetObjectACLRequest对象

**返回结果：**

* 获取Object ACL的HTTP请求响应

**代码示例：**
```

		KSS3SetObjectACLRequest *setObjectACLRequest = [[KSS3SetObjectACLRequest alloc] initWithName:strBucketName];
            setObjectACLRequest.key = strObjectName;
            KSS3AccessControlList *acl = [[KSS3AccessControlList alloc] init];
            [acl setContronAccess:KingSoftYun_Permission_Private];
            setObjectACLRequest.acl = acl;
            KSS3SetObjectACLResponse *response = [[KingSoftS3Client initialize] setObjectACL:setObjectACLRequest];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set object acl success!");
            }
            else {
                NSLog(@"Set object acl error: %@", response.error.description);
            }
```

*上传object的acl，以AccessControlList形式*

**方法名：** 

\- (KSS3SetObjectGrantACLResponse \*)setObjectGrantACL:(KSS3SetObjectGrantACLRequest \*)setObjectGrantACLRequest;

**参数说明：**

* setObjectGrantACLRequest：设置Object Grant ACL的KSS3SetObjectGrantACLRequest对象

**返回结果：**

* 获取Object Grant ACL的HTTP请求响应

**代码示例：**
```

		KSS3SetObjectGrantACLRequest *request = [[KSS3SetObjectGrantACLRequest alloc] initWithName:@"blues111"];
            request.key = @"500.txt";
            KSS3GrantAccessControlList *acl = [[KSS3GrantAccessControlList alloc] init];
            [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
            acl.identifier = @"436749834";
            acl.displayName = @"blues111";
            request.acl = acl;
            KSS3SetObjectGrantACLResponse *response = [[KingSoftS3Client initialize] setObjectGrantACL:request];
            if (response.httpStatusCode == 200) {
                NSLog(@"Set object grant acl success!");
            }
            else {
                NSLog(@"Set object grant acl error: %@", response.error.description);
            }
```

####List Objects：

*列举Bucket内的Object*

**方法名：** 

\- (KSS3ListObjectsResponse \*)listObjects:(KSS3ListObjectsRequest \*)listObjectsRequest;

**参数说明：**

* listObjectsRequest：列举指定的Bucket内所有Object的KSS3ListObjectsRequest对象，它可以设置prefix，marker，maxKeys，delimiter四个指定的属性。prefix：限定返回的Object名字都以制定的prefix前缀开始。类型：字符串默认：无；marker：从一个指定的名字marker开始列出Object的名字。类型：字符串默认值：无；maxKeys：设定返回的Object名字数量，返回的数量有可能比设定的少，但是绝不会比设定的多，如果还存在没有返回的Object名字，返回的结果包含<IsTruncated>true</IsTruncated>。类型：字符串默认：10000；delimiter：delimiter是用来对Object名字进行分组的一个字符。包含指定的前缀到第一次出现的delimiter字符的所有Object名字作为一组结果CommonPrefix。类型：字符串默认值：无

**返回结果：**

* 列举指定Bucket内所有Object的HTTP请求响应

**代码示例：**
````

		KSS3ListObjectsRequest *listObjectRequest = [[KSS3ListObjectsRequest alloc] initWithName:@"blues111"];
    	KSS3ListObjectsResponse *response = [[KingSoftS3Client initialize] listObjects:listObjectRequest];
    	_result = response.listBucketsResult;
    	_arrObjects = response.listBucketsResult.objectSummaries;
    
    	for (KSS3ObjectSummary *objectSummary in _arrObjects) {
        	NSLog(@"%@",objectSummary.Key);
        	NSLog(@"%@",objectSummary.owner.ID);
    	}
    	NSLog(@"%@",_result.bucketName);
    	NSLog(@"%ld",_result.objectSummaries.count);
    	NSLog(@"%ld",_result.commonPrefixes.count);
    
    	NSLog(@"KSS3ListObjectsResponse %d",response.httpStatusCode);
````

####Put Object：

*上传Object数据*

**方法名：** 

\- (KSS3PutObjectResponse \*)putObject:(KSS3PutObjectRequest \*)putObjectRequest;


**参数说明：**

* putObjectRequest：上传指定的Object的KSS3PutObjectRequest对象。它需要设置指定的Bucket的名称和Object的名称

**返回结果：**

* 上传指定的Object的HTTP请求响应

**代码示例：**
```

	/* 一定要实现委托方法 (这种情况如果实现委托，返回的reponse一般返回为nil，具体获取返回对象需要到委托方法里面获取，如果不实现委托，reponse不会为nil*/
		KSS3PutObjectRequest *putObjRequest = [[KSS3PutObjectRequest alloc] initWithName:@"testcreatebucket-wf111"];
            putObjRequest.delegate = self;
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
            putObjRequest.data = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedIfSafe error:nil];
            putObjRequest.filename = [fileName lastPathComponent];
            [[KingSoftS3Client initialize] putObject:putObjRequest];

```

####Initiate Multipart Upload：
 
*调用这个接口会初始化一个分块上传，KS3 Server会返回一个upload id, upload id 用来标识属于当前object的具体的块，并且用来标识完成分块上传或者取消分块上传*

**方法名：** 

\- (KSS3MultipartUpload \*)initiateMultipartUploadWithKey:(NSString \*)theKey withBucket:(NSString \*)theBucket


**参数说明：**

* theKey：指定的Object名称
* theBucket：指定的Bucket名称

**返回结果：**

* 初始化分块上传的HTTP响应，KSS3MultipartUpload类型的对象里面包含了指定的Object名称，Bucket名称，此次上传的Upload ID，Object的Owner，初始化日期

**代码示例：**
```

	KSS3MultipartUpload *muilt = [[KingSoftS3Client initialize] initiateMultipartUploadWithKey:strObjectName withBucket:strBucketName];

```

####Upload Part：

*初始化分块上传后，上传分块接口。Part number 是标识每个分块的数字，介于0-10000之间。除了最后一块，每个块必须大于等于5MB，最后一块没有这个限制。*

**方法名：** 

\- (KSS3UploadPartResponse \*)uploadPart:(KSS3UploadPartRequest \*)uploadPartRequest;

**参数说明：**

* uploadPartRequest：上传块的KSS3UploadPartRequest对象，它需要指定上传的Object名称，指定的Bucket的名称，分块的块号，此块的数据

**返回结果：**

* 块上传的HTTP请求响应

**代码示例：**
```

		KSS3UploadPartRequest *req = [[KSS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
                req.delegate = self;
                req.data = data;
                req.partNumber = partNumber;
                req.contentLength = data.length;
                KSS3UploadPartResponse *response = [[KingSoftS3Client initialize] uploadPart:req];

```

####List Parts:

*罗列出已经上传的块*

**方法名：** 

\- (KSS3ListPartsResponse \*)listParts:(KSS3ListPartsRequest \*)listPartsRequest;

**参数说明：**

* listPartsRequest：罗列已经上传的块的KSS3ListPartsRequest对象，它包含指定的Object的名称，此次上传的Upload ID，maxParts，它表示块大小限制，类型：字符串，默认值：None，partNumberMarker，它表示块号标记，将返回大于此块号的分块，类型：字符串，默认值：None

**返回结果：**

* 罗列已经上传的块的HTTP请求响应，它包含了类型为KSS3ListPartsResult的请求的结果，它包含指定的Bucket名称，指定的Object名称，此次上传的Upload ID，partNumberMarker，它表示块号标记，将返回大于此块号的分块，maxParts，它表示块大小限制，isTruncated，它表示是否取完分块，Owner它表示创建分块上传的用户

**代码示例：**
```

		KSS3ListPartsRequest *req2 = [[KSS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        KSS3ListPartsResponse *response2 = [[KingSoftS3Client initialize] listParts:req2];

```

####Abort Multipart Upload:

*取消分块上传。*

**方法名：** 

\- (KSS3AbortMultipartUploadResponse \*)abortMultipartUpload:(KSS3AbortMultipartUploadRequest \*)abortMultipartRequest

**参数说明：**

* abortMultipartRequest：取消分块上传的KSS3AbortMultipartUploadRequest对象，它需要使用KSS3MultipartUpload对象来初始化，初始化包括指定的Bucket名称，Object的名称，分块上传的Upload ID

**返回结果：**

* 取消上传的HTTP请求响应

**代码示例：**
```

		KSS3AbortMultipartUploadRequest *request = [[KSS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
            KSS3AbortMultipartUploadResponse *response = [[KingSoftS3Client initialize] abortMultipartUpload:request];
            if (response.httpStatusCode == 204) {
                NSLog(@"Abort multipart upload success!");
            }
            else {
                NSLog(@"error: %@", response.error.description);
            }
		
```

####Complete Multipart Upload:

*组装之前上传的块，然后完成分块上传。通过你提供的xml文件，进行分块组装。在xml文件中，块号必须使用升序排列。必须提供每个块的ETag值。*

**方法名：** 

\- (KSS3CompleteMultipartUploadResponse \*)completeMultipartUpload:(KSS3CompleteMultipartUploadRequest \*)completeMultipartUploadRequest;

**参数说明：**

* completeMultipartUploadRequest：组装上传所有块的KSS3CompleteMultipartUploadRequest对象，它包含指定的Bucket名称，Object名称，此次上传的Upload ID，需要组装的所有块的信息数据

**返回结果：**

* 组装所有块的HTTP请求响应

**代码示例：**
```

		KSS3ListPartsResponse *response2 = [[KingSoftS3Client initialize] listParts:req2];
        KSS3CompleteMultipartUploadRequest *req = [[KSS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        for (KSS3Part *part in response2.listResult.parts) {
            [req addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
        [[KingSoftS3Client initialize] completeMultipartUpload:req];

```

####Multipart Upload Example Code:

*分片上传代码示例*

````

		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"bugDownload" ofType:@"txt"]];
        long long fileLength = [[fileHandle availableData] length];
        long long partLength = 5*1024.0*1024.0;
        _partInter = (ceilf((float)fileLength / (float)partLength));
        [fileHandle seekToFileOffset:0];
            
        _muilt = [[KingSoftS3Client initialize] initiateMultipartUploadWithKey:@"500.txt" withBucket:@"blues111"];
        for (NSInteger i = 0; i < _partInter; i ++) {
	        NSData *data = nil;
	         if (i == _partInter - 1) {
	         	data = [fileHandle readDataToEndOfFile];
	         } 
	         else {
	         	data = [fileHandle readDataOfLength:partLength];
	           [fileHandle seekToFileOffset:partLength*(i+1)];
            }
            KSS3UploadPartRequest *req = [[KSS3UploadPartRequest alloc] initWithMultipartUpload:_muilt];
            req.delegate = self;
            req.data = data;
            req.partNumber = (int32_t)i+1;
            req.contentLength = data.length;
            [[KingSoftS3Client initialize] uploadPart:req];
        }
                
        // **** 分块上传的回调，每块上传结束后都会被调用
		- (void)request:(KingSoftServiceRequest *)request didCompleteWithResponse:(KingSoftServiceResponse *)response {
    		_upLoadCount++;
    		if (_partInter == _upLoadCount) {
        		KSS3ListPartsRequest *req2 = [[KSS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        		KSS3ListPartsResponse *response2 = [[KingSoftS3Client initialize] listParts:req2];
        		KSS3CompleteMultipartUploadRequest *req = [[KSS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
        		NSLog(@" - - - - - %@",response2.listResult.parts);
        		for (KSS3Part *part in response2.listResult.parts) {
            		[req addPartWithPartNumber:part.partNumber withETag:part.etag];
        		}
        		[[KingSoftS3Client initialize] completeMultipartUpload:req];
    		}
		}
		- (void)request:(KingSoftServiceRequest *)request didFailWithError:(NSError *)error {
    		NSLog(@"error: %@", error.description);
     	}

````

##其它
>完整示例，请见 [KS3-iOS-SDK-Demo](http://www.ksyun.com/doc/4358412.html) 

