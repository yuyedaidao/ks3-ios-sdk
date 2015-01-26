//
//  AppDelegate.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#import "AppDelegate.h"
#import <KS3YunSDK/KS3YunSDK.h>

// **** 外网白名单测试
NSString *const strAccessKey = @"GENJ6O5PQFVE37MEEMZA";
NSString *const strSecretKey = @"9Z6VbeYUJ0BiKcuwYe5x/j76TZvYe9VRh2OdH15m";

// **** 用户的AK/SK
//NSString *const strAccessKey = @"IYh4GQWndtnQvmCJWFL4";
//NSString *const strSecretKey = @"1+RBTrWaeT6LaixUV5SGPFpeTa/wZEeZlGzYaZfr";

// **** 测试callback
//NSString *const strAccessKey = @"VSDNT6SHFNDWBXYZRS3A";
//NSString *const strSecretKey = @"OxJr4PEt9xg2d0+zYo+ckkMLVBwHLuebYnzS5Ev1";

// **** 测试token host
NSString *const strTokenHost = @"http://0.0.0.0:11911"; // **** token 的请求地址

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // **** use ak/sk
//     [[KS3Client initialize] connectWithAccessKey:strAccessKey withSecretKey:strSecretKey];
    
    // **** use token
//    [[KS3Client initialize] connectWithTokenHost:strTokenHost];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
