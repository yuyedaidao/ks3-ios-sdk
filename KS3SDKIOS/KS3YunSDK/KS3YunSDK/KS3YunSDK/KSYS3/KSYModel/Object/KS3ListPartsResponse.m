//
//  KSS3ListPartsResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListPartsResponse.h"
#import "KS3ListPartsResultXMLParser.h"

@implementation KS3ListPartsResponse
-(void)processBody
{
    KS3ListPartsResultXMLParser *xmlParser = [[KS3ListPartsResultXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listResult = xmlParser.listPartsResult;
//    NSLog(@"KSS3InitiateMultipartUploadResponse %d",self.httpStatusCode);
////    NSLog(@"KSS3InitiateMultipartUploadResponse  %@",body);
//    NSLog(@" 0 0 0 0 0 %@",[self.error description]);

    
}
@end
