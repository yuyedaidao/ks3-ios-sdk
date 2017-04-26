//
//  KSS3InitiateMultipartUploadXMLParser.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3InitiateMultipartUploadResult.h"
#import <Foundation/Foundation.h>

@interface KS3InitiateMultipartUploadXMLParser : NSObject <NSXMLParserDelegate>
@property(strong, nonatomic) KS3InitiateMultipartUploadResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;

@end
