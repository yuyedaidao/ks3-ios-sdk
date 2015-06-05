//
//  KSYMacroDefinition.h
//  KS3YunSDK
//
//  Created by JackWong on 15/6/5.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#ifndef KS3YunSDK_KSYMacroDefinition_h
#define KS3YunSDK_KSYMacroDefinition_h

#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

#endif
