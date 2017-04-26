//
//  KingSoftURLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3Credentials.h"
#import <Foundation/Foundation.h>

@interface KS3URLRequest : NSMutableURLRequest
@property(weak, nonatomic) KS3Credentials *credentials;
@end
