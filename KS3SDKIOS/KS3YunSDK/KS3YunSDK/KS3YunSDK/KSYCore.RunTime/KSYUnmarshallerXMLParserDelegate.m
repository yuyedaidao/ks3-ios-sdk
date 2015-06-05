//
//  KSYUnmarshallerXMLParserDelegate.m
//  KS3YunSDK
//
//  Created by JackWong on 15/6/2.
//  Copyright (c) 2015年 kingsoft. All rights reserved.
//

#import "KSYUnmarshallerXMLParserDelegate.h"

@implementation KSYUnmarshallerXMLParserDelegate
@synthesize currentTag;
@synthesize endElementTagName;
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
   attributes:(NSDictionary *)attributeDict
{
    // reset the current text
    if (currentText != nil) {
        currentText = nil;
    }
    
    self.currentTag = elementName;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (nil == currentText)
    {
        currentText = [[NSMutableString alloc] initWithCapacity:50];
    }
    
    [currentText appendString:string];
}
-(void) parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    // We don't do anything with this right now.
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // We don't do anything with this right now.
}

-(NSString *)currentText
{
    if (nil == currentText) {
        return @"";
    }
    
    return [NSString stringWithString:currentText];
}

//
// When parsing nested tags, control is handed to another delegate.
// When that delegate is done, it will
// - set the parser's delegate to the caller, returning control to it
// - assign the object it created to the parent field with [parent setter:object]
//
-(KSYUnmarshallerXMLParserDelegate *) initWithCaller:(KSYUnmarshallerXMLParserDelegate *)aCaller withParentObject:(id)parent withSetter:(SEL)setter
{
    caller            = aCaller;
    parentObject      = parent;
    parentSetter      = setter;
    endElementTagName = nil;
    return self;
}

-(KSYUnmarshallerXMLParserDelegate *) initWithCaller:(KSYUnmarshallerXMLParserDelegate *)aCaller withParentObject:(id)parent withSetter:(SEL)setter withAlias:(NSString *)alias
{
    caller            = aCaller;
    parentObject      = parent;
    parentSetter      = setter;
    endElementTagName = alias;
    return self;
}
@end
