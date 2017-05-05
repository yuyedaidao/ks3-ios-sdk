//
//  KS3UploadRequest.m
//  Pods
//
//  Created by Sun Peng on 2017/5/4.
//
//

#import "KS3UploadRequest.h"

@implementation KS3UploadRequest

- (id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket acl:(KS3AccessControlList *)acl grantAcl:(NSArray *)arrGrantAcl {
    if (self = [super initWithKey:aKey inBucket:aBucket acl:acl grantAcl:arrGrantAcl]) {
    }

    return self;
}

@end
