//
//  KSS3ListObjectsXMLPrarser.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSS3ListObjectsResult;
@interface KSS3ListObjectsXMLPrarser : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic) KSS3ListObjectsResult *listBuctkResult;
- (void)kSS3XMLarse:(NSData *)dataXml;



@end
