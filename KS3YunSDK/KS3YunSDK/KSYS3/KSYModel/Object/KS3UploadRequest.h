//
//  KS3UploadRequest.h
//  Pods
//
//  Created by Sun Peng on 2017/5/4.
//
//

#import "KS3InitiateMultipartUploadRequest.h"

@interface KS3UploadRequest : KS3InitiateMultipartUploadRequest

- (id)initWithKey:(NSString *)aKey
         inBucket:(NSString *)aBucket
              acl:(KS3AccessControlList *)acl
         grantAcl:(NSArray *)arrGrantAcl;

@end
