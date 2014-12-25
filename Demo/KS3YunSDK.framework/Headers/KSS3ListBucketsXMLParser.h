//
//  KSS3ListBucketsXMLParser.h
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSS3Owner.h"
#import "KSS3ListBucketsResult.h"

@interface KSS3ListBucketsXMLParser : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic) KSS3ListBucketsResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;
@end
