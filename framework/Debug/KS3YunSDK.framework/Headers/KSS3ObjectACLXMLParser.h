//
//  KSS3ObjectACLXMLParser.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSS3BucketACLResult.h"
@interface KSS3ObjectACLXMLParser : NSObject<NSXMLParserDelegate>
@property (strong, nonatomic) KSS3BucketACLResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;

@end
