//
//  KingSoftURLRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/9/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KingSoftCredentials.h"

@interface KingSoftURLRequest : NSMutableURLRequest
@property (weak, nonatomic) KingSoftCredentials *credentials;
@end
