//
//  KSYLog.h
//  KS3YunSDK
//
//  Created by Blues on 15/7/20.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KSYLog : NSManagedObject

@property (nonatomic, retain) NSString * source_ip;
@property (nonatomic, retain) NSString * target_ip;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * build_version;
@property (nonatomic, retain) NSString * device_id;
@property (nonatomic, retain) NSString * network_type;
@property (nonatomic, retain) NSString * first_data_time;
@property (nonatomic, retain) NSString * response_time;
@property (nonatomic, retain) NSNumber * response_size;
@property (nonatomic, retain) NSNumber * client_state;
@property (nonatomic, retain) NSString * mobile_network_type;
@property (nonatomic, retain) NSNumber * ksy_error_code;
@property (nonatomic, retain) NSString * send_before_time;
@property (nonatomic, retain) NSString * request_id;

@end
