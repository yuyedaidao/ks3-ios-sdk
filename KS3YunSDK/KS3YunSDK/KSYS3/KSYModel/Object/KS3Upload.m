//
//  KS3Upload.m
//  Pods
//
//  Created by Sun Peng on 2017/5/4.
//
//

#import "KS3Upload.h"

@implementation KS3Upload

- (id)copyWithZone:(NSZone *)zone {
    KS3Upload *copy = [[[self class] allocWithZone:zone] init];
    copy.key = self.key;
    copy.bucket = self.bucket;
    copy.uploadId = self.uploadId;
    copy.storageClass = self.storageClass;
    copy.initiator = self.initiator;
    copy.initiated = self.initiated;
    copy.contentLength = self.contentLength;
    copy.blockSize = self.blockSize;
    copy.partCount = self.partCount;
    return copy;
}

@end
