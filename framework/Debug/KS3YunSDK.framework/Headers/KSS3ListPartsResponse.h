//
//  KSS3ListPartsResponse.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3Response.h"
#import "KSS3ListPartsResult.h"

@class KSS3ListPartsResult;
@interface KSS3ListPartsResponse : KSS3Response

@property (strong, nonatomic) KSS3ListPartsResult *listResult;
@end
