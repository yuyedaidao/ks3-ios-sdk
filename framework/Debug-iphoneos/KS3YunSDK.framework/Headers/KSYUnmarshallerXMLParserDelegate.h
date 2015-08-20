//
//  KSYUnmarshallerXMLParserDelegate.h
//  KS3YunSDK
//
//  Created by JackWong on 15/6/2.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYUnmarshallerXMLParserDelegate : NSObject<NSXMLParserDelegate> {
    NSMutableString                     *currentText;
    NSString                            *currentTag;
    KSYUnmarshallerXMLParserDelegate *caller;
    id                                  parentObject;
    SEL                                 parentSetter;
    NSString                            *endElementTagName;
}
@property (nonatomic, readonly) NSString *currentText;

@property (nonatomic, strong) NSString   *currentTag;

@property (nonatomic, strong) NSString *endElementTagName;

- (KSYUnmarshallerXMLParserDelegate *) initWithCaller:(KSYUnmarshallerXMLParserDelegate *)aCaller withParentObject:(id)parent withSetter:(SEL)setter;


- (KSYUnmarshallerXMLParserDelegate *) initWithCaller:(KSYUnmarshallerXMLParserDelegate *)aCaller withParentObject:(id)parent withSetter:(SEL)setter withAlias:(NSString *)alias;


@end
