//
//  KingSoftServiceRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ServiceRequest.h"
#import "KS3AuthUtils.h"
#import "KS3ClientException.h"
#import "KS3Client.h"
#import "KS3LogModel.h"

@implementation KS3ServiceRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentMd5 = @"";
        _contentType = @"";
        _kSYHeader = @"";
        _kSYResource = @"";
        _host = [[NSMutableString alloc] initWithString:@""];
        _requestDate = [NSDate date];
        _strDate = [KS3AuthUtils strDateWithDate:_requestDate andType:@"GMT"];
        _strKS3Token = nil;
        [KS3Client initialize].totalRequestCount++;
        _urlRequest = [KS3URLRequest new];
        _logModel = [KS3LogModel new];
        _logModel.ksyErrorcode = -2;
    }
    return self;
}

- (void)setCompleteRequest
{
    
}
- (void)sign
{
    [KS3AuthUtils signRequestV4:self urlRequest:_urlRequest headers:nil payload:nil credentials:_credentials];
}

- (KS3URLRequest *)configureURLRequest
{
    [self sign];
    return _urlRequest;
    
}

- (KS3ClientException *)validate
{
    return nil;
}
- (void)cancel
{
    [self.urlConnection cancel];
}

- (void)setEndPointWith:(NSString *)endPoint
{
    
    NSLog(@"old host is %@",self.host);
    NSRange range = [self.host rangeOfString:@"kss.ksyun.com"];
    if (range.length > 0) {
        [self.host replaceCharactersInRange:range withString:endPoint];
        
        NSLog(@"new host is %@",self.host);

    }else {
        NSLog(@"end point can be change only onece,zhis request will use old host");

    }
    
    
}
- (NSString *)vHostToVPath:(NSString *)vHost withBucketName:(NSString *)strBucketName
{
    NSString *vPath = @"";
    if ([vHost hasPrefix:@"http://"]) {
        NSArray *ipsArray = [[KS3Client initialize] ksyIps];
        if (ipsArray.count) {
            NSString *ipS = ipsArray[0];
            if (![ipS hasPrefix:@"http://"]) {
                ipS = [NSString stringWithFormat:@"http://%@",ipS];
            }
            NSMutableArray *paraMeterArray = [NSMutableArray arrayWithArray:[[vHost substringFromIndex:7] componentsSeparatedByString:@"/"]];
            if (paraMeterArray.count) {
                if (strBucketName != nil) {
                    [paraMeterArray replaceObjectAtIndex:0 withObject:strBucketName];
                }
                else {
                    [paraMeterArray removeObjectAtIndex:0]; // **** 某些API不带有bucket的名字
                }
                // **** bucket 名称可能含有“.”，按照“.”区分是错误的
//                NSArray *vHostArray = [paraMeterArray[0] componentsSeparatedByString:@"."];
//                if (vHostArray.count) {
//                    NSString *buckName = vHostArray[0];
//                    [paraMeterArray replaceObjectAtIndex:0 withObject:buckName];
//                }
            }
            NSString *components = [paraMeterArray componentsJoinedByString:@"/"];
            vPath = [NSString stringWithFormat:@"%@/%@",ipS,components];
            [self setHost:vPath];
            [self.urlRequest setValue:@"kss.ksyun.com" forHTTPHeaderField:@"host"];
        }else{
            return vHost;
        }
    }
    return vPath;
}
- (NSString *)URLEncodedString:(NSString *)str
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    
    int sourceLen = (int)strlen((const char *)source);
    
    for (int i = 0; i < sourceLen; ++i) {
        
        const unsigned char thisChar = source[i];
        
        if (thisChar == ' '){
            
            [output appendString:@"+"];
            
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   
                   (thisChar >= '0' && thisChar <= '9')) {
            
            [output appendFormat:@"%c", thisChar];
            
        } else {
            
            [output appendFormat:@"%%%02X", thisChar];
            
        }
        
    }
    
    return output;
    
}

@end
