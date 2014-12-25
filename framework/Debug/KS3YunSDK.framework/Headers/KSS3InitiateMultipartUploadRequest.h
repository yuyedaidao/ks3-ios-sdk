//
//  KSS3InitiateMultipartUploadRequest.h
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KSS3AbstractPutRequest.h"

@interface KSS3InitiateMultipartUploadRequest : KSS3AbstractPutRequest

-(id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket;

@property (nonatomic, strong) NSString *key;
/** Can be used to specify caching behavior along the request/reply chain.
 * For more information, go to http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9.
 */
@property (nonatomic, strong) NSString *cacheControl;

/** Specifies presentational information for the object.
 * For more information, go to http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1.
 */
@property (nonatomic, strong) NSString *contentDisposition;

/** Specifies what content encodings have been applied to the object and thus what
 * decoding mechanisms must be applied to obtain the media-type referenced by the
 * <code>Content-Type</code> header field.
 * For more information, go to http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.11.
 */
@property (nonatomic, strong) NSString *contentEncoding;

@property (nonatomic, strong) NSString *redirectLocation;

/** Number of milliseconds before expiration. */
@property (nonatomic, readonly) int32_t expires;

@end
