//
//  KSS3CompleteMultipartUploadRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3CompleteMultipartUploadRequest.h"
#import "KS3Constants.h"

@interface KS3CompleteMultipartUploadRequest ()
@property (strong, nonatomic) NSMutableDictionary *parts;
@end

@implementation KS3CompleteMultipartUploadRequest
-(id)initWithMultipartUpload:(KS3MultipartUpload *)multipartUpload
{
    if(self = [super init])
    {
        self.bucket   = multipartUpload.bucket;
        self.key      = multipartUpload.key;
        self.uploadId = multipartUpload.uploadId;
        self.contentMd5 = @"";
        self.contentType = @"text/xml";
        self.httpMethod = kHttpMethodPost;
        self.kSYResource =  [NSString stringWithFormat:@"/%@", self.bucket];
        self.kSYHeader = @"";
    }
    return self;
}
-(NSURLRequest *)configureURLRequest
{
    [self setKSYResource:[NSString stringWithFormat:@"%@/%@?%@=%@", self.kSYResource,_key, kKS3QueryParamUploadId, self.uploadId]];
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploadId=%@", self.bucket, self.key, self.uploadId];
    [super configureURLRequest];
    [self.urlRequest setHTTPMethod:kHttpMethodPost];
    [self.urlRequest setHTTPBody:[self requestBody]];
    [self.urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[self.urlRequest HTTPBody] length]] forHTTPHeaderField:kKSHttpHdrContentLength];
    [self.urlRequest setValue:@"text/xml" forHTTPHeaderField:kKSHttpHdrContentType];
    return self.urlRequest;
}
- (void)addPartWithPartNumber:(int)partNumber withETag:(NSString *)etag
{
    if (_parts == nil) {
        _parts = [NSMutableDictionary new];
    }
    [_parts setObject:etag forKey:[NSNumber numberWithInt:partNumber]];
}
-(NSData *)requestBody
{
    NSMutableString *xml = [NSMutableString stringWithFormat:@"<CompleteMultipartUpload>"];
    NSComparator   comparePartNumbers = ^ (id part1, id part2) {
        return [part1 compare:part2];
    };
    NSArray *keys = [[self.parts allKeys] sortedArrayUsingComparator:comparePartNumbers];
    for (NSNumber *partNumber in keys)
    {
        [xml appendFormat:@"<Part><PartNumber>%d</PartNumber><ETag>%@</ETag></Part>", [partNumber intValue], [self.parts objectForKey:partNumber]];
    }
    [xml appendString:@"</CompleteMultipartUpload>"];
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
}
@end
