//
//  KSYHardwareInfo.h
//  KS3YunSDK
//
//  Created by JackWong on 15/5/28.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYHardwareInfo : NSObject

// Model of Device
+ (NSString *)deviceModel;

// Device Name
+ (NSString *)deviceName;

// System Name
+ (NSString *)systemName ;

// System Version
+ (NSString *)systemVersion;

+ (NSString *)systemDeviceTypeFormatted:(BOOL)formatted;

+ (NSString *)getDeviceIPAddress;

+ (NSString*)getIPAddressByHostName:(NSURL*)url;

+ (NSString *)getSystemVersion;

+ (NSString *)getManufacturer;

+ (NSString *)getUniqueForDevice;

+ (NSString *)getMobileNetworkInfo;

+ (NSString*)checkNetworkType;

+ (NSString *)getCurrentTime;

@end
