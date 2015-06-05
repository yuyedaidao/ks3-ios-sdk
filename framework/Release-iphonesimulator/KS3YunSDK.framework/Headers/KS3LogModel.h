//
//  KS3LogModel.h
//  KS3YunSDK
//
//  Created by JackWong on 15/5/28.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KS3LogModel : NSObject

@property (strong, nonatomic) NSString *Log_source_ip;
@property (strong, nonatomic) NSString *Log_target_ip;
@property (strong, nonatomic) NSString *Log_model;
@property (strong, nonatomic) NSString *Log_manufacturer;
@property (strong, nonatomic) NSString *Log_build_version;
@property (strong, nonatomic) NSString *Log_device_id;
@property (strong, nonatomic) NSString *Log_network_type;
@property (strong, nonatomic) NSString *Log_first_data_time;
@property (strong, nonatomic) NSString *Log_response_time;
@property (assign, nonatomic) double Log_response_size;
@property (assign, nonatomic) NSInteger Log_client_state;
@property (strong, nonatomic) NSString *Log_mobile_network_type;
@property (assign, nonatomic) NSInteger ksyErrorcode;
@property (strong, nonatomic) NSString *send_before_time;
@property (strong, nonatomic) NSString *log_RequestId;
@end
