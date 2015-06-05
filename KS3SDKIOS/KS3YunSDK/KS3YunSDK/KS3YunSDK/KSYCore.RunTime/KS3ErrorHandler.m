//
//  KS3ErrorHandler.m
//  KS3YunSDK
//
//  Created by JackWong on 12/23/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

// Public Constants
#import "KS3ErrorHandler.h"
#import "KS3ClientException.h"
#import "KS3ExceptionConstants.h"
#import "KSYMacroDefinition.h"
NSString *const KS3iOSSDKServiceErrorDomain = @"com.ks3yun.iossdk.ServiceErrorDomain";
NSString *const KS3iOSSDKClientErrorDomain = @"com.ks3yun.iossdk.ClientErrorDomain";
static BOOL throwsExceptions = NO;

@interface KS3ErrorHandler ()
@property (nonatomic, assign) int32_t httpStatusCode;
//@property (nonatomic, strong) KS3ClientException *exception;
@end

@implementation KS3ErrorHandler

-(id)initWithStatusCode:(int32_t)statusCode
{
    if (self = [super init])
    {
        _httpStatusCode = statusCode;
        _exception = [[KS3ClientException alloc] initWithMessage:@"KS3Exception"];
        _exception.statusCode = _httpStatusCode;
    }
    return self;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    NSLog(@"elementName ----%@",elementName);
    if ([elementName isEqualToString:@"Message"]) {
        _exception.message = self.currentText;
        return;
    }
    
    if ([elementName isEqualToString:@"Code"]) {
        _exception.errorCode = self.currentText;
        return;
    }
    
    if ([elementName isEqualToString:@"RequestId"]) {
        _exception.requestId = self.currentText;
        return;
    }
}

- (void)convertKS3Error{
    switch (_httpStatusCode) {
        case 403:{
            if ([_exception.errorCode containsString:@"AccessDenied"]) {
                _exception.statusCode = ERROR_CODE_ACCESS_DENIED;
                _exception.message = ERROR_CODE_ACCESS_DENIED_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidAccessKey"]){
                _exception.statusCode = ERROR_CODE_INVALID_ACCESS_KEY;
                _exception.message = ERROR_CODE_INVALID_ACCESS_KEY_MESSAGE;
            }else if ([_exception.errorCode containsString:@"RequestTimeTooSkewed"]){
                _exception.statusCode = ERROR_CODE_REQUEST_TIME_TOO_SKEWED;
                _exception.message = ERROR_CODE_REQUEST_TIME_TOO_SKEWED_MESSAGE;
            }else if ([_exception.errorCode containsString:@"SignatureDoesNotMatch"]){
                _exception.statusCode = ERROR_CODE_SIGNATURE_DOES_NOT_MATCH;
                _exception.message = ERROR_CODE_SIGNATURE_DOES_NOT_MATCH_MESSAGE;
            }else if ([_exception.errorCode containsString:@"URLExpired"]){
                _exception.statusCode = ERROR_CODE_URL_EXPIRED;
                _exception.message = ERROR_CODE_URL_EXPIRED_MESSAGE;
            }
            
        }
            break;
        case 400: {
            if ([_exception.errorCode containsString:@"BadDigest"]) {
                _exception.statusCode = ERROR_CODE_BAD_DIGEST;
                _exception.message = ERROR_CODE_BAD_DIGEST_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidACLString"]) {
                _exception.statusCode = ERROR_CODE_INVALID_ACL_STR;
                _exception.message = ERROR_CODE_INVALID_ACL_STR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidAuthorizationString"]) {
                _exception.statusCode = ERROR_CODE_INVALID_AUTHORIZATION_STR;
                _exception.message = ERROR_CODE_INVALID_AUTHORIZATION_STR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidBucketName"]) {
                _exception.statusCode = ERROR_CODE_INVALID_BUCKET_NAME;
                _exception.message = ERROR_CODE_INVALID_BUCKET_NAME_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidDateFormat"]) {
                _exception.statusCode = ERROR_CODE_INVALID_DATE_FORMAT;
                _exception.message = ERROR_CODE_INVALID_DATE_FORMAT_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidDigest"]) {
                _exception.statusCode = ERROR_CODE_INVALID_DIGEST;
                _exception.message = ERROR_CODE_INVALID_DIGEST_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidEncryptionAlgorithm"]) {
                _exception.statusCode = ERROR_CODE_INVALID_ENCYPTION_ALGORITHM;
                _exception.message = ERROR_CODE_INVALID_ENCYPTION_ALGORITHM_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidHostHeader"]) {
                _exception.statusCode = ERROR_CODE_INVALID_HOST_HEADER;
                _exception.message = ERROR_CODE_INVALID_HOST_HEADER_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidParameter"]) {
                _exception.statusCode = ERROR_CODE_INVALID_PARAMETER;
                _exception.message = ERROR_CODE_INVALID_PARAMETER_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidPath"]) {
                _exception.statusCode = ERROR_CODE_INVALID_PATH;
                _exception.message = ERROR_CODE_INVALID_PATH_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidQueryString"]) {
                _exception.statusCode = ERROR_CODE_INVALID_QUERY_STR;
                _exception.message = ERROR_CODE_INVALID_QUERY_STR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"InvalidRange"]) {
                _exception.statusCode = ERROR_CODE_INVALID_RANGE;
                _exception.message = ERROR_CODE_INVALID_RANGE_MESSAGE;
            }else if ([_exception.errorCode containsString:@"KeyTooLong"]) {
                _exception.statusCode = ERROR_CODE_KEY_TOO_LONG;
                _exception.message = ERROR_CODE_KEY_TOO_LONG_MESSAGE;
            }else if ([_exception.errorCode containsString:@"MetadataTooLarge"]) {
                _exception.statusCode = ERROR_CODE_META_DATA_TOO_LARGE;
                _exception.message = ERROR_CODE_META_DATA_TOO_LARGE_MESSAGE;
            }else if ([_exception.errorCode containsString:@"MissingDateHeader"]){
                _exception.statusCode = ERROR_CODE_MISSING_DATA_HEADER;
                _exception.message = ERROR_CODE_MISSING_DATA_HEADER_MESSAGE;
            }else if ([_exception.errorCode containsString:@"MissingHostHeader"]){
                _exception.statusCode = ERROR_CODE_MISSING_HOST_HEADER;
                _exception.message = ERROR_CODE_MISSING_HOST_HEADER_MESSAGE;
            }else if ([_exception.errorCode containsString:@"TooManyBuckets"]){
                _exception.statusCode = ERROR_CODE_TOO_MANY_BUCKETS;
                _exception.message = ERROR_CODE_TOO_MANY_BUCKETS_MESSAGE;
            }else if ([_exception.errorCode containsString:@"BadParams"]){
                _exception.statusCode = ERROR_CODE_BAD_PARAMS;
                _exception.message = ERROR_CODE_BAD_PARAMS_MESSAGE;
            }else if ([_exception.errorCode containsString:@"ImageTypeNotSupport"]){
                _exception.statusCode = ERROR_CODE_IMAGE_TYPE_NOT_SUPPORT;
                _exception.message = ERROR_CODE_IMAGE_TYPE_NOT_SUPPORT_MESSAGE;
            }else if ([_exception.errorCode containsString:@"MissingFormArgs"]){
                _exception.statusCode = ERROR_CODE_MISSING_FROM_ARGS;
                _exception.message = ERROR_CODE_MISSING_FROM_ARGS_MESSAGE;
            }else if ([_exception.errorCode containsString:@"ContentRangeError"]){
                _exception.statusCode = ERROR_CODE_CONTENT_RANGE_ERROR;
                _exception.message = ERROR_CODE_CONTENT_RANGE_ERROR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"ContentLengthOutOfRange"]){
                _exception.statusCode = ERROR_CODE_CONTENT_LENGTH_OUT_OF_RANGE;
                _exception.message = ERROR_CODE_CONTENT_LENGTH_OUT_OF_RANGE_MESSAGE;
            }else if ([_exception.errorCode containsString:@"PolicyError"]){
                _exception.statusCode = ERROR_CODE_POLICY_ERROR;
                _exception.message = ERROR_CODE_POLICY_ERROR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"ExpirationError"]){
                _exception.statusCode = ERROR_CODE_EXPIRATION_ERROR;
                _exception.message = ERROR_CODE_EXPIRATION_ERROR_MESSAGE;
            }else if ([_exception.errorCode containsString:@"FormUnmatchPolicy"]){
                _exception.statusCode = ERROR_CODE_FORM_UNMATCH_POLICY;
                _exception.message = ERROR_CODE_FORM_UNMATCH_POLICY_MESSAGE;
            }
            
            
            
        }
            break;
        case 409: {
            if ([_exception.errorCode containsString:@"BucketAlreadyExists"]) {
                _exception.statusCode = ERROR_CODE_BUCKET_ALREADY_EXISTS;
                _exception.message = ERROR_CODE_BUCKET_ALREADY_EXISTS_MESSAGE;
            }else if ([_exception.errorCode containsString:@"BucketAlreadyOwnedByYou"]){
                _exception.statusCode = ERROR_CODE_BUCKET_ALREADY_OWNED_BY_YOU;
                _exception.message = ERROR_CODE_BUCKET_ALREADY_OWNED_BY_YOU_MESSAGE;
            }else if ([_exception.errorCode containsString:@"BucketNotEmpty"]){
                _exception.statusCode = ERROR_CODE_BUCKET_NOT_EMPTY;
                _exception.message = ERROR_CODE_BUCKET_NOT_EMPTY_MESSAGE;
            }
        }
            break;
        case 500: {
            if ([_exception.errorCode containsString:@"InternalError"]) {
                _exception.statusCode = ERROR_CODE_INTERNAL_ERROR;
                _exception.message = ERROR_CODE_INTERNAL_ERROR_MESSAGE;
            }
        }
            break;
        case 416: {
            if ([_exception.errorCode containsString:@"InvalidRange"]) {
                _exception.statusCode = ERROR_CODE_INVALID_RANGE;
                _exception.message = ERROR_CODE_INVALID_RANGE_MESSAGE;
            }
        }
            break;
        case 405: {
            if ([_exception.errorCode containsString:@"MethodNotAllowed"]) {
                _exception.statusCode = ERROR_CODE_METHOD_NOT_ALLOWED;
                _exception.message = ERROR_CODE_METHOD_NOT_ALLOWED_MESSAGE;
            }
        }
            break;
        case 404: {
            if ([_exception.errorCode containsString:@"NoSuchBucket"]) {
                _exception.statusCode = ERROR_CODE_NO_SUCH_BUCKET;
                _exception.message = ERROR_CODE_NO_SUCH_BUCKET_MESSAGE;
            }else if ([_exception.errorCode containsString:@"NoSuchKey"]){
                _exception.statusCode = ERROR_CODE_NO_SUCH_KEY;
                _exception.message = ERROR_CODE_NO_SUCH_KEY_MESSAGE;
            }
        }
            break;
        case 501: {
            if ([_exception.errorCode containsString:@"NotImplemented"]) {
                _exception.statusCode = ERROR_CODE_NOT_IMPLEMENTED;
                _exception.message = ERROR_CODE_NOT_IMPLEMENTED_MESSAGE;
            }
        }
            break;
        default:
            break;
    }
    
}

+ (void)shouldThrowExceptions
{
    throwsExceptions = YES;
}

+ (void)shouldNotThrowExceptions
{
    throwsExceptions = NO;
}

+ (BOOL)throwsExceptions
{
    return throwsExceptions;
}

+ (NSError *)errorFromExceptionWithThrowsExceptionOption:(NSException *)exception
{
    if(exception == nil)
    {
        return nil;
    }
    else if(throwsExceptions == YES)
    {
        @throw exception;
    }
    else if(![exception isKindOfClass:[KS3ClientException class]])
    {
        // Fatal error. This should not happen.
        @throw exception;
    }
    
    return [KS3ErrorHandler errorFromException:exception];
}

+ (NSError *)errorFromException:(NSException *)exception serviceErrorDomain:(NSString *)serviceErrorDomain clientErrorDomain:(NSString *)clientErrorDomain
{
    NSError *error = nil;
    
    if([exception isKindOfClass:[KS3ClientException class]])
    {
        KS3ClientException *clientException = (KS3ClientException *)exception;
        
        if(clientException.error != nil)
        {
            error = clientException.error;
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      clientException.message, @"message",
                                      clientException, @"exception", nil];
            
            error = [NSError errorWithDomain:clientErrorDomain code:-1 userInfo:userInfo];
        }
    }
    
    // Return nil for non Amazon exceptions.
    return error;
}

+ (NSError *)errorFromException:(NSException *)exception
{
    return [KS3ErrorHandler errorFromException:exception
                            serviceErrorDomain:KS3iOSSDKServiceErrorDomain
                             clientErrorDomain:KS3iOSSDKClientErrorDomain];
}


@end
