//
//  KS3Upload.h
//  Pods
//
//  Created by Sun Peng on 2017/5/4.
//
//

#import <Foundation/Foundation.h>
#import "KS3MultipartUpload.h"

@interface KS3Upload : KS3MultipartUpload <NSCopying>

@property (assign, nonatomic) NSInteger contentLength;
@property (assign, nonatomic) NSInteger blockSize;
@property (assign, nonatomic) NSInteger partCount;

@end
