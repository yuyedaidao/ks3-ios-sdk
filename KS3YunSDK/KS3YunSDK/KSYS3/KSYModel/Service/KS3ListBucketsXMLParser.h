//
//  KSS3ListBucketsXMLParser.h
//  KS3SDK
//
//  Created by JackWong on 12/11/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListBucketsResult.h"
#import "KS3Owner.h"
#import <Foundation/Foundation.h>

@interface KS3ListBucketsXMLParser : NSObject <NSXMLParserDelegate>
@property(strong, nonatomic) KS3ListBucketsResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;
@end
