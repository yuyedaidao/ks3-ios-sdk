### v2.1.0 改动日志 2017.05.05
* 添加KS3UploadManager，提供封装后的简易上传接口

### v2.0.0 改动日志 2017.04.26
* 修复kSYHeader多返回换行导致可能的签名错误
* 修复异步上传回调在非主线程运行不回调问题
* 更新项目结构及SDK整合方式

### v1.7.2 改动日志 2016.11.30
* 支持HTTPS

### v1.7.1 改动日志 2016.07.27
* 支持向绑定bucket的自定义域名分块上传和下载文件
* 重构putObject接口（支持自定义域名上传）
* 提供打包framework的脚本

### v1.7.0 改动日志 2016.07.18
* 增加向用户绑定的域名上传文件的示例（参见beginSingleUpload方法中注释）
* encode函数增加特殊字符的替换操作（和API统一）
* 删除测试AK/SK,运行Demo前请先在AppDelegate.m中设置您账号的AK/SK，在相应的ViewController.m文件的头部指定您的bucket（即kUploadBucketName宏定义）

### v1.6.0 改动日志 2016.06.27
* 默认为北京region，杭州region老用户仍可以使用
* 增加put object上传查看response回调的示例
* 修正分块上传恢复时的块号问题
* 不再维护AK/SK Demo，只维护KS3SDKDemo-Token
* 增加视频转码和截图异步处理请求的Demo

### v1.5.1 改动日志 2016-05-09
* SDK取消杭州域名,默认为北京
* 增加设置自定义域名，详情请看KS3Client.h，
   - (void)setBucketDomain:(NSString \*)domainRegion;

### v1.5.0 改动日志 2016-05-06

* 分块上传支持断点续传，上传为了简化流程的复杂度，每次都是从初始化开始，依步骤进行：
    1.初始化上传，需app记录uploadId，如不存在uploadId，从第一块开始上传；如已存在uploadId，用已经存在的uploadId，发listPart请求，返回已经上传成功的数据块，进行第二步,从上传断点数据块号开始上传。
        2.分块上传数据块，同步的发uploadPart请求，一块块上传，直至所有块传输成功。若中间断开，下次开始从第一步重新开始。
            3.完成上传，发complete请求，httpCode = 200，成功。
            Tips:1.基于分块上传的原理，上传暂停继续会有最多一个块的进度回退。
            2.具体用法请看KS3SDKDemo,Token方式与AKSK方式相同

### v1.4.3 改动日志 2016-04-28

* 解决分块上传崩溃问题，静态库请在Builid setting -> Other link lags 加上 -all\_load
* 修改加载framework说明，请详细阅读加载framework说明

### v1.4.2 改动日志 2016-04-25

* 修改加载framework说明，整理并重新打包静态库与动态库
* 解决暂停下载导致的cpu占用过高

### v1.4.1 改动日志 2016-04-08

* 将读取相册分块方法写入KS3Client文件
* 增加SDK设置bucket所在地区，默认北京

### v1.4.0 改动日志 2016-03-30

* 增加上传类型：从相册上传，增加相册视频文件分块上传，可见Token-Demo
* 增加相应注释，客户端建议使用Token方式上传，获取Token，应由App Server 计算后返回，上传下载请直接看KS3SDKDemo-Token工程下ObjectViewController.m
* Demo所用为测试账号，如需测试，请使用自身账号，更改AKSK与BucketName，BucketKey后测试

* 如需更多帮助，请看KS3 API文档  ： http://ks3.ksyun.com/doc/index.html

### v1.3.0 改动日志 2016-02-25

* 增添下载断点续传，具体可见KS3SDKDemo-Token
* 增添上传进度回调，取消上传功能，具体可见KS3SDKDemo-Token

### V1.2.0 改动日志 2015-12-28

* 修改下载时在后台线程去下载不执行下载回调，导致下载不能成功的bug


## V.1.1.0 改动日志 (2015-09-02)
---

* 增加静态库， 静态库兼容到IOS6.0。
*  APP兼容IOS8.0以下的需要用静态库。 原有的集成动态库的，如果遇到提交AppStore是因为KS3SDK引起的无法正常提交的，建议下载并更新为staticFramework中对应的静态库，同时在Target->General->Embedded Binaries中删除对应的KS3SDK

---
