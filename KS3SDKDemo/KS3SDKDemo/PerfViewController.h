//
//  PerfViewController.h
//  KS3SDKDemo
//
//  Created by Sun Peng on 2017/6/29.
//  Copyright © 2017年 Kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerfViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *uploadTimes;
@property (weak, nonatomic) IBOutlet UIProgressView *totalProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *currentProgress;
@property (weak, nonatomic) IBOutlet UITextView *result;
@property (weak, nonatomic) IBOutlet UIButton *startUploadButton;

@end
