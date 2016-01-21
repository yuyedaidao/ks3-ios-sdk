//
//  KSYLogManager.h
//  KS3YunSDK
//
//  Created by JackWong on 15/5/28.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3ServiceRequest.h"

@interface KSYLogManager : NSObject
+ (void)setLocalLogInfo:(KS3LogModel *)logmodel;
+ (void)senNSLogData:(KS3LogModel *)logModel;
@end
