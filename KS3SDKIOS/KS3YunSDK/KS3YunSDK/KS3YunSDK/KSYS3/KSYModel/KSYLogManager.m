//
//  KSYLogManager.m
//  KS3YunSDK
//
//  Created by JackWong on 15/5/28.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import "KSYLogManager.h"
#import "KSYHardwareInfo.h"
#import "KS3LogModel.h"
#import "KSYMacroDefinition.h"
@implementation KSYLogManager

+ (void)setLocalLogInfo:(KS3LogModel *)logModel
{
    logModel.Log_source_ip = [KSYHardwareInfo getDeviceIPAddress];
    logModel.Log_target_ip = [KSYHardwareInfo getIPAddressByHostName:[NSURL URLWithString:@"http://kss.ksyun.com"]];
    logModel.Log_model = [KSYHardwareInfo systemDeviceTypeFormatted:YES];
    logModel.Log_manufacturer = [KSYHardwareInfo getManufacturer];
    logModel.Log_build_version = [KSYHardwareInfo getSystemVersion];
    logModel.Log_device_id = [KSYHardwareInfo getUniqueForDevice];
    logModel.Log_network_type = [KSYHardwareInfo checkNetworkType];
    logModel.Log_mobile_network_type = [KSYHardwareInfo getMobileNetworkInfo];
}

+ (void)senNSLogData:(KS3LogModel *)logModel
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://mlog.ksyun.com/"]];
    [urlRequest setValue:logModel.Log_source_ip forHTTPHeaderField:@"LogSourceIp"];
    [urlRequest setValue:logModel.Log_target_ip forHTTPHeaderField:@"LogTargetIp"];
    [urlRequest setValue:logModel.Log_model forHTTPHeaderField:@"LogModel"];
    [urlRequest setValue:logModel.Log_manufacturer forHTTPHeaderField:@"LogManufacturer"];
    [urlRequest setValue:logModel.Log_build_version forHTTPHeaderField:@"LogBuildVersion"];
    [urlRequest setValue:logModel.Log_device_id forHTTPHeaderField:@"LogDeviceId"];
    [urlRequest setValue:logModel.Log_network_type forHTTPHeaderField:@"LogNetworkType"];
    [urlRequest setValue:logModel.Log_first_data_time forHTTPHeaderField:@"LogFirstDataTime"];
    [urlRequest setValue:logModel.Log_response_time forHTTPHeaderField:@"LogResponseTime"];
    [urlRequest setValue:logModel.send_before_time forHTTPHeaderField:@"LogSendTime"];
    [urlRequest setValue:logModel.log_RequestId forHTTPHeaderField:@"LogRequestId"];
    [urlRequest setValue:[NSString stringWithFormat:@"%f",logModel.Log_response_size ]forHTTPHeaderField:@"LogResponseSize"];
    [urlRequest setValue:[NSString stringWithFormat:@"%ld",(long)logModel.Log_client_state] forHTTPHeaderField:@"LogClientState"];
    [urlRequest setValue:logModel.Log_mobile_network_type forHTTPHeaderField:@"LogMobileNetworkType"];
    [urlRequest setValue:[NSString stringWithFormat:@"%ld",(long)logModel.ksyErrorcode]forHTTPHeaderField:@"LogError"];
     NSLog(@"－－－－－%@",urlRequest.allHTTPHeaderFields);
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"Logmanager -----%ld",(long)responseCode);

        
    }];
    
    
}

@end
