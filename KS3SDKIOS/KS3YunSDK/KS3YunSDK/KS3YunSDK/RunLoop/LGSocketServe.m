//
//  LGSocketServe.m
//  AsyncSocketDemo
//
//  Created by ligang on 15/4/3.
//  Copyright (c) 2015年 ligang. All rights reserved.
//

#import "LGSocketServe.h"


@implementation LGSocketServe


static LGSocketServe *socketServe = nil;

#pragma mark public static methods


+ (LGSocketServe *)sharedSocketServe {
    @synchronized(self) {
        if(socketServe == nil) {
            socketServe = [[[self class] alloc] init];
        }
    }
    return socketServe;
}


+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (socketServe == nil)
        {
            socketServe = [super allocWithZone:zone];
            return socketServe;
        }
    }
    return nil;
}


- (void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    if ( ![self SocketOpen:self.ipAddress port:80] )
    {
        
    }
    
}

- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:20 error:&error];
    }
    
    return 0;
}


-(void)cutOffSocket
{
    self.socket.userData = SocketOfflineByUser;
    [self.socket disconnect];
}


- (void)sendMessage:(id)message
{
    //像服务器发送数据
    NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:cmdData withTimeout:20 tag:1];
}





#pragma mark - Delegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    

    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:)]) {
        [self.delegate socketDidDisconnect:sock];
    }
}



- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    
    if ([self.delegate respondsToSelector:@selector(socket:willDisconnectWithError:)]) {
        [self.delegate socket:sock willDisconnectWithError:err];
    }
    
}



- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:sock didConnectToHost:host port:port];
    }
}



@end
