#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BMYNetworkRequestDelegate;

@interface BMYRequest : NSObject {
    NSURLRequest *request;
    id target;
    SEL selector;
    NSURLConnection *urlConnection;
    NSFileHandle *fileHandle;
    NSFileManager *fileManager;

    SEL failureSelector;
    SEL downloadProgressSelector;
    SEL uploadProgressSelector;

    NSString *resultFilename;
    NSString *tempFilename;
    NSDictionary *userInfo;
    NSString *sourcePath;

    NSHTTPURLResponse *response;
    NSDictionary *xBanmayunMetadataJson;
    long bytesDownloaded;
    CGFloat downloadProgress;
    CGFloat uploadProgress;
    NSMutableData *resultData;
    NSError *error;
}

/*
   Set this to get called when _any_request starts or stops. This should hook into whatever network
   activity indicator system you have
 */
+ (void)setNetworkRequestDelegate:(id<BMYNetworkRequestDelegate>)delegate;

/*
   This constructor downloads the URL into the resultData object
 */
- (id)initWithURLRequest:(NSURLRequest *)request andInformTarget:(id)target selector:(SEL)selector;

/*
   Cancels the request and prevents it from sending additional messages to the delegate.
 */
- (void)cancel;

/*
   If there is no error, it will parse the response as Json and make sure the Json object is the correct
   type. If not, it will set the error object with an error code of BMYErrorInvalidResponse
 */
- (id)parseResponseAsType:(Class)cls;

@property(nonatomic, assign) SEL failureSelector;  // To send failure events to a different selector set this

@property(nonatomic, assign) SEL downloadProgressSelector;  // To receive download progress events set this

@property(nonatomic, assign) SEL uploadProgressSelector;  // To receive upload progress events set this

@property(nonatomic, strong)
        NSString *resultFilename;  // The file to put the HTTP body in, otherwise body is stored in resultData

@property(nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic, strong) NSString *sourcePath;  // Used by methods that upload to refresh the input stream

@property(nonatomic, readonly) NSURLRequest *request;
@property(nonatomic, readonly) NSHTTPURLResponse *response;
@property(nonatomic, readonly) NSDictionary *xBanmayunMetadataJson;
@property(nonatomic, readonly) NSInteger statusCode;
@property(nonatomic, readonly) CGFloat downloadProgress;
@property(nonatomic, readonly) CGFloat uploadProgress;
@property(nonatomic, readonly) NSData *resultData;
@property(nonatomic, readonly) NSString *resultString;
@property(nonatomic, readonly) NSObject *resultJson;
@property(nonatomic, readonly) NSError *error;

@end

@protocol BMYNetworkRequestDelegate

- (void)networkRequestStarted;
- (void)networkRequestStopped;

@end
