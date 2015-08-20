//
//  KSYLogClient.h
//  KS3YunSDK
//
//  Created by Blues on 15/7/20.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3LogModel.h"

@interface KSYLogClient : NSObject

- (void)insertLog:(KS3LogModel *)logInfo;
- (void)sendData;

@end
