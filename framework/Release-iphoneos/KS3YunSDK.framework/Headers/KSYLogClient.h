//
//  KSYLogClient.h
//  KS3YunSDK
//
//  Created by Blues on 15/7/20.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KS3LogModel.h"

#define LogClientLog(log)	    if ([self.delegate respondsToSelector:@selector(logCilentLog:)]) {\
[self.delegate logCilentLog:log];\
}


@protocol KSYLogClientDelegate <NSObject>

- (void)logCilentLog:(NSString *)log;

@end

@interface KSYLogClient : NSObject

@property (nonatomic, weak)id<KSYLogClientDelegate> delegate;
@property (nonatomic, copy)NSString *outsideIP;
- (void)insertLog:(KS3LogModel *)logInfo;
- (void)sendData;

@end
