#import "BMYRequest.h"
#import "Json.h"
#import "BMYJsonParser.h"
#import "BMYJsonWriter.h"
#import "BMYLog.h"
#import "BMYError.h"
#import "BMYRequest.h"
#import "DBBase64Transcoder.h"

#define HTTP_RESPONSE_SUC_CODE 200
#define HTTP_CONTENT_NOT_MODIFIED_ERROR_CODE 304

static const char *kBase64RootCerts[];
static const size_t kNumRootCerts;
static const size_t kMaxCertLen = 10000;
static const NSMutableArray *volatile sRootCerts = NULL;

id<BMYNetworkRequestDelegate> bmyNetworkRequestDelegate = nil;

@interface BMYRequest ()

- (void)setError:(NSError *)error;

@property(nonatomic, strong) NSFileManager *fileManager;

@end

@implementation BMYRequest

+ (void)setNetworkRequestDelegate:(id<BMYNetworkRequestDelegate>)delegate {
    bmyNetworkRequestDelegate = delegate;
}

- (id)initWithURLRequest:(NSURLRequest *)aRequest andInformTarget:(id)aTarget selector:(SEL)aSelector {
    if (self = [super init]) {
        request = aRequest;
        target = aTarget;
        selector = aSelector;

        fileManager = [[NSFileManager alloc] init];
        urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [bmyNetworkRequestDelegate networkRequestStarted];
    }

    return self;
}

- (void)dealloc {
    [urlConnection cancel];
}

@synthesize failureSelector;
@synthesize fileManager;
@synthesize downloadProgressSelector;
@synthesize uploadProgressSelector;
@synthesize userInfo;
@synthesize sourcePath;
@synthesize request;
@synthesize response;
@synthesize xBanmayunMetadataJson;
@synthesize downloadProgress;
@synthesize uploadProgress;
@synthesize resultData;
@synthesize resultFilename;
@synthesize error;

- (NSString *)resultString {
    return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
}

- (NSObject *)resultJson {
    return [[self resultString] JsonValue];
}

- (NSInteger)statusCode {
    return [response statusCode];
}

- (long long)responseBodySize {
    // Use the content-length header, if available.
    long long contentLength = [[[response allHeaderFields] objectForKey:@"Content-Length"] longLongValue];

    if (contentLength > 0) {
        return contentLength;
    }

    // Fall back on the bytes field in the metadata x-header, if available.
    if (xBanmayunMetadataJson != nil) {
        id bytes = [xBanmayunMetadataJson objectForKey:@"bytes"];

        if (bytes != nil) {
            return [bytes longLongValue];
        }
    }

    return 0;
}

- (void)cancel {
    [urlConnection cancel];
    target = nil;

    if (tempFilename) {
        [fileHandle closeFile];
        NSError *rmError;

        if (![fileManager removeItemAtPath:tempFilename error:&rmError]) {
            BMYLogError(@"BMYRequest#cancel Error removing temp file: %@", rmError);
        }
    }

    [bmyNetworkRequestDelegate networkRequestStopped];
}

- (id)parseResponseAsType:(Class)cls {
    if (error) {
        return nil;
    }

    NSObject *res = [self resultJson];

    if (![res isKindOfClass:cls]) {
        [self setError:[NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:userInfo]];
        return nil;
    }

    return res;
}

#pragma mark -
#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    response = (NSHTTPURLResponse *)aResponse;

    // Parse the x-response-metadata as Json
    xBanmayunMetadataJson = [[[response allHeaderFields] objectForKey:@"X-Banmayun-Meta"] JsonValue];

    if (resultFilename && [self statusCode] == HTTP_RESPONSE_SUC_CODE) {
        // Create the file here so it's created in case it's zero length
        // File is downloaded into a temporary file and then moved over when completed successfully
        NSString *filename = [[NSProcessInfo processInfo] globallyUniqueString];
        tempFilename = [NSTemporaryDirectory() stringByAppendingString:filename];

        BOOL success = [fileManager createFileAtPath:tempFilename contents:nil attributes:nil];

        if (!success) {
            BMYLogError(@"BMYRequest#connection:didReceiveResponse: Error creating temp file: (%d) %s", errno,
                        strerror(errno));
        }

        fileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilename];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (resultFilename && [self statusCode] == HTTP_RESPONSE_SUC_CODE) {
        @try {
            [fileHandle writeData:data];
        }
        @catch (NSException *e) {
            // In case we run out of disk space
            [urlConnection cancel];
            [fileHandle closeFile];
            [fileManager removeItemAtPath:tempFilename error:nil];
            [self setError:[NSError errorWithDomain:BMYErrorDomain
                                               code:BMYErrorInsufficientDiskSpace
                                           userInfo:userInfo]];

            SEL sel = failureSelector ? failureSelector : selector;
            [target performSelector:sel withObject:self];
            [bmyNetworkRequestDelegate networkRequestStopped];
            return;
        }
        @finally {
        }
    } else {
        if (resultData == nil) {
            resultData = [NSMutableData new];
        }

        [resultData appendData:data];
    }

    bytesDownloaded += [data length];

    long long responseBodySize = [self responseBodySize];

    if (responseBodySize > 0) {
        downloadProgress = (CGFloat)bytesDownloaded / (CGFloat)responseBodySize;

        if (downloadProgressSelector) {
            [target performSelector:downloadProgressSelector withObject:self];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [fileHandle closeFile];
    fileHandle = nil;

    if (self.statusCode != HTTP_RESPONSE_SUC_CODE) {
        NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];

        // To get error userInfo, first try and make sense of the response as Json, if that fails
        // then send back the string as an error message
        NSString *resultString = [self resultString];

        if ([resultString length] > 0) {
            @try {
                BMYJsonParser *jsonParser = [BMYJsonParser new];
                NSObject *resultJson = [jsonParser objectWithString:resultString];

                if ([resultJson isKindOfClass:[NSDictionary class]]) {
                    [errorUserInfo addEntriesFromDictionary:(NSDictionary *)resultJson];
                }
            }
            @catch (NSException *e) {
                [errorUserInfo setObject:resultString forKey:@"errorMessage"];
            }
            @finally {
            }
        }

        [self setError:[NSError errorWithDomain:BMYErrorDomain code:self.statusCode userInfo:errorUserInfo]];
    } else if (tempFilename) {
        NSError *moveError;
        // Check that the file size is the same as the Content-Length
        NSDictionary *fileAttrs = [fileManager attributesOfItemAtPath:tempFilename error:&moveError];

        if (!fileAttrs) {
            BMYLogError(@"BMYRequest#connectionDidFinishLoading: error getting file attrs: %@", moveError);
            [fileManager removeItemAtPath:tempFilename error:nil];
            [self setError:[NSError errorWithDomain:moveError.domain code:moveError.code userInfo:self.userInfo]];
        } else if ([self responseBodySize] != 0 && [self responseBodySize] != [fileAttrs fileSize]) {
            // This happens in iOS 4.0 when the network connection changes while loading
            [fileManager removeItemAtPath:tempFilename error:nil];
            [self setError:[NSError errorWithDomain:BMYErrorDomain code:BMYErrorGenericError userInfo:self.userInfo]];
        } else {
            // Everything is OK, move temp file over to desired file
            [fileManager removeItemAtPath:resultFilename error:nil];

            BOOL success = [fileManager moveItemAtPath:tempFilename toPath:resultFilename error:&moveError];

            if (!success) {
                BMYLogError(@"BMYRequest#connectionDidFinishLoading: error moving temp file to desire location: %@",
                            [moveError localizedDescription]);
                [self setError:[NSError errorWithDomain:moveError.domain code:moveError.code userInfo:self.userInfo]];
            }
        }

        tempFilename = nil;
    }

    SEL sel = (error && failureSelector) ? failureSelector : selector;
    [target performSelector:sel withObject:self];

    [bmyNetworkRequestDelegate networkRequestStopped];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError {
    [fileHandle closeFile];
    [self setError:[NSError errorWithDomain:anError.domain code:anError.code userInfo:self.userInfo]];
    bytesDownloaded = 0;
    downloadProgress = 0;
    uploadProgress = 0;

    if (tempFilename) {
        NSError *removeError;
        BOOL success = [fileManager removeItemAtPath:tempFilename error:&removeError];

        if (!success) {
            BMYLogError(@"BMYRequest#connection:didFailWithError: error removing temporary file: %@",
                        [removeError localizedDescription]);
        }

        tempFilename = nil;
    }

    SEL sel = failureSelector ? failureSelector : selector;
    [target performSelector:sel withObject:self];

    [bmyNetworkRequestDelegate networkRequestStopped];
}

- (void)connection:(NSURLConnection *)connection
                  didSendBodyData:(NSInteger)bytesWritten
                totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    uploadProgress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;

    if (uploadProgressSelector) {
        [target performSelector:uploadProgressSelector withObject:self];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)req {
    if (!sourcePath) {
        BMYLogWarning(@"BanmayunSDK: need new body stream, but none available");
        return nil;
    }

    return [NSInputStream inputStreamWithFileAtPath:sourcePath];
}

#pragma mark -
#pragma mark - Private Method

- (void)setError:(NSError *)aError {
    if (aError == error) {
        return;
    }

    error = aError;

    NSString *errorStr = [error.userInfo objectForKey:@"error"];

    if (!errorStr) {
        errorStr = [error description];
    }

    if (!([error.domain isEqual:BMYErrorDomain] && error.code == HTTP_CONTENT_NOT_MODIFIED_ERROR_CODE)) {
        // Log errors unless they're 304's
        BMYLogError(@"BanmayunSDK: error making request to %@ - (%ld) %@", [[request URL] path], (long)error.code,
                    errorStr);
    }
}

//
// Called on SSL handshake
// Performs SSL certificate pinning
//

- (void)connection:(NSURLConnection *)connection
        willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSString *host = [[challenge protectionSpace] host];

    // Check the authentication method for connection: only SSL/TLS is allowed
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // Validate host's certificates against certificate authorities
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)[BMYRequest rootCertificates]);
        SecTrustResultType trustResult = kSecTrustResultInvalid;
        SecTrustEvaluate(serverTrust, &trustResult);

        if (trustResult == kSecTrustResultUnspecified) {
            // Certificate validation succeeded. Continue the connection
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                    forAuthenticationChallenge:challenge];
        } else {
            // Certificate validation failed. Terminate the connection
            BMYLogError(@"BanmayunSDK: SSL Error. Cannot validate a certificate for the host: %@", host);
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    } else {
        // Disallowed authentication method. Terminate the connection. Assuming an SSL failure is
        // the safest option here
        BMYLogError(@"BanmayunSDK: SSL error. Unknown authentication method %@ for Banmayun host: %@",
                    challenge.protectionSpace.authenticationMethod, host);
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

// Static method returning NSArray with root certificates

+ (NSArray *)rootCertificates {
    if (sRootCerts != NULL) {
        return sRootCerts;
    }

    @synchronized([BMYRequest class]) {
        if (sRootCerts == NULL) {
            NSMutableArray *certs = [NSMutableArray array];

            for (int i = 0; i < kNumRootCerts; i++) {
                size_t base64CertLen = strnlen(kBase64RootCerts[i], kMaxCertLen);
                size_t derCertLen = DBEstimateBas64DecodedDataSize(base64CertLen);
                char derCert[derCertLen];
                bool success = DBBase64DecodeData(kBase64RootCerts[i], base64CertLen, derCert, &derCertLen);

                if (!success) {
                    BMYLogError(@"Root certificate base64 decoding failed!");
                    continue;
                }

                CFDataRef rawCert = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)derCert, derCertLen);
                SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, rawCert);

                if (cert == NULL) {
                    BMYLogError(@"Invalid root certificate!");
                    CFRelease(rawCert);
                    continue;
                }

                CFRelease(rawCert);
                [certs addObject:(__bridge id)cert];
                CFRelease(cert);
            }

            sRootCerts = certs;
        }
    }
    return sRootCerts;
}

@end
