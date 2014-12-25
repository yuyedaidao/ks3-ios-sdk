//
//  KSS3HeadObjectRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Request.h"

@interface KS3HeadObjectRequest : KS3Request

@property (strong, nonatomic) NSString *key;
- (instancetype)initWithName:(NSString *)bucketName;
@end
