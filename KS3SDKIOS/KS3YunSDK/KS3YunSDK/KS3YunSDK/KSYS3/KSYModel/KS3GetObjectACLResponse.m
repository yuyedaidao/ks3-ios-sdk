//
//  KSS3GetObjectACLResponse.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3GetObjectACLResponse.h"
#import "KS3ObjectACLXMLParser.h"
#import "KS3BucketACLResult.h"
@implementation KS3GetObjectACLResponse

-(void)processBody
{
    KS3ObjectACLXMLParser *xmlParser = [[KS3ObjectACLXMLParser alloc] init];
    [xmlParser kSS3XMLarse:body];
    _listBucketsResult = xmlParser.listBuctkResult;
//    NSLog(@"KSS3GetObjectACLResponse %d",self.httpStatusCode);
//    NSLog(@"KSS3GetObjectACLResponse  %@",body);
//    NSLog(@" 0 0 0 0 0 %@",[self.error description]);
//    
//    NSLog(@"KSS3GetObjectACLResponse  %@",_listBucketsResult.owner.ID);
//    NSLog(@"KSS3GetObjectACLResponse  %@",_listBucketsResult.owner.displayName);
//    
//    for (KSS3Grant *grant in _listBucketsResult.accessControlList) {
//        NSLog(@"%@",grant.grantee.ID);
//        NSLog(@"%@",grant.grantee.displayName);
//        NSLog(@"%@",grant.grantee.URI);
//        NSLog(@"_______________________");
//        NSLog(@"%@",grant.permission);
//    }

    
}
@end
