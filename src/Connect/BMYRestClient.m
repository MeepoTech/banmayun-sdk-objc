//
//  BMYRestClient.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-4.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYRestClient.h"
#import "BMYLog.h"
#import "BMYError.h"
#import "BMYRequest.h"
#import "BMYMetadata.h"
#import "BMYLink.h"
#import "BMYUser.h"
#import "BMYResultList.h"
#import "BMYGroup.h"
#import "BMYRoot.h"
#import "BMYComment.h"
#import "BMYShare.h"
#import "BMYTrash.h"
#import "BMYUserRole.h"
#import "BMYRelationRole.h"
#import "BMYGroupType.h"
#import "BMYRevision.h"
#import "BMYURLRequestParameter.h"
#import "NSString+URLEscapingAdditions.h"
#import "NSObject+BMYJSON.h"



//NSString *kBMYBanMaYunAPIHost = @"api.banmayun.com";
NSString *kBMYBanMaYunAPIHost = @ "192.168.200.195:5000";  // For test
//NSString *kBMYProtocolHTTPS = @"https";
NSString *kBMYProtocolHTTPS = @"http";      // For test

NSString *kBMYBanMaYunAPIVersion = @"1";


NSInteger kBMYBanMaYunUploadChunkSize = 1024 * 1024;

#define BANMAYUN_ACCESS_TOKEN_KEY @"token"
#define BANMAYUN_USER_ID_KEY @"user_id"
#define BANMAYUN_GROUP_ID_KEY @"group_id"
#define BANMAYUN_LINK_ID_KEY @"link_id"
#define BANMAYUN_ROOT_ID_KEY @"root_id"
#define BANMAYUN_META_ID_KEY @"meta_id"
#define BANMAYUN_SHARE_ID_KEY @"share_id"
#define BANMAYUN_COMMENT_ID_KEY @"comment_id"
#define BANMAYUN_TRASH_ID_KEY @"trash_id"
#define BANMAYUN_FILE_PATH_KEY @"path"
#define BANMAYUN_FILE_VERSION_KEY @"version"
#define BANMAYUN_FILE_OFFSET_KEY @"offset"
#define BANMAYUN_FILE_LOADSIZE_KEY @"bytes"
#define BANMAYUN_FILE_DESTINATION_PATH_KEY @"destinationPath"
#define BANMAYUN_FILE_THUMBNAIL_FORMAT_KEY @"format"
#define BANMAYUN_FILE_THUMBNAIL_SIZE_KEY @"size"
#define BANMAYUN_FILE_META_ID_KEY @"meta_id"
#define BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY @"sourcePath"
#define BANMAYUN_FILE_UPLOAD_CLIENTMTIME_KEY @"client_mtime"
#define BANMAYUN_FILE_UPLOAD_OVERWRITE_KEY @"overwrite"
#define BANMAYUN_FILE_CHUNKUPLOAD_OFFSET_KEY @"offset"
#define BANMAYUN_FILE_CHUNKUPLOAD_UPLOADID_KEY @"upload_id"


@interface BMYRestClient ()

// This method escape all URI eacape characters except /
+ (NSString *)escapeStr:(NSString *)str;

+ (NSString *)bestLanguage;


- (NSMutableURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path parameter:(NSDictionary *)params;
- (NSMutableURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path parameter:(NSDictionary *)params method:(NSString *)method;

- (NSString *)accessToken;

- (void)checkForAuthenticationFailure:(BMYRequest *)request;

@end



@implementation BMYRestClient

- (id)initWithSession:(BMYSession *)session
{
    if (self = [super init]) {
        requests = [[NSMutableSet alloc] init];
        imageLoadRequests = [[NSMutableDictionary alloc] init];
        loadRequests = [[NSMutableDictionary alloc] init];
        uploadRequests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)checkForAuthenticationFailure:(BMYRequest *)request
{
    NSLog(@"Check For Authentication Failure Called!");
}

- (NSString *)accessToken
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    if (!token) {
        return @"";
    }else{
        return token;
    }
}

- (void)cancelAllRequests
{
    for (BMYRequest *request in requests) {
        [request cancel];
    }
    [requests removeAllObjects];
    
    for (BMYRequest *request in [loadRequests allValues]) {
        [request cancel];
    }
    [loadRequests removeAllObjects];
    
    for (BMYRequest *request in [imageLoadRequests allValues]) {
        [request cancel];
    }
    [imageLoadRequests removeAllObjects];
    
    for (BMYRequest *request in [uploadRequests allValues]) {
        [request cancel];
    }
    [uploadRequests removeAllObjects];
}

- (void)dealloc
{
    [self cancelAllRequests];
}

@synthesize delegate;




#pragma mark -
#pragma mark - Sign In

- (void)signInWithParams:(NSDictionary *)params
{
    NSString *fullPath = [NSString stringWithFormat:@"/auth/sign_in"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSignIn:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)signInWithUsername:(NSString *)username passwd:(NSString *)password linkName:(NSString *)linkname linkDevice:(NSString *)linkDevice ldapName:(NSString *)ldapname
{
    if (!username || !password) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (username) {
        [params setObject:username forKey:@"username"];
    }
    if (password) {
        [params setObject:password forKey:@"password"];
    }
    if (linkname) {
        [params setObject:linkname forKey:@"link_name"];
    }
    if (linkDevice) {
        [params setObject:linkDevice forKey:@"link_device"];
    }
    if (ldapname) {
        [params setObject:ldapname forKey:@"ldap_name"];
    }
    [self signInWithParams:params];
}


- (void)requestDidSignIn:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:signInFailedWithError:)]) {
            [delegate restClient:self signInFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSignInLinkWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *curThread = [NSThread currentThread];
        [inv setArgument:&curThread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseSignInLinkWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYLink *link = [[BMYLink alloc] initWithDictionary:result];
    if (link) {
        [self performSelector:@selector(didParseSignInLink:) onThread:thread withObject:link waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseSignInLinkFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseSignInLink:(BMYLink *)link
{
    if ([delegate respondsToSelector:@selector(restClient:signedIn:)]) {
        [delegate restClient:self signedIn:link];
    }
}


- (void)parseSignInLinkFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing link info");
    if ([delegate respondsToSelector:@selector(restClient:signInFailedWithError:)]) {
        [delegate restClient:self signInFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Sign Out

- (void)signOut
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self accessToken], @"token",
                          nil];
    NSString *fullPath = [NSString stringWithFormat:@"/auth/sign_out"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSignOut:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                      nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidSignOut:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:signOutFailedWithError:)]) {
            [delegate restClient:self signOutFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSignOutLinkWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseSignOutLinkWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYLink *signOutLink = [[BMYLink alloc] initWithDictionary:result];
    if (signOutLink) {
        [self performSelector:@selector(didParseSignOutLink:) onThread:thread withObject:signOutLink waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseSignOutLinkFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseSignOutLink:(BMYLink *)signoutLink
{
    if ([delegate respondsToSelector:@selector(restClient:signedOut:)]) {
        [delegate restClient:self signedOut:signoutLink];
    }
}


- (void)parseSignOutLinkFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing link");
    if ([delegate respondsToSelector:@selector(restClient:signOutFailedWithError:)]) {
        [delegate restClient:self signOutFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Change Password

- (void)changePasswordWithParams:(NSDictionary *)params
{
    NSString *fullPath = [NSString stringWithFormat:@"/auth/change_password"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidChangePassword:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)changePassword:(NSString *)username oldPassword:(NSString *)oldpasswd newPassword:(NSString *)newpasswd
{
    if (!username || !oldpasswd || !newpasswd) {
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"username",
                            oldpasswd, @"password",
                            newpasswd, @"new_password",
                            nil];
    [self changePasswordWithParams:params];
}


- (void)requestDidChangePassword:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:changePasswordFailedWithError:)]) {
            [delegate restClient:self changePasswordFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseChangePasswdUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseChangePasswdUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *changePasswdUser = [[BMYUser alloc] initWithDictionary:result];
    if (changePasswdUser) {
        [self performSelector:@selector(didParseChangePasswdUser:) onThread:thread withObject:changePasswdUser waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseChangePasswdUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseChangePasswdUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:changedPassword:)]) {
        [delegate restClient:self changedPassword:user];
    }
}


- (void)parseChangePasswdUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [[NSError alloc] initWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user info");
    if ([delegate respondsToSelector:@selector(restClient:changePasswordFailedWithError:)]) {
        [delegate restClient:self changePasswordFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Forgot Password

- (void)forgotPassword:(NSString *)email
{
    if (!email) {
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                email, @"email",
                                nil];
    NSString *fullPath = [NSString stringWithFormat:@"/auth/forgot_password"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidForgotPassword:)];
    request.userInfo = params;
    [requests addObject:request];
}


- (void)requestDidForgotPassword:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:forgotPasswordFailedWithError:)]) {
            [delegate restClient:self forgotPasswordFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseForgotPasswdUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseForgotPasswdUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseForgotPasswdUser:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseForgotPasswdUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseForgotPasswdUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:forgottenPassword:)]) {
        [delegate restClient:self forgottenPassword:user];
    }
}


- (void)parseForgotPasswdUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user info");
    if ([delegate respondsToSelector:@selector(restClient:forgotPasswordFailedWithError:)]) {
        [delegate restClient:self forgotPasswordFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Reset User Password

- (void)resetPasswordWithParams:(NSDictionary *)params
{
    NSString *fullPath = [NSString stringWithFormat:@"/auth/reset_password"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidResetPassword:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)resetPassword:(NSString *)newPassword
{
    if (!newPassword) {
        return;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          newPassword, @"new_password",
                          [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                          nil];
    [self resetPasswordWithParams:dict];
}


- (void)requestDidResetPassword:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:resetPasswordFailedWithError:)]) {
            [delegate restClient:self resetPasswordFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseResetPasswdUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseResetPasswdUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *resetPasswdUser = [[BMYUser alloc] initWithDictionary:result];
    if (resetPasswdUser) {
        [self performSelector:@selector(didParseResetPasswdUser:) onThread:thread withObject:resetPasswdUser waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseResetPasswdUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseResetPasswdUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:resetPassword:)]) {
        [delegate restClient:self resetPassword:user];
    }
}


- (void)parseResetPasswdUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user info for reset password");
    if ([delegate respondsToSelector:@selector(restClient:resetPasswordFailedWithError:)]) {
        [delegate restClient:self resetPasswordFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Get User Link

- (void)getUserLink:(NSString *)aUserId linkId:(NSString *)linkId
{
    if (!aUserId || !linkId) {
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/links/%@", aUserId, linkId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetUserLink:)];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [self accessToken],    BANMAYUN_ACCESS_TOKEN_KEY,
                                     aUserId,    BANMAYUN_USER_ID_KEY,
                                     linkId,    BANMAYUN_LINK_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetUserLink:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getUserLinkFailedWithError:)]) {
            [delegate restClient:self getUserLinkFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetUserLinkWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseGetUserLinkWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYLink *link = [[BMYLink alloc] initWithDictionary:result];
    if (link) {
        [self performSelector:@selector(didParseGetUserLink:) onThread:thread withObject:link waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseGetUserLinkFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseGetUserLink:(BMYLink *)link
{
    if ([delegate respondsToSelector:@selector(restClient:gotUserLink:)]) {
        [delegate restClient:self gotUserLink:link];
    }
}


- (void)parseGetUserLinkFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing link");
    if ([delegate respondsToSelector:@selector(restClient:getUserLinkFailedWithError:)]) {
        [delegate restClient:self getUserLinkFailedWithError:error];
    }
}


#pragma mark - 
#pragma mark - List User Links

- (void)listUserLinks:(NSString *)aUserId withParams:(NSDictionary *)params
{
    if (!aUserId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/links", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListUserLinks:)];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listUserLinks:(NSString *)aUserId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self accessToken] forKey:BANMAYUN_ACCESS_TOKEN_KEY];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    [self listUserLinks:aUserId withParams:params];
}


- (void)listUserLinks:(NSString *)aUserId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    [self listUserLinks:aUserId withParams:params];
}

- (void)requestDidListUserLinks:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listUserLinksFailedWithError:)]) {
            [delegate restClient:self listUserLinksFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListUserLinksWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseListUserLinksWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYResultList *resultList = [[BMYResultList alloc] initWithDictionary:result];
    if (resultList) {
        [self performSelector:@selector(didParseListUserLinks:) onThread:thread withObject:resultList waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseListUserLinksFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseListUserLinks:(BMYResultList *)resultList
{
    if ([delegate respondsToSelector:@selector(restClient:listedUserLinks:)]) {
        [delegate restClient:self listedUserLinks:resultList];
    }
}


- (void)parseListUserLinksFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user links result list");
    if ([delegate respondsToSelector:@selector(restClient:listUserLinksFailedWithError:)]) {
        [delegate restClient:self listUserLinksFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Delete User Link

- (void)deleteUserLink:(NSString *)aUserId linkId:(NSString *)aLinkId
{
    if (!aUserId || !aLinkId) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/links/%@", aUserId, aLinkId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest
                                                 andInformTarget:self
                                                        selector:@selector(requestDidDeleteUserLink:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId,   BANMAYUN_USER_ID_KEY,
                                     aLinkId,   BANMAYUN_LINK_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteUserLink:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteUserLinkFailedWithError:)]) {
            [delegate restClient:self deleteUserLinkFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseDeleteUserLinkWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseDeleteUserLinkWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYLink *resultLink = [[BMYLink alloc] initWithDictionary:result];
    if (resultLink) {
        [self performSelector:@selector(didParseDeleteUserLink:) onThread:thread withObject:resultLink waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseDeleteUserLinkFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseDeleteUserLink:(BMYLink *)link
{
    if ([delegate respondsToSelector:@selector(restClient:deletedUserLink:)]) {
        [delegate restClient:self deletedUserLink:link];
    }
}


- (void)parseDeleteUserLinkFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing delete user link");
    if ([delegate respondsToSelector:@selector(restClient:deleteUserLinkFailedWithError:)]) {
        [delegate restClient:self deleteUserLinkFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Delete All User Links

- (void)deleteAllUserLinks:(NSString *)aUserId
{
    if (!aUserId) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [self accessToken],    BANMAYUN_ACCESS_TOKEN_KEY,
                                 nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/links", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"DELETE";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteAllUserLinks:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    if (dict) {
        [userInfo addEntriesFromDictionary:dict];
    }
    [requests addObject:request];
}


- (void)requestDidDeleteAllUserLinks:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteAllUserLinksFailedWithError:)]) {
            [delegate restClient:self deleteAllUserLinksFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientDeletedAllUserLinks:)]) {
            [delegate restClientDeletedAllUserLinks:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Exists User

- (void)existsUser:(NSString *)name email:(NSString *)email
{
    if ((!name && !email) || ((name.length == 0)&&(email.length == 0))) {
        return;
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/users/exists"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:nil];
    urlRequest.HTTPMethod = @"POST";
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (name) {
        [bodyDict setObject:name forKey:@"name"];
    }
    if (email) {
        [bodyDict setObject:email forKey:@"email"];
    }
    NSData *bodyData = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = bodyData;
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidExistUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (name) {
        [userInfo setObject:name forKey:@"name"];
    }
    if (email) {
        [userInfo setObject:email forKey:@"email"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidExistUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:existsUserFailedWithError:)]) {
            [delegate restClient:self existsUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseExistsUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseExistsUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseExistsUser:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseExistsUserFailedWithRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseExistsUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:existedUser:)]) {
        [delegate restClient:self existedUser:user];
    }
}


- (void)parseExistsUserFailedWithRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing exists user");
    if ([delegate respondsToSelector:@selector(restClient:existsUserFailedWithError:)]) {
        [delegate restClient:self existsUserFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Create User

- (void)createUser:(NSString *)name password:(NSString *)password email:(NSString *)email displayName:(NSString *)displayName isFromAdmin:(BOOL)isAdmin source:(NSString *)source usingGroupsCanOwn:(BOOL)usingGroupsCanOwn groupsCanOwn:(NSInteger)groupsCanOwn role:(BMYUserRole *)role
{
    if (!name || !password) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   password, @"password",
                                   nil];
    if (isAdmin) {
        [params setObject:[self accessToken] forKey:BANMAYUN_ACCESS_TOKEN_KEY];
    }
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (name) {
        [bodyDict setObject:name forKey:@"name"];
    }
    if (email) {
        [bodyDict setObject:email forKey:@"email"];
    }
    if (displayName) {
        [bodyDict setObject:displayName forKey:@"display_name"];
    }
    if(isAdmin){
        if (source) {
            [bodyDict setObject:source forKey:@"source"];
        }
        if (usingGroupsCanOwn) {
            [bodyDict setObject:[NSNumber numberWithInteger:groupsCanOwn]
                         forKey:@"groups_can_own"];
        }
        if (role) {
            [bodyDict setObject:role forKey:@"role"];
        }
    }
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCreateUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     name, @"name",
                                     nil];
    if (email) {
        [userInfo setObject:email forKey:@"email"];
    }
    if (displayName) {
        [userInfo setObject:displayName forKey:@"display_name"];
    }
    if (source) {
        [userInfo setObject:source forKey:@"source"];
    }
    if (isAdmin) {
        [userInfo setObject:[NSNumber numberWithBool:isAdmin] forKey:@"isAdmin"];
        if (usingGroupsCanOwn) {
            [userInfo setObject:[NSNumber numberWithInteger:groupsCanOwn] forKey:@"groups_can_own"];
        }
        if (role) {
            [userInfo setObject:[role JSONRepresentation] forKey:@"role"];
        }
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidCreateUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createUserFailedWithError:)]) {
            [delegate restClient:self createUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCreateUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseCreateUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *resultUser = [[BMYUser alloc] initWithDictionary:result];
    if (resultUser) {
        [self performSelector:@selector(didParseCreateUser:)
                     onThread:thread
                   withObject:resultUser
                waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseCreateUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseCreateUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:createdUser:)]) {
        [delegate restClient:self createdUser:user];
    }
}


- (void)parseCreateUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user");
    if ([delegate respondsToSelector:@selector(restClient:createUserFailedWithError:)]) {
        [delegate restClient:self createUserFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Get User

- (void)getUser:(NSString *)aUserId
{
    if (!aUserId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getUserLinkFailedWithError:)]) {
            [delegate restClient:self getUserLinkFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseGetUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseGetUser:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseGetUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseGetUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:gotUser:)]) {
        [delegate restClient:self gotUser:user];
    }
}


- (void)parseGetUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user");
    if ([delegate respondsToSelector:@selector(restClient:getUserFailedWithError:)]) {
        [delegate restClient:self getUserFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List Users

- (void)listUsersWithParams:(NSDictionary *)params
{
    NSString *fullPath = [NSString stringWithFormat:@"/users"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                 nil];
    if (params) {
        [dict addEntriesFromDictionary:params];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListUsers:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)listUsers:(NSString *)role usingIsActivated:(BOOL)usingIsActivated isActivated:(BOOL)isActivated usingIsBlocked:(BOOL)usingIsBlocked isBlocked:(BOOL)isBlocked usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (role) {
        [dict setObject:role forKey:@"role"];
    }
    if (usingIsActivated) {
        if (isActivated) {
            [dict setObject:@"true" forKey:@"is_activated"];
        }else{
            [dict setObject:@"false" forKey:@"is_activated"];
        }
    }
    if (usingIsBlocked) {
        if (isBlocked) {
            [dict setObject:@"true" forKey:@"is_blocked"];
        }else{
            [dict setObject:@"false" forKey:@"is_blocked"];
        }
    }
    if (usingOffset) {
        [dict setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [dict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    [self listUsersWithParams:dict];
}

- (void)listUsers
{
    [self listUsersWithParams:nil];
}

- (void)requestDidListUsers:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listUsersFailedWithError:)]) {
            [delegate restClient:self listUsersFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListUsersWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseListUsersWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYResultList *resultList = [[BMYResultList alloc] initWithDictionary:result];
    if (resultList) {
        [self performSelector:@selector(didParseListUsers:) onThread:thread withObject:resultList waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseListUsersFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseListUsers:(BMYResultList *)list
{
    if ([delegate respondsToSelector:@selector(restClient:listedUsers:)]) {
        [delegate restClient:self listedUsers:list];
    }
}


- (void)parseListUsersFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parse result list");
    if ([delegate respondsToSelector:@selector(restClient:listUsersFailedWithError:)]) {
        [delegate restClient:self listUsersFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Update User

- (void)updateUser:(NSString *)aUserId displayName:(NSString *)displayName isFromAdmin:(BOOL)isAdmin usingGroupsCanOwn:(BOOL)usingGroupsCanOwn groupsCanOwn:(NSInteger)groupsCanOwn role:(BMYUserRole *)role usingIsBlocked:(BOOL)usingIsBlocked isBlocked:(BOOL)isBlocked
{
    if (!aUserId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/update", aUserId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken],  BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (displayName) {
        [bodyDict setObject:displayName forKey:@"display_name"];
    }
    if (isAdmin) {
        if (usingGroupsCanOwn) {
            [bodyDict setObject:[NSNumber numberWithInteger:groupsCanOwn] forKey:@"groups_can_own"];
        }
        if (usingIsBlocked) {
            if (isBlocked) {
                [bodyDict setObject:@"true" forKey:@"is_blocked"];
            }else{
                [bodyDict setObject:@"false" forKey:@"is_blocked"];
            }
        }
        if (role) {
            [bodyDict setObject:role forKey:@"role"];
        }
    }
    NSData *bodyData = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = bodyData;
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUpdateUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    if (displayName) {
        [userInfo setObject:displayName forKey:@"display_name"];
    }
    if (isAdmin) {
        if (usingGroupsCanOwn) {
            [userInfo setObject:[NSNumber numberWithInteger:groupsCanOwn] forKey:@"groups_can_own"];
        }
        if (usingIsBlocked) {
            [userInfo setObject:[NSNumber numberWithBool:isBlocked] forKey:@"is_blocked"];
        }
        if (role) {
            [userInfo setObject:role forKey:@"role"];
        }
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidUpdateUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateUserFailedWithError:)]) {
            [delegate restClient:self updateUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseUpdateUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseUpdateUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseUpdateUser:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseUpdateUserFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseUpdateUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:updatedUser:)]) {
        [delegate restClient:self updatedUser:user];
    }
}


- (void)parseUpdateUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK:error parse user");
    if ([delegate respondsToSelector:@selector(restClient:updateUserFailedWithError:)]) {
        [delegate restClient:self updateUserFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Verify User Email

- (void)verifyUserEmail:(NSString *)aUserId
{
    if (!aUserId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/verify_email", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidVerifyUserEmail:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidVerifyUserEmail:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:verifyUserEmailFailedWithError:)]) {
            [delegate restClient:self verifyUserEmailFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseVerifyUserEmailWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseVerifyUserEmailWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseVerifyUserEmail:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseVerifyUserEmailFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseVerifyUserEmail:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:verifiedUserEmail:)]) {
        [delegate restClient:self verifiedUserEmail:user];
    }
}


- (void)parseVerifyUserEmailFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK:error parse user");
    if ([delegate respondsToSelector:@selector(restClient:verifyUserEmailFailedWithError:)]) {
        [delegate restClient:self verifyUserEmailFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Set User Password

- (void)setUserPassword:(NSString *)aUserId withParams:(NSDictionary *)params
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (params) {
        [dict addEntriesFromDictionary:params];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/password", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetUserPassword:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)setUserPassword:(NSString *)aUserId newPassword:(NSString *)newPassword
{
    if (!aUserId || !newPassword) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   newPassword, @"new_password",
                                   nil];
    [self setUserPassword:aUserId withParams:params];
}


- (void)requestDidSetUserPassword:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setUserPasswordFailedWithError:)]) {
            [delegate restClient:self setUserPasswordFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSetUserPasswordWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseSetUserPasswordWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *user = [[BMYUser alloc] initWithDictionary:result];
    if (user) {
        [self performSelector:@selector(didParseSetUserPassword:) onThread:thread withObject:user waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseSetUserPasswordFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseSetUserPassword:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:doneSetUserPassword:)]) {
        [delegate restClient:self doneSetUserPassword:user];
    }
}


- (void)parseSetUserPasswordFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK:error parse user");
    if ([delegate respondsToSelector:@selector(restClient:setUserPasswordFailedWithError:)]) {
        [delegate restClient:self setUserPasswordFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Set User Avatar

- (void)setUserAvatar:(NSString *)aUserId avatar:(NSData *)avatar format:(NSString *)format
{
    if (!aUserId || !format) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                 nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/avatar", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = avatar;
    
    NSString *contentTypeStr;
    if ([[format lowercaseString] isEqualToString:@"jpg"]
        || [[format lowercaseString] isEqualToString:@"jpeg"]) {
        contentTypeStr = @"image/jpeg";
    }else if([[format lowercaseString] isEqualToString:@"png"]){
        contentTypeStr = @"image/png";
    }
    [urlRequest addValue:contentTypeStr forHTTPHeaderField:@"Content-Type"];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetUserAvatar:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidSetUserAvatar:(BMYRequest *)request
{
    NSLog(@"%d", [[request response] statusCode]);
    
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setUserAvatarFailedWithError:)]) {
            [delegate restClient:self setUserAvatarFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientSetUserAvatar:)]) {
            [delegate restClientSetUserAvatar:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Get User Avatar

- (NSString *)userAvatarKeyForUserId:(NSString *)aUserId
{
    return [NSString stringWithFormat:@"%@", aUserId];
}

- (void)getUserAvatar:(NSString *)aUserId params:(NSDictionary *)params
{
    if (!aUserId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/avatar", aUserId];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                 nil];
    if (params) {
        [dict addEntriesFromDictionary:params];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:dict];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetUserAvatar:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [imageLoadRequests setObject:request forKey:[self userAvatarKeyForUserId:aUserId]];
}

- (void)getUserAvatar:(NSString *)aUserId format:(NSString *)format size:(NSString *)size
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (format) {
        [params setObject:format forKey:@"format"];
    }
    if (size) {
        [params setObject:size forKey:@"size"];
    }
    [self getUserAvatar:aUserId params:params];
}


- (void)requestDidGetUserAvatar:(BMYRequest *)request
{
    NSData *avatarData = request.resultData;
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getUserAvatarFailedWithError:)]) {
            [delegate restClient:self getUserAvatarFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClient:gotUserAvatar:)]) {
            [delegate restClient:self gotUserAvatar:avatarData];
        }
    }
    [imageLoadRequests removeObjectForKey:[self userAvatarKeyForUserId:[request.userInfo objectForKey:BANMAYUN_USER_ID_KEY]]];
}


/*
 User Group Common Usage Method
 */
- (void)parseUserGroupObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSeccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *resultDic = (NSDictionary *)[request resultJSON];
    if (resultDic) {
        [self performSelector:aSeccSelector onThread:thread withObject:resultDic waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


#pragma mark -
#pragma mark - Add User Group

- (void)addUserGroup:(NSString *)aUserId groupId:(NSString *)groupId remarks:(NSString *)remarks isFromAdmin:(BOOL)isAdmin role:(BMYRelationRole *)role
{
    if (!aUserId || !groupId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/groups", aUserId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   groupId, BANMAYUN_GROUP_ID_KEY,
                                   nil];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (remarks) {
        [bodyDict setObject:remarks forKey:@"remarks"];
    }
    if (isAdmin) {
        if (role) {
            [bodyDict setObject:role forKey:@"role"];
        }
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidAddUserGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (remarks) {
        [userInfo setObject:remarks forKey:@"remarks"];
    }
    if (role) {
        [userInfo setObject:[role JSONRepresentation] forKey:@"role"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidAddUserGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:addUserGroupFailedWithError:)]) {
            [delegate restClient:self addUserGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseAddUserGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseAddUserGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
//    NSDictionary *result = (NSDictionary *)[request resultJSON];
//    BMYGroup *group = [[BMYGroup alloc] initWithDictionary:result];
//    if (group) {
//        [self performSelector:@selector(didParseAddUserGroup:) onThread:thread withObject:group waitUntilDone:NO];
//    }else{
//        [self performSelector:@selector(parseAddUserGroupFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
//    }
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseAddUserGroup:) failSelector:@selector(parseAddUserGroupFailedForRequest:)];
}


- (void)didParseAddUserGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:addedUserGroup:)]) {
        [delegate restClient:self addedUserGroup:group];
    }
}


- (void)parseAddUserGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:addUserGroupFailedWithError:)]) {
        [delegate restClient:self addUserGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Get User Group

- (void)getUserGroup:(NSString *)aUserId groupId:(NSString *)groupId
{
    if (!aUserId || !groupId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/groups/%@", aUserId, groupId];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                            nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetUserGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId,   BANMAYUN_USER_ID_KEY,
                                     groupId,   BANMAYUN_GROUP_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetUserGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getUserGroupFailedWithError:)]) {
            [delegate restClient:self getUserGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetUserGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseGetUserGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseGetUserGroup:) failSelector:@selector(parseGetUserGroupFailedForRequest:)];
}


- (void)didParseGetUserGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:gotUserGroup:)]) {
        [delegate restClient:self gotUserGroup:group];
    }
}


- (void)parseGetUserGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if([delegate respondsToSelector:@selector(restClient:getUserGroupFailedWithError:)]){
        [delegate restClient:self getUserGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List User Groups

- (void)listUserGroups:(NSString *)aUserId role:(NSString *)role usingIsActivatedParam:(BOOL)usingIsActivedOrNot isActivated:(BOOL)isActivated usingIsBlockedParam:(BOOL)usingIsBlockedOrNot isBlocked:(BOOL)isBlocked usingOffsetParam:(BOOL)usingOffsetOrNot offset:(NSInteger)offset usingLimitParam:(BOOL)usingLimitOrNot limit:(NSInteger)limit
{
    if (!aUserId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (role) {
        [params setObject:role forKey:@"role"];
    }
    if (usingIsActivedOrNot) {
        if (isActivated) {
            [params setObject:@"true" forKey:@"is_activated"];
        }else{
            [params setObject:@"false" forKey:@"is_activated"];
        }
    }
    if (usingIsBlockedOrNot) {
        if (isBlocked) {
            [params setObject:@"true" forKey:@"is_blocked"];
        }else{
            [params setObject:@"false" forKey:@"is_blocked"];
        }
    }
    if (usingOffsetOrNot) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimitOrNot) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/groups", aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListUserGroups:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listUserGroups:(NSString *)aUserId role:(NSString *)role
{
    [self listUserGroups:aUserId role:role usingIsActivatedParam:NO isActivated:NO usingIsBlockedParam:NO isBlocked:NO usingOffsetParam:NO offset:0 usingLimitParam:NO limit:0];
}


- (void)listUserGroups:(NSString *)aUserId
{
    [self listUserGroups:aUserId role:nil];
}


- (void)requestDidListUserGroups:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listUserGroupsFailedWithError:)]) {
            [delegate restClient:self listUserGroupsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListUserGroupsWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseListUserGroupsWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYResultList *groupList = [[BMYResultList alloc] initWithDictionary:result];
    if (groupList) {
        [self performSelector:@selector(didParseListUserGroups:) onThread:thread withObject:groupList waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseListUserGroupsFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseListUserGroups:(BMYResultList *)groupList
{
    if ([delegate respondsToSelector:@selector(restClient:listedUserGroups:)]) {
        [delegate restClient:self listedUserGroups:groupList];
    }
}


- (void)parseListUserGroupsFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing groups result list");
    if ([delegate respondsToSelector:@selector(restClient:listUserGroupsFailedWithError:)]) {
        [delegate restClient:self listUserGroupsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Update User Group

- (void)updateUserGroup:(NSString *)aUserId groupId:(NSString *)groupId role:(BMYRelationRole *)role usingIsActivated:(BOOL)usingIsActivedOrNot isActivated:(BOOL)isActivated usingIsBlocked:(BOOL)usingIsBlockedOrNot isBlocked:(BOOL)isBlocked
{
    if (!aUserId || !groupId) {
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                            nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/groups/%@/update", aUserId, groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];

        if (role) {
            [bodyDict setObject:role forKey:@"role"];
        }
        if (usingIsActivedOrNot) {
            if (isActivated) {
                [bodyDict setObject:@"true" forKey:@"is_activated"];
            }else{
                [bodyDict setObject:@"false" forKey:@"is_activated"];
            }
        }
    if (usingIsBlockedOrNot) {
        if (isBlocked) {
            [bodyDict setObject:@"true" forKey:@"is_blocked"];
        }else{
                [bodyDict setObject:@"false" forKey:@"is_blocked"];
        }
    }
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUpdateUserGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                              aUserId, BANMAYUN_USER_ID_KEY,
                              groupId, BANMAYUN_GROUP_ID_KEY,
                              nil];
    if (role) {
        [userInfo setObject:role forKey:@"role"];
    }
    if (usingIsActivedOrNot) {
        [userInfo setObject:[NSNumber numberWithBool:isActivated] forKey:@"is_activated"];
    }
    if (usingIsBlockedOrNot) {
        [userInfo setObject:[NSNumber numberWithBool:isBlocked] forKey:@"is_blocked"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)updateUserGroup:(NSString *)aUserId groupId:(NSString *)groupId
{
    [self updateUserGroup:aUserId groupId:groupId role:nil usingIsActivated:NO isActivated:NO usingIsBlocked:NO isBlocked:NO];
}


- (void)requestDidUpdateUserGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateUserGroupFailedWithError:)]) {
            [delegate restClient:self updateUserGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseUpdateUserGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseUpdateUserGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseUpdateUserGroup:) failSelector:@selector(parseUpdateUserGroupFailedForRequest:)];
}


- (void)didParseUpdateUserGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:updatedUserGroup:)]) {
        [delegate restClient:self updatedUserGroup:group];
    }
}


- (void)parseUpdateUserGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:updateUserGroupFailedWithError:)]) {
        [delegate restClient:self updateUserGroupFailedWithError:error];
    }
}


#pragma mark - 
#pragma mark - Remove User Group

- (void)removeUserGroup:(NSString *)aUserId groupId:(NSString *)groupId
{
    if (!aUserId || !groupId) {
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                            nil];
    NSString *fullPath = [NSString stringWithFormat:@"/users/%@/groups/%@", aUserId, groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidRemoveUserGroup:)];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                              aUserId, BANMAYUN_USER_ID_KEY,
                              groupId, BANMAYUN_GROUP_ID_KEY,
                              nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidRemoveUserGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:removeUserGroupFailedWithError:)]) {
            [delegate restClient:self removeUserGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseRemoveUserGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseRemoveUserGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseRemoveUserGroup:) failSelector:@selector(parseRemoveUserGroupFailedForRequest:)];
}


- (void)didParseRemoveUserGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:removedUserGroup:)]) {
        [delegate restClient:self removedUserGroup:group];
    }
}


- (void)parseRemoveUserGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK:error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:removeUserGroupFailedWithError:)]) {
        [delegate restClient:self removeUserGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Exists Group

- (void)existsGroup:(NSString *)name
{
    if (!name) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/groups/exists"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                            nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (name) {
        [bodyDict setObject:name forKey:@"name"];
    }
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidExistGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                              nil];
    if (name) {
        [userInfo setObject:name forKey:@"name"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidExistGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:existsGroupFailedWithError:)]) {
            [delegate restClient:self existsGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseExistsGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseExistsGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseExistsGroup:) failSelector:@selector(parseExistsGroupFailedForRequest:)];
}


- (void)didParseExistsGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:existedGroup:)]) {
        [delegate restClient:self existedGroup:group];
    }
}


- (void)parseExistsGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:existsGroupFailedWithError:)]) {
        [delegate restClient:self existsGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Create Group

- (void)createGroup:(NSString *)name type:(BMYGroupType *)groupType isVisible:(BOOL)isVisible intro:(NSString *)introduction tags:(NSString *)tags announce:(NSString *)announce isFromAdmin:(BOOL)isAdmin ownerId:(NSString *)ownerId source:(NSString *)source
{
    if (!name || !groupType) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (isAdmin) {
        if (ownerId) {
            [params setObject:ownerId forKey:@"owner_id"];
        }
    }
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:name forKey:@"name"];
    [bodyDict setObject:groupType forKey:@"type"];
    if (isVisible) {
        [bodyDict setObject:@"true" forKey:@"is_visible"];
    }else{
        [bodyDict setObject:@"false" forKey:@"is_visible"];
    }
    if (introduction) {
        [bodyDict setObject:introduction forKey:@"intro"];
    }
    if (tags) {
        [bodyDict setObject:tags forKey:@"tags"];
    }
    if (announce) {
        [bodyDict setObject:announce forKey:@"announde"];
    }
    
    if (isAdmin) {
        if (source) {
            [bodyDict setObject:source forKey:@"source"];
        }
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/groups"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCreateGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (name) {
        [userInfo setObject:name forKey:@"name"];
    }
    if (groupType) {
        [userInfo setObject:groupType forKey:@"type"];
    }
    [userInfo setObject:[NSNumber numberWithBool:isVisible] forKey:@"is_visible"];
    if (introduction) {
        [userInfo setObject:introduction forKey:@"intro"];
    }
    if (tags) {
        [userInfo setObject:tags forKey:@"tags"];
    }
    if (announce) {
        [userInfo setObject:announce forKey:@"announce"];
    }
    if (isAdmin) {
        if (ownerId) {
            [userInfo setObject:ownerId forKey:@"owner_id"];
        }
        if (source) {
            [userInfo setObject:source  forKey:@"source"];
        }
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)createGroup:(NSString *)name type:(BMYGroupType *)groupType isVisible:(BOOL)isVisible
{
    [self createGroup:name type:groupType isVisible:isVisible intro:nil tags:nil announce:nil isFromAdmin:NO ownerId:nil source:nil];
}


- (void)requestDidCreateGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createGroupFailedWithError:)]) {
            [delegate restClient:self createGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCreateGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}

- (void)parseCreateGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseCreateGroup:) failSelector:@selector(parseCreateGroupFailedForRequest:)];
}


- (void)didParseCreateGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:createdGroup:)]) {
        [delegate restClient:self createdGroup:group];
    }
}


- (void)parseCreateGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:createGroupFailedWithError:)]) {
        [delegate restClient:self createGroupFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Get Group

- (void)getGroup:(NSString *)groupId
{
    if (!groupId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@", groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getGroupFailedWithError:)]) {
            [delegate restClient:self getGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseGetGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseGetGroup:) failSelector:@selector(parseGetGroupFailedForRequest:)];
}


- (void)didParseGetGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:gotGroup:)]) {
        [delegate restClient:self gotGroup:group];
    }
}


- (void)parseGetGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:getGroupFailedWithError:)]) {
        [delegate restClient:self getGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List Groups

- (void)listGroups:(NSString *)type usingIsActivated:(BOOL)usingIsActivatedOrNot isAcivated:(BOOL)isActivated usingIsBlocked:(BOOL)usingIsBlockedOrNot isBlocked:(BOOL)isBlocked usingOffset:(BOOL)usingOffsetOrNot offset:(NSInteger)offset usingLimit:(BOOL)usingLimitOrNot limit:(NSInteger)limit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken],  BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (type) {
        [params setObject:type forKey:@"type"];
    }
    if (usingIsActivatedOrNot) {
        if (isActivated) {
            [params setObject:@"true" forKey:@"is_activated"];
        }else{
            [params setObject:@"false" forKey:@"is_activated"];
        }
    }
    if (usingIsBlockedOrNot) {
        if (isBlocked) {
            [params setObject:@"true" forKey:@"is_blocked"];
        }else{
            [params setObject:@"false" forKey:@"is_blocked"];
        }
    }
    if (usingOffsetOrNot) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimitOrNot) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/groups"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListGroups:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listGroups
{
    [self listGroups:nil usingIsActivated:NO isAcivated:NO usingIsBlocked:NO isBlocked:NO usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidListGroups:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listGroupsFailedWithError:)]) {
            [delegate restClient:self listGroupsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListGroupsWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseListGroupsWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYResultList *groupList = [[BMYResultList alloc] initWithDictionary:result];
    if (groupList) {
        [self performSelector:@selector(didParseListGroups:) onThread:thread withObject:groupList waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseListGroupsFailedForRequest:) onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)didParseListGroups:(BMYResultList *)groupList
{
    if ([delegate respondsToSelector:@selector(restClient:listedGroups:)]) {
        [delegate restClient:self listedGroups:groupList];
    }
}


- (void)parseListGroupsFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group result list");
    if ([delegate respondsToSelector:@selector(restClient:listGroupsFailedWithError:)]) {
        [delegate restClient:self listGroupsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Update Group

- (void)updateGroup:(NSString *)groupId type:(BMYGroupType *)type isVisible:(BOOL)isVisible intro:(NSString *)intro tags:(NSString *)tags announce:(NSString *)announce isFromAdmin:(BOOL)isAdmin usingIsBlocked:(BOOL)usingIsBlocked isBlocked:(BOOL)isBlocked
{
    if (!groupId || !type) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/update", groupId];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (type) {
        [bodyDict setObject:type forKey:@"type"];
    }
    if (isVisible) {
        [bodyDict setObject:@"true" forKey:@"is_visible"];
    }else{
        [bodyDict setObject:@"false" forKey:@"is_visible"];
    }
    if (intro) {
        [bodyDict setObject:intro forKey:@"intro"];
    }
    if (tags) {
        [bodyDict setObject:tags forKey:@"tags"];
    }
    if (announce) {
        [bodyDict setObject:announce forKey:@"announce"];
    }
    if (isAdmin) {
        if (usingIsBlocked) {
            if (isBlocked) {
                [bodyDict setObject:@"true" forKey:@"is_blocked"];
            }else{
                [bodyDict setObject:@"false" forKey:@"is_blocked"];
            }
        }
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUpdateGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    if (type) {
        [userInfo setObject:[type JSONRepresentation] forKey:@"type"];
    }
    [userInfo setObject:[NSNumber numberWithBool:isVisible] forKey:@"is_visible"];
    if (intro) {
        [userInfo setObject:intro forKey:@"intro"];
    }
    if (tags) {
        [userInfo setObject:tags forKey:@"tags"];
    }
    if (announce) {
        [userInfo setObject:announce forKey:@"announce"];
    }
    if (isAdmin) {
        if (usingIsBlocked) {
            [userInfo setObject:[NSNumber numberWithBool:isBlocked] forKey:@"is_blocked"];
        }
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)updateGroup:(NSString *)groupId type:(BMYGroupType *)type isVisible:(BOOL)isVisible isFromAdmin:(BOOL)isAdmin usingIsBlocked:(BOOL)usingIsBlocked isBlocked:(BOOL)isBlocked
{
    [self updateGroup:groupId type:type isVisible:isVisible intro:nil tags:nil announce:nil isFromAdmin:isAdmin usingIsBlocked:usingIsBlocked isBlocked:isBlocked];
}


- (void)updateGroup:(NSString *)groupId type:(BMYGroupType *)type isVisible:(BOOL)isVisible
{
    [self updateGroup:groupId type:type isVisible:isVisible isFromAdmin:NO usingIsBlocked:NO isBlocked:NO];
}


- (void)requestDidUpdateGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateGroupFailedWithError:)]) {
            [delegate restClient:self updateGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseUpdateGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseUpdateGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseUpdateGroup:) failSelector:@selector(parseUpdateGroupFailedForRequest:)];
}


- (void)didParseUpdateGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:updatedGroup:)]) {
        [delegate restClient:self updatedGroup:group];
    }
}


- (void)parseUpdateGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:updateGroupFailedWithError:)]) {
        [delegate restClient:self updateGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Delete Group

- (void)deleteGroup:(NSString *)groupId
{
    if (!groupId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@", groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteGroup:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteGroup:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteGroupFailedWithError:)]) {
            [delegate restClient:self deleteGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseDeleteGroupWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseDeleteGroupWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserGroupObject:request resultThread:thread succSelector:@selector(didParseDeleteGroup:) failSelector:@selector(parseDeleteGroupFailedForRequest:)];
}


- (void)didParseDeleteGroup:(BMYGroup *)group
{
    if ([delegate respondsToSelector:@selector(restClient:deletedGroup:)]) {
        [delegate restClient:self deletedGroup:group];
    }
}


- (void)parseDeleteGroupFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing group");
    if ([delegate respondsToSelector:@selector(restClient:deleteGroupFailedWithError:)]) {
        [delegate restClient:self deleteGroupFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Set Group Logo

- (void)setGroupLogo:(NSString *)groupId logo:(NSData *)logo format:(NSString *)format
{
    if (!groupId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/logo", groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = logo;
    if ([[format lowercaseString] isEqualToString:@"png"]) {
        [urlRequest addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    }else if([[format lowercaseString] isEqualToString:@"jpg"] || [[format lowercaseString] isEqualToString:@"jpeg"]){
        [urlRequest addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    }
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetGroupLogo:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidSetGroupLogo:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setGroupLogoFailedWithError:)]) {
            [delegate restClient:self setGroupLogoFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientDoneSetGroupLogo:)]) {
            [delegate restClientDoneSetGroupLogo:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Get Group Logo

- (NSString *)groupLogoKeyForGroupId:(NSString *)groupId
{
    return [NSString stringWithFormat:@"%@", groupId];
}

- (void)getGroupLogo:(NSString *)groupId format:(NSString *)format size:(NSString *)size
{
    if (!groupId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (format) {
        [params setObject:format forKey:@"format"];
    }
    if (size) {
        [params setObject:size forKey:@"size"];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/logo", groupId];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetGroupLogo:)];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [imageLoadRequests setObject:request forKey:[self groupLogoKeyForGroupId:groupId]];
}


- (void)requestDidGetGroupLogo:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getGroupFailedWithError:)]) {
            [delegate restClient:self getGroupFailedWithError:request.error];
        }
    }else{
        NSData *groupLogoData = request.resultData;
        if ([delegate respondsToSelector:@selector(restClient:gotGroupLogo:)]) {
            [delegate restClient:self gotGroupLogo:groupLogoData];
        }
    }
    [imageLoadRequests removeObjectForKey:[self groupLogoKeyForGroupId:[request.userInfo objectForKey:BANMAYUN_GROUP_ID_KEY]]];
}


#pragma mark -
#pragma mark - Add Group User

- (void)addGroupUser:(NSString *)groupId userId:(NSString *)aUserId
{
    if (groupId == nil || aUserId == nil) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   aUserId, BANMAYUN_USER_ID_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/users", groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidAddGroupUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidAddGroupUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:addGroupUserFailedWithError:)]) {
            [delegate restClient:self addGroupUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseAddGroupUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseAddGroupUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserObject:request resultThread:thread succSelector:@selector(didParseAddGroupUser:) failSelector:@selector(parseAddGroupUserFailedForRequest:)];
}


- (void)didParseAddGroupUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:addedGroupUser:)]) {
        [delegate restClient:self addedGroupUser:user];
    }
}


- (void)parseAddGroupUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user");
    if ([delegate respondsToSelector:@selector(restClient:addGroupUserFailedWithError:)]) {
        [delegate restClient:self addGroupUserFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Get Group User

- (void)getGroupUser:(NSString *)groupId userId:(NSString *)aUserId
{
    if (groupId == nil || aUserId == nil) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/users/%@", groupId, aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetGroupUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetGroupUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getGroupFailedWithError:)]) {
            [delegate restClient:self getGroupFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetGroupUserWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseGetGroupUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserObject:request resultThread:thread succSelector:@selector(didParseGetGroupUser:) failSelector:@selector(parseGetGroupUserFailedForRequest:)];
}


- (void)didParseGetGroupUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:gotGroupUser:)]) {
        [delegate restClient:self gotGroupUser:user];
    }
}


- (void)parseGetGroupUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parse user");
    if ([delegate respondsToSelector:@selector(restClient:getGroupUserFailedWithError:)]) {
        [delegate restClient:self getGroupUserFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - List Group Users

- (void)listGroupUsers:(NSString *)groupId role:(NSString *)role usingIsActivated:(BOOL)usingIsActivatedOrNot isActivated:(BOOL)isActivated usingIsBlocked:(BOOL)usingIsBlockedOrNot isBlocked:(BOOL)isBlocked usingOffset:(BOOL)usingOffsetOrNot offset:(NSInteger)offset usingLimit:(BOOL)usingLimitOrNot limit:(NSInteger)limit
{
    if (!groupId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken],  BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (role) {
        [params setObject:role forKey:@"role"];
    }
    if (usingIsActivatedOrNot) {
        if (isActivated) {
            [params setObject:@"true" forKey:@"is_activated"];
        }else{
            [params setObject:@"false" forKey:@"is_activated"];
        }
    }
    if (usingIsBlockedOrNot) {
        if (isBlocked) {
            [params setObject:@"true" forKey:@"is_blocked"];
        }else{
            [params setObject:@"false" forKey:@"is_blocked"];
        }
    }
    if (usingOffsetOrNot) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimitOrNot) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/users", groupId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListGroupUsers:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listGroupUsers:(NSString *)groupId
{
    [self listGroupUsers:groupId role:nil usingIsActivated:NO isActivated:NO usingIsBlocked:NO isBlocked:NO usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidListGroupUsers:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listGroupUsersFailedWithError:)]) {
            [delegate restClient:self listGroupUsersFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListGroupUsersWithRequest:resultThread:);
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:sel];
        [inv setArgument:&request atIndex:2];
        NSThread *thread = [NSThread currentThread];
        [inv setArgument:&thread atIndex:3];
        [inv retainArguments];
        [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    }
    [requests removeObject:request];
}


- (void)parseListGroupUsersWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYUser class] resultThread:thread succSelector:@selector(didParseListGroupUsers:) failSelector:@selector(parseListGroupUsersFailedForRequest:)];
}


- (void)didParseListGroupUsers:(BMYResultList *)groupUsersList
{
    if ([delegate respondsToSelector:@selector(restClient:listedGroupUsers:)]) {
        [delegate restClient:self listedGroupUsers:groupUsersList];
    }
}


- (void)parseListGroupUsersFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:listGroupUsersFailedWithError:)]) {
        [delegate restClient:self listGroupUsersFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Update Group User

- (void)updateGroupUser:(NSString *)groupId userId:(NSString *)aUserId role:(BMYRelationRole *)role usingIsActived:(BOOL)usingIsActived isActivated:(BOOL)isActivated usingIsBlocked:(BOOL)usingIsBlocked isBlocked:(BOOL)isBlocked
{
    if (groupId == nil || aUserId == nil) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/users/%@/update", groupId, aUserId];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (role) {
        [bodyDict setObject:role forKey:@"role"];
    }
    if (usingIsActived) {
        if (isActivated) {
            [bodyDict setObject:@"true" forKey:@"is_activated"];
        }else{
            [bodyDict setObject:@"false" forKey:@"is_activated"];
        }
    }
    if (usingIsBlocked) {
        if (isBlocked) {
            [bodyDict setObject:@"true" forKey:@"is_blocked"];
        }else{
            [bodyDict setObject:@"false" forKey:@"is_blocked"];
        }
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUpdateGroupUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (role) {
        [userInfo setObject:[role JSONRepresentation] forKey:@"role"];
    }
    if (usingIsActived) {
        [userInfo setObject:[NSNumber numberWithBool:isActivated] forKey:@"is_activated"];
    }
    if (usingIsBlocked) {
        [userInfo setObject:[NSNumber numberWithBool:isBlocked] forKey:@"is_blocked"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)updateGroupUser:(NSString *)groupId userId:(NSString *)aUserId
{
    [self updateGroupUser:groupId userId:aUserId role:nil usingIsActived:NO isActivated:NO usingIsBlocked:NO isBlocked:NO];
}


- (void)requestDidUpdateGroupUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateGroupUserFailedWithError:)]) {
            [delegate restClient:self updateGroupUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseUpdateGroupUserWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseUpdateGroupUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserObject:request resultThread:thread succSelector:@selector(didParseUpdateGroupUser:) failSelector:@selector(parseUpdateGroupUserFailedForRequest:)];
}


- (void)didParseUpdateGroupUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:updatedGroupUser:)]) {
        [delegate restClient:self updatedGroupUser:user];
    }
}


- (void)parseUpdateGroupUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user");
    if ([delegate respondsToSelector:@selector(restClient:updateGroupUserFailedWithError:)]) {
        [delegate restClient:self updateGroupUserFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Remove Group User

- (void)removeGroupUser:(NSString *)groupId userId:(NSString *)aUserId
{
    if (!groupId || !aUserId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/groups/%@/users/%@", groupId, aUserId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidRemoveGroupUser:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     groupId, BANMAYUN_GROUP_ID_KEY,
                                     aUserId, BANMAYUN_USER_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidRemoveGroupUser:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:removeGroupUserFailedWithError:)]) {
            [delegate restClient:self removeGroupUserFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseRemoveGroupUserWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseRemoveGroupUserWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseUserObject:request resultThread:thread succSelector:@selector(didParseRemoveGroupUser:) failSelector:@selector(parseRemoveGroupUserFailedForRequest:)];
}


- (void)didParseRemoveGroupUser:(BMYUser *)user
{
    if ([delegate respondsToSelector:@selector(restClient:removedGroupUser:)]) {
        [delegate restClient:self removedGroupUser:user];
    }
}


- (void)parseRemoveGroupUserFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing user");
    if ([delegate respondsToSelector:@selector(restClient:removeGroupUserFailedWithError:)]) {
        [delegate restClient:self removeGroupUserFailedWithError:error];
    }
}




#pragma mark -
#pragma mark - Get Root

- (void)getRoot:(NSString *)rootId
{
    if (!rootId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@", rootId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetRoot:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      rootId, BANMAYUN_ROOT_ID_KEY,
                                      [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetRoot:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getRootFailedWithError:)]) {
            [delegate restClient:self getRootFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetRootWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseGetRootWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseRootObject:request resultThread:thread succSelector:@selector(didParseGetRoot:) failSelector:@selector(parseGetRootFailedForRequest:)];
}


- (void)didParseGetRoot:(BMYRoot *)aRoot
{
    if ([delegate respondsToSelector:@selector(restClient:gotRoot:)]) {
        [delegate restClient:self gotRoot:aRoot];
    }
}


- (void)parseGetRootFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing root");
    if ([delegate respondsToSelector:@selector(restClient:getRootFailedWithError:)]) {
        [delegate restClient:self getRootFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Set Default Permission

- (void)setDefaultPermission:(NSString *)aRootId insertableToOwner:(BOOL)insertableToOwner readableToOwner:(BOOL)readableToOwner writableToOwner:(BOOL)writableToOwner deletableToOwner:(BOOL)deletableToOwner insertableToOthers:(BOOL)insertableToOthers readableToOthers:(BOOL)readableToOthers writableToOthers:(BOOL)writableToOthers deletableToOthers:(BOOL)deletableToOthers
{
    if (aRootId == nil) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/default_permission", aRootId];

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (writableToOthers) {
        [bodyDict setObject:@"true" forKey:@"writable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"writable_to_others"];
    }
    
    if (readableToOthers) {
        [bodyDict setObject:@"true" forKey:@"readable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"readable_to_others"];
    }
    if (insertableToOthers) {
        [bodyDict setObject:@"true" forKey:@"insertable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"insertable_to_others"];
    }
    if (deletableToOthers) {
        [bodyDict setObject:@"true" forKey:@"deletable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"deletable_to_others"];
    }
    
    if (writableToOwner) {
        [bodyDict setObject:@"true" forKey:@"writable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"writable_to_owner"];
    }
    
    if (readableToOwner) {
        [bodyDict setObject:@"true" forKey:@"readable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"readable_to_owner"];
    }
    if (insertableToOwner) {
        [bodyDict setObject:@"true" forKey:@"insertable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"insertable_to_owner"];
    }
    if (deletableToOwner) {
        [bodyDict setObject:@"true" forKey:@"deletable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"deletable_to_owner"];
    }
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetDefaultPermission:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     aRootId, BANMAYUN_ROOT_ID_KEY,
                                     [NSNumber numberWithBool:insertableToOwner], @"insertable_to_owner",
                                     [NSNumber numberWithBool:readableToOwner], @"readable_to_owner",
                                     [NSNumber numberWithBool:writableToOwner], @"writable_to_owner",
                                     [NSNumber numberWithBool:deletableToOwner], @"deletable_to_owner",
                                     [NSNumber numberWithBool:insertableToOthers], @"insertable_to_others",
                                     [NSNumber numberWithBool:readableToOthers], @"readable_to_others",
                                     [NSNumber numberWithBool:writableToOthers], @"writable_to_others",
                                     [NSNumber numberWithBool:deletableToOthers], @"deletable_to_others",
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidSetDefaultPermission:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setDefaultPermissionFailedWithError:)]) {
            [delegate restClient:self setDefaultPermissionFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSetDefaultPermissionRootWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseSetDefaultPermissionRootWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseRootObject:request resultThread:thread succSelector:@selector(didParseSetDefaultPermissionRoot:) failSelector:@selector(parseSetDefaultPermissionRootForRequest:)];
}


- (void)didParseSetDefaultPermissionRoot:(BMYRoot *)aRoot
{
    if ([delegate respondsToSelector:@selector(restClient:doneSetDefaultPermission:)]) {
        [delegate restClient:self doneSetDefaultPermission:aRoot];
    }
}


- (void)parseSetDefaultPermissionRootForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing root");
    if ([delegate respondsToSelector:@selector(restClient:setDefaultPermissionFailedWithError:)]) {
        [delegate restClient:self setDefaultPermissionFailedWithError:error];
    }
}


#pragma mark - 
#pragma mark - Set Root Quota

- (void)setRootQuota:(NSString *)aRootId quota:(NSString *)quota
{
    if (aRootId == nil) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   quota, @"quota",
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/quota", aRootId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetRootQuota:)];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              aRootId, @"root_id",
                              [self accessToken], @"token",
                              quota, @"quota",
                              nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidSetRootQuota:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setRootQuotaFailedWithError:)]) {
            [delegate restClient:self setRootQuotaFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSetRootQuotaRootWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}

- (void)parseSetRootQuotaRootWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseRootObject:request resultThread:thread succSelector:@selector(didParseSetRootQuotaRoot:) failSelector:@selector(parseSetRootQuotaRootFailedForRequest:)];
}


- (void)didParseSetRootQuotaRoot:(BMYRoot *)aRoot
{
    if ([delegate respondsToSelector:@selector(restClient:doneSetRootQuota:)]) {
        [delegate restClient:self doneSetRootQuota:aRoot];
    }
}


- (void)parseSetRootQuotaRootFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing root");
    if ([delegate respondsToSelector:@selector(restClient:setRootQuotaFailedWithError:)]) {
        [delegate restClient:self setRootQuotaFailedWithError:error];
    }
}


#pragma mark - 
#pragma mark - Put File by Path

- (NSString *)putFileByPathKeyWithRootId:(NSString *)rootId path:(NSString *)path
{
    return [NSString stringWithFormat:@"rootId#path"];
}

- (void)putFileByPathWithRootId:(NSString *)rootId path:(NSString *)path modifiedAtMillis:(long)modifiedAtMillis usingOverwrite:(BOOL)usingOverwrite overwrite:(BOOL)overwrite fromPath:(NSString *)sourcePath
{
    if (!rootId) {
        return;
    }
    BOOL isDir = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&isDir];
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:sourcePath error:nil];
    if (!fileExists || isDir || !fileAttrs) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  sourcePath, BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY,
                                  rootId, BANMAYUN_ROOT_ID_KEY,
                                  path, BANMAYUN_FILE_DESTINATION_PATH_KEY,
                                  nil];
        if (usingOverwrite) {
            [userInfo setObject:[NSNumber numberWithBool:overwrite] forKey:@"overwrite"];
        }
        NSInteger errorCode = isDir ? BMYErrorIllegalFileType : BMYErrorFileNotFound;
        NSError *error = [NSError errorWithDomain:BMYErrorDomain code:errorCode userInfo:userInfo];
        NSString *errorMsg = isDir ? NSLocalizedString(@"Unable to upload folders", @"不能上传文件夹"):NSLocalizedString(@"File does not exist", @"文件不存在");
        BMYLogWarning(@"BanMaYunSDK: %@ (%@)", errorMsg, sourcePath);
        if ([delegate respondsToSelector:@selector(restClient:putFileFailedWithError:)]) {
            [delegate restClient:self putFileFailedWithError:error];
        }
        return;
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/p/%@", rootId, path];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   [NSNumber numberWithLong:modifiedAtMillis], @"modified_at_millis",
                                   nil];
    if (usingOverwrite) {
        if (overwrite) {
            [params setObject:@"true" forKey:@"overwrite"];
        }else{
            [params setObject:@"false" forKey:@"overwrite"];
        }
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"PUT";
    NSString *contentLength = [NSString stringWithFormat:@"%qu", [fileAttrs fileSize]];
    [urlRequest addValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:sourcePath]];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidPutFile:)];
    request.uploadProgressSelector = @selector(requestPutFileProgress:);
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                        sourcePath, BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY,
                        rootId, BANMAYUN_ROOT_ID_KEY,
                        path, BANMAYUN_FILE_DESTINATION_PATH_KEY,
                        nil];
    request.sourcePath = sourcePath;
    [uploadRequests setObject:request forKey:[self putFileByPathKeyWithRootId:rootId path:path]];
}

- (void)requestPutFileProgress:(BMYRequest *)request
{
    NSString *sourcePath = [(NSDictionary *)request.userInfo objectForKey:BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY];
    NSString *destPath = [request.userInfo objectForKey:BANMAYUN_FILE_DESTINATION_PATH_KEY];
    NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
    if ([delegate respondsToSelector:@selector(restClient:putFileProgress:forRootId:path:fromPath:)])
    {
        [delegate restClient:self putFileProgress:request.uploadProgress forRootId:rootId path:destPath fromPath:sourcePath];
    }
}

- (void)requestDidPutFile:(BMYRequest *)request
{
    NSDictionary *result = [request parseResponseAsType:[NSDictionary class]];
    if (!result) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:putFileFailedWithError:)]) {
            [delegate restClient:self putFileFailedWithError:request.error];
        }
    }else{
        BMYMetadata *metadata = [[BMYMetadata alloc] initWithDictionary:result];
        NSString *sourcePath = [request.userInfo objectForKey:BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY];
        NSString *destPath = [request.userInfo objectForKey:BANMAYUN_FILE_DESTINATION_PATH_KEY];
        NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
        
        if ([delegate respondsToSelector:@selector(restClient:donePutFileByPathWithRootId:path:fromPath:metadata:)]) {
            [delegate restClient:self donePutFileByPathWithRootId:rootId path:destPath fromPath:sourcePath metadata:metadata];
        }
    }
    [uploadRequests removeObjectForKey:[self putFileByPathKeyWithRootId:[request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY] path:[request.userInfo objectForKey:BANMAYUN_FILE_DESTINATION_PATH_KEY]]];
}

- (void)cancelFilePutWithRootId:(NSString *)rootId path:(NSString *)path
{
    BMYRequest *request = [uploadRequests objectForKey:[self putFileByPathKeyWithRootId:rootId path:path]];
    if (request) {
        [request cancel];
        [uploadRequests removeObjectForKey:[self putFileByPathKeyWithRootId:rootId path:path]];
    }
}


#pragma mark -
#pragma mark - Get File by Path

- (void)getFileByPathWithRootId:(NSString *)rootId path:(NSString *)path usingVersion:(BOOL)usingVersion version:(long)version usingOffset:(BOOL)usingOffset offset:(long)offset usingBytes:(BOOL)usingBytes bytes:(long)bytes toPath:(NSString *)toPath
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/p/%@", rootId, path];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingVersion) {
        [params setObject:[NSNumber numberWithLong:version] forKey:@"version"];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    }
    if (usingBytes) {
        [params setObject:[NSNumber numberWithLong:bytes] forKey:@"bytes"];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetFileByPath:)];
    request.resultFilename = toPath;
    request.downloadProgressSelector = @selector(requestGetFileByPathProgress:);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        path, @"path",
                        toPath, @"toPath",
                        nil];
    if (usingVersion) {
        [userInfo setObject:[NSNumber numberWithLong:version] forKey:@"version"];
    }
    request.userInfo = userInfo;
    [loadRequests setObject:request forKey:path];
}


- (void)getFileBypathWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath
{
    [self getFileByPathWithRootId:rootId path:path usingVersion:NO version:0 usingOffset:NO offset:0 usingBytes:NO bytes:0 toPath:toPath];
}


- (void)requestGetFileByPathProgress:(BMYRequest *)request
{
    if ([delegate respondsToSelector:@selector(restClient:getFileByPathProgress:forFile:)]) {
        [delegate restClient:self getFileByPathProgress:request.downloadProgress forFile:request.resultFilename];
    }
}


- (void)restClient:(BMYRestClient *)restClient gotFileByPathToPath:(NSString *)toPath contentType:(NSString *)contentType eTag:(NSString *)eTag
{
    // Empty selector to get the signature from
}


- (void)requestDidGetFileByPath:(BMYRequest *)request
{
    NSString *path = [request.userInfo objectForKey:@"path"];
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileByPathFailedWithError:)])
        {
            [delegate restClient:self getFileByPathFailedWithError:request.error];
        }
    }else{
        NSString *filename = request.resultFilename;
        NSDictionary *headers = [request.response allHeaderFields];
        NSString *contentType = [headers objectForKey:@"Content-Type"];
        NSDictionary *metadataDict = [request xBanmayunMetadataJSON];
        NSString *eTag = [headers objectForKey:@"Etag"];
        if ([delegate respondsToSelector:@selector(restClient:gotFileByPathToPath:)]) {
            [delegate restClient:self gotFileByPathToPath:filename];
        }else if ([delegate respondsToSelector:@selector(restClient:gotFileByPathToPath:contentType:metadata:)]){
            BMYMetadata *metadata = [[BMYMetadata alloc] initWithDictionary:metadataDict];
            [delegate restClient:self gotFileByPathToPath:filename contentType:contentType metadata:metadata];
        }else if ([delegate respondsToSelector:@selector(restClient:gotFileByPathToPath:contentType:eTag:)]){
            NSMethodSignature *sig = [self methodSignatureForSelector:@selector(restClient:gotFileByPathToPath:contentType:eTag:)];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:self];
            [inv setSelector:@selector(restClient:gotFileByPathToPath:contentType:eTag:)];
            [inv setArgument:(void *)&self atIndex:2];
            [inv setArgument:&filename atIndex:3];
            [inv setArgument:&contentType atIndex:4];
            [inv setArgument:&eTag atIndex:5];
            [inv retainArguments];
            [inv invoke];
        }
    }
    [loadRequests removeObjectForKey:path];
}


- (void)cancelFileGet:(NSString *)path
{
    BMYRequest *outstandingRequest = [loadRequests objectForKey:path];
    if (outstandingRequest) {
        [outstandingRequest cancel];
        [loadRequests removeObjectForKey:path];
    }
}


#pragma mark -
#pragma mark - Trash File by Path

- (void)trashFileByPathWithRootId:(NSString *)rootId path:(NSString *)path
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/p/%@", rootId, path];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidTrashFileByPath:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     path, @"path",
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidTrashFileByPath:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:trashFileByPathFailedWithError:)]) {
            [delegate restClient:self trashFileByPathFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseTrashFileMetaWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


-(void)parseTrashFileMetaWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseTrashFileMetadata:) failSelector:@selector(parseTrashFileMetadataFailedForRequest:)];
}


- (void)didParseTrashFileMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:trashedFileByPath:)]) {
        [delegate restClient:self trashedFileByPath:metadata];
    }
}

- (void)parseTrashFileMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata ");
    if ([delegate respondsToSelector:@selector(restClient:trashFileByPathFailedWithError:)]) {
        [delegate restClient:self trashFileByPathFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Upload File by Id

- (NSString *)uploadFileByIdKeyWithRootId:(NSString *)rootId metaId:(NSString *)metaId
{
    return [NSString stringWithFormat:@"%@#%@", rootId, metaId];
}

- (void)uploadFileByIdWithRootId:(NSString *)rootId metaId:(NSString *)metaId modifiedAtMillis:(long)modifiedAtMillis fromPath:(NSString *)sourcePath
{
    if (!rootId || !metaId) {
        return;
    }
    BOOL isDir = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&isDir];
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:sourcePath error:nil];
    if (!fileExists || isDir || !fileAttrs) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         sourcePath, BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY,
                                         rootId, BANMAYUN_ROOT_ID_KEY,
                                         metaId, @"meta_id",
                                         nil];
        NSInteger errorCode = isDir ? BMYErrorIllegalFileType : BMYErrorFileNotFound;
        NSError *error = [NSError errorWithDomain:BMYErrorDomain code:errorCode userInfo:userInfo];
        NSString *errorMsg = isDir ? NSLocalizedString(@"Unable to upload folders", @"不能上传文件夹"):NSLocalizedString(@"File does not exist", @"文件不存在");
        BMYLogWarning(@"BanMaYunSDK: %@ (%@)", errorMsg, sourcePath);
        if ([delegate respondsToSelector:@selector(restClient:uploadFileByIdFailedWithError:)]) {
            [delegate restClient:self uploadFileByIdFailedWithError:error];
        }
        return;
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@", rootId, metaId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   modifiedAtMillis ? [NSNumber numberWithLong:modifiedAtMillis]:[NSNumber numberWithLong:0], @"modified_at_millis",
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    
    NSString *contentLength = [NSString stringWithFormat:@"%qu", [fileAttrs fileSize]];
    [urlRequest addValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:sourcePath]];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUploadFileById:)];
    request.uploadProgressSelector = @selector(requestUploadFileByIdProgress:);
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                        sourcePath, BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY,
                        rootId, BANMAYUN_ROOT_ID_KEY,
                        metaId, @"meta_id",
                        nil];
    request.sourcePath = sourcePath;
    [uploadRequests setObject:request forKey:[self uploadFileByIdKeyWithRootId:rootId metaId:metaId]];
}


- (void)requestUploadFileByIdProgress:(BMYRequest *)request
{
    NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
    NSString *metaId = [request.userInfo objectForKey:@"meta_id"];
    NSString *sourcePath = [request.userInfo objectForKey:BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY];
    if ([delegate respondsToSelector:@selector(restClient:uploadFileByIdProgress:forRootId:metaId:fromPath:)]) {
        [delegate restClient:self uploadFileByIdProgress:request.uploadProgress forRootId:rootId metaId:metaId fromPath:sourcePath];
    }
}


- (void)requestDidUploadFileById:(BMYRequest *)request
{
    NSDictionary *result = [request parseResponseAsType:[NSDictionary class]];
    if (!result) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:uploadFileByIdFailedWithError:)]) {
            [delegate restClient:self uploadFileByIdFailedWithError:request.error];
        }
    }else{
        BMYMetadata *metadata = [[BMYMetadata alloc] initWithDictionary:result];
        NSString *sourcePath = [request.userInfo objectForKey:BANMAYUN_FILE_UPLOAD_SOURCE_PATH_KEY];
        NSString *metaId = [request.userInfo objectForKey:@"meta_id"];
        NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
        if ([delegate respondsToSelector:@selector(restClient:uploadedFileByIdForRootId:metaId:fromPath:metadata:)]) {
            [delegate restClient:self uploadedFileByIdForRootId:rootId metaId:metaId fromPath:sourcePath metadata:metadata];
        }
    }
    [uploadRequests removeObjectForKey:[self uploadFileByIdKeyWithRootId:[request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY] metaId:[request.userInfo objectForKey:@"meta_id"]]];
}


- (void)cancelFileUploadByIdWithRootId:(NSString *)rootId metaId:(NSString *)metaId
{
    BMYRequest *request = [uploadRequests objectForKey:[self uploadFileByIdKeyWithRootId:rootId metaId:metaId]];
    if (request) {
        [request cancel];
        [uploadRequests removeObjectForKey:[self uploadFileByIdKeyWithRootId:rootId metaId:metaId]];
    }
}


#pragma mark -
#pragma mark - Get File by Id

- (NSString *)getFileByIdKeyWithRootId:(NSString *)rootId metaId:(NSString *)metaId
{
    return [NSString stringWithFormat:@"%@#%@", rootId, metaId];
}

- (void)getFileByIdWithRootId:(NSString *)rootId metaId:(NSString *)metaId usingVersion:(BOOL)usingVersion version:(long)version usingOffset:(BOOL)usingOffset offset:(long)offset usingBytes:(BOOL)usingBytes bytes:(long)bytes toPath:(NSString *)toPath
{
    if (!rootId || !metaId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@", rootId, metaId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingVersion) {
        [params setObject:[NSNumber numberWithLong:version] forKey:@"version"];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    }
    if (usingBytes) {
        [params setObject:[NSNumber numberWithLong:bytes] forKey:@"bytes"];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetFileById:)];
    request.resultFilename = toPath;
    request.downloadProgressSelector = @selector(requestGetFileByIdProgress:);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, @"meta_id",
                                     toPath, @"toPath",
                                     nil];
    if (usingVersion) {
        [userInfo setObject:[NSNumber numberWithLong:version] forKey:@"version"];
    }
    request.userInfo = userInfo;
    [loadRequests setObject:request forKey:[self getFileByIdKeyWithRootId:rootId metaId:metaId]];
}


- (void)getFileByIdWithRootId:(NSString *)rootId metaId:(NSString *)metaId toPath:(NSString *)toPath
{
    [self getFileByIdWithRootId:rootId metaId:metaId usingVersion:NO version:0 usingOffset:NO offset:0 usingBytes:NO bytes:0 toPath:toPath];
}

- (void)requestGetFileByIdProgress:(BMYRequest *)request
{
    if ([delegate respondsToSelector:@selector(restClient:getFileByIdProgress:forFile:)]) {
        [delegate restClient:self getFileByPathProgress:request.downloadProgress forFile:request.resultFilename];
    }
}

- (void)restClient:(BMYRestClient *)restClient gotFileByIdToPath:(NSString *)toPath contentType:(NSString *)contentType eTag:(NSString *)eTag
{
    // Empty selector to get the signature from
}

- (void)requestDidGetFileById:(BMYRequest *)request
{
    NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
    NSString *metaId = [request.userInfo objectForKey:@"meta_id"];
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileByIdFailedWithError:)])
        {
            [delegate restClient:self getFileByIdFailedWithError:request.error];
        }
    }else{
        NSString *filename = request.resultFilename;
        NSDictionary *headers = [request.response allHeaderFields];
        NSString *contentType = [headers objectForKey:@"Content-Type"];
        NSDictionary *metadataDict = [request xBanmayunMetadataJSON];
        NSString *eTag = [headers objectForKey:@"Etag"];
        if ([delegate respondsToSelector:@selector(restClient:gotFileByIdToPath:)]) {
            [delegate restClient:self gotFileByIdToPath:filename];
        }else if ([delegate respondsToSelector:@selector(restClient:gotFileByIdToPath:contentType:metadata:)]){
            BMYMetadata *metadata = [[BMYMetadata alloc] initWithDictionary:metadataDict];
            [delegate restClient:self gotFileByIdToPath:filename contentType:contentType metadata:metadata];
        }else if ([delegate respondsToSelector:@selector(restClient:gotFileByIdToPath:contentType:eTag:)]){
            NSMethodSignature *sig = [self methodSignatureForSelector:@selector(restClient:gotFileByIdToPath:contentType:eTag:)];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:self];
            [inv setSelector:@selector(restClient:gotFileByPathToPath:contentType:eTag:)];
            [inv setArgument:(void *)&self atIndex:2];
            [inv setArgument:&filename atIndex:3];
            [inv setArgument:&contentType atIndex:4];
            [inv setArgument:&eTag atIndex:5];
            [inv retainArguments];
            [inv invoke];
        }
    }
    [loadRequests removeObjectForKey:[self getFileByIdKeyWithRootId:rootId metaId:metaId]];
}


#pragma mark -
#pragma mark - Trash File by Id

- (void)trashFileByPathWithRootId:(NSString *)rootId metaId:(NSString *)metaId
{
    if (!rootId || !metaId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@", rootId, metaId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidTrashFileById:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, @"meta_id",
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidTrashFileById:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:trashFileByIdFailedWithError:)]) {
            [delegate restClient:self trashFileByIdFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseTrashFileByIdMetaWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


-(void)parseTrashFileByIdMetaWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseTrashFileByIdMetadata:) failSelector:@selector(parseTrashFileByIdMetadataFailedForRequest:)];
}


- (void)didParseTrashFileByIdMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:trashedFileById:)]) {
        [delegate restClient:self trashedFileById:metadata];
    }
}

- (void)parseTrashFileByIdMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata ");
    if ([delegate respondsToSelector:@selector(restClient:trashFileByIdFailedWithError:)]) {
        [delegate restClient:self trashFileByIdFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Get File Meta

- (void)getFileMetaWithRootId:(NSString *)rootId metaId:(NSString *)metaId
{
    if (!rootId || !metaId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/meta", rootId, metaId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetFileMeta:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, @"meta_id",
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetFileMeta:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileMetaFailedWithError:)]) {
            [delegate restClient:self getFileMetaFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetFileMetaWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseGetFileMetaWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseGetFileMeta:) failSelector:@selector(parseGetFileMetaFailedForRequest:)];
}

- (void)didParseGetFileMeta:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:gotFileMeta:)]) {
        [delegate restClient:self gotFileMeta:metadata];
    }
}

- (void)parseGetFileMetaFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata ");
    if ([delegate respondsToSelector:@selector(restClient:getFileMetaFailedWithError:)]) {
        [delegate restClient:self getFileMetaFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Get File Thumbnail

- (NSString *)thumbnailKeyForRootId:(NSString *)rootId metaId:(NSString *)metaId format:(NSString *)format size:(NSString *)size
{
    NSMutableString *tmpStr = [NSMutableString string];
    [tmpStr appendString:rootId];
    [tmpStr appendFormat:@"#%@", metaId];
    if (format) {
        [tmpStr appendFormat:@"#%@", format];
    }
    if (size) {
        [tmpStr appendFormat:@"#%@", size];
    }
    return tmpStr;
}

- (void)getFileThumbnailWithRootId:(NSString *)rootId metaId:(NSString *)metaId format:(NSString *)format size:(NSString *)size toPath:(NSString *)toPath
{
    if (!rootId || !metaId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/thumbnail", rootId, metaId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (format) {
        [params setObject:format forKey:@"format"];
    }
    if (size) {
        [params setObject:size forKey:@"size"];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetFileThumbnail:)];
    request.resultFilename = toPath;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, @"meta_id",
                                     nil];
    if (format) {
        [userInfo setObject:format forKey:@"format"];
    }
    if (size) {
        [userInfo setObject:size forKey:@"size"];
    }
    [imageLoadRequests setObject:request forKey:[self thumbnailKeyForRootId:rootId metaId:metaId format:format size:size]];
}


- (void)requestDidGetFileThumbnail:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileThumbnailFailedWithError:)]) {
            [delegate restClient:self getFileThumbnailFailedWithError:request.error];
        }
    }else{
        NSString *filename = request.resultFilename;
        NSDictionary *metadataDict = [request xBanmayunMetadataJSON];
        BMYMetadata *resultMetadata = [[BMYMetadata alloc] initWithDictionary:metadataDict];
        if ([delegate respondsToSelector:@selector(restClient:gotFileThumbnail:metadata:)]) {
            [delegate restClient:self gotFileThumbnail:filename metadata:resultMetadata];
        }
    }
    NSString *rootId = [request.userInfo objectForKey:BANMAYUN_ROOT_ID_KEY];
    NSString *metaId = [request.userInfo objectForKey:@"meta_id"];
    NSString *format = [request.userInfo objectForKey:@"format"];
    NSString *size = [request.userInfo objectForKey:@"size"];
    
    [imageLoadRequests removeObjectForKey:[self thumbnailKeyForRootId:rootId metaId:metaId format:format size:size]];
}


- (void)cancelGetFileThumbnailWithRootId:(NSString *)rootId metaId:(NSString *)metaId format:(NSString *)format size:(NSString *)size
{
    NSString *key = [self thumbnailKeyForRootId:rootId metaId:metaId format:format size:size];
    BMYRequest *request = [imageLoadRequests objectForKey:key];
    if (request) {
        [request cancel];
        [imageLoadRequests removeObjectForKey:key];
    }
}


#pragma mark -
#pragma mark - List File Revisions

- (void)listFileRevisionsWithRootId:(NSString *)rootId metaId:(NSString *)metaId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/revisions", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListFileRevisions:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidListFileRevisions:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listFileRevisionsFailedWithError:)]) {
            [delegate restClient:self listFileRevisionsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListFileRevisionsResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListFileRevisionsResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYRevision class] resultThread:thread succSelector:@selector(didParseListFileRevisionsResultList:) failSelector:@selector(parseListFileRevisionsResultListFailedForRequest:)];
}


- (void)didParseListFileRevisionsResultList:(BMYResultList *)fileRevisionsList
{
    if ([delegate respondsToSelector:@selector(restClient:listedFileRevisions:)]) {
        [delegate restClient:self listedFileRevisions:fileRevisionsList];
    }
}


- (void)parseListFileRevisionsResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:listFileRevisionsFailedWithError:)]) {
        [delegate restClient:self listFileRevisionsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Commit Chunked Upload

- (void)commitChunkedUploadWithRootId:(NSString *)rootId path:(NSString *)path uploadId:(NSString *)uploadId modifiedAtMillis:(long)modifiedAtMillis
{
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/commit_chunked_upload"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   uploadId, @"upload_id",
                                   [NSNumber numberWithLong:modifiedAtMillis], @"modified_at_millis",
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCommitChunkedUpload:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidCommitChunkedUpload:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:commitChunkedUploadFailedWithError:)]) {
            [delegate restClient:self commitChunkedUploadFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCommitChunkedUploadMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}

- (void)parseCommitChunkedUploadMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseCommitChunkedUploadMetadata:) failSelector:@selector(parseCommitChunkedUploadMetadataFailedForRequest:)];
}

- (void)didParseCommitChunkedUploadMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:commitedChunkedUpload:)]) {
        [delegate restClient:self commitedChunkedUpload:metadata];
    }
}


- (void)parseCommitChunkedUploadMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:commitChunkedUploadFailedWithError:)]) {
        [delegate restClient:self commitChunkedUploadFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Copy

- (void)copyFileWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath
{
    if (!rootId ||!path || !toPath) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/copy"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   toPath, @"to_path",
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCopyFile:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidCopyFile:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:copyFileFailedWithError:)]) {
            [delegate restClient:self copyFileFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCopyFileMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseCopyFileMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseCopyFileMetadata:) failSelector:@selector(parseCopyFileMetadataFailedForRequest:)];
}

- (void)didParseCopyFileMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:copiedFile:)]) {
        [delegate restClient:self copiedFile:metadata];
    }
}


- (void)parseCopyFileMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:copyFileFailedWithError:)]) {
        [delegate restClient:self copyFileFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Create Folder

- (void)createFolderWithRootId:(NSString *)rootId path:(NSString *)path modifiedAtMillis:(long)modifiedAtMillis
{
    if (!rootId ||!path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/create_folder"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   [NSNumber numberWithLong:modifiedAtMillis], @"modified_at_millis",
                                   nil];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCreateFolder:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidCreateFolder:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createFolderFailedWithError:)]) {
            [delegate restClient:self createFolderFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCreateFolderMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}

- (void)parseCreateFolderMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseCreateFolderMetadata:) failSelector:@selector(parseCreateFolderMetadataFailedForRequest:)];
}


- (void)didParseCreateFolderMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:createdFolder:)]) {
        [delegate restClient:self createdFolder:metadata];
    }
}


- (void)parseCreateFolderMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:createFolderFailedWithError:)]) {
        [delegate restClient:self createFolderFailedWithError:error];
    }
}

#pragma mark -
#pragma mark - Fileops Get Meta
- (void)getMetaOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path list:(BOOL)list
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/get_meta"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   nil];
    if (list) {
        [params setObject:@"true" forKey:@"list"];
    }else{
        [params setObject:@"false" forKey:@"list"];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetMetaOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetMetaOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getMetaOfFileOpsFailedWithError:)]) {
            [delegate restClient:self getMetaOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetMetaOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}

- (void)parseGetMetaOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseGetMetaOfFileOpsMetadata:) failSelector:@selector(parseGetMetaOfFileOpsMetadataFailedForRequest:)];
}

- (void)didParseGetMetaOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:gotMetaOfFileOps:)]) {
        [delegate restClient:self gotMetaOfFileOps:metadata];
    }
}


- (void)parseGetMetaOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:getMetaOfFileOpsFailedWithError:)]) {
        [delegate restClient:self getMetaOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops List Folder

- (void)listFolderOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/list_folder"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   nil];

    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListFolderOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidListFolderOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listFolderOfFileOpsFailedWithError:)]) {
            [delegate restClient:self listFolderOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListFolderOfFileOpsMetadataListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListFolderOfFileOpsMetadataListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    NSArray *resultArray = [request parseResponseAsType:[NSArray class]];
    if (resultArray) {
        [self performSelector:@selector(didParseListFolderOfFileOpsMetadataList:) onThread:thread withObject:resultArray waitUntilDone:NO];
    }else{
        [self performSelector:@selector(parseListFolderOfFileOpsMetadataFailedForRequest:) onThread:thread withObject:resultArray waitUntilDone:NO];
    }
}


- (void)didParseListFolderOfFileOpsMetadataList:(NSArray *)metadataList
{
    if ([delegate respondsToSelector:@selector(restClient:listedFolderOfFileOps:)]) {
        [delegate restClient:self listedFolderOfFileOps:metadataList];
    }
}


- (void)parseListFolderOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:listFolderOfFileOpsFailedWithError:)]) {
        [delegate restClient:self listFolderOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Move

- (void)moveOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath
{
    if (!rootId || !path || !toPath) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/move"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   toPath, @"to_path",
                                   nil];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidMoveOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidMoveOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:moveOfFileOpsFailedWithError:)]) {
            [delegate restClient:self moveOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseMoveOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseMoveOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseMoveOfFileOpsMetadata:) failSelector:@selector(parseMoveOfFileOpsMetadataFailedForRequest:)];
}

- (void)didParseMoveOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:movedOfFileOps:)]) {
        [delegate restClient:self movedOfFileOps:metadata];
    }
}


- (void)parseMoveOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:moveOfFileOpsFailedWithError:)]) {
        [delegate restClient:self moveOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Rollback

- (void)rollbackOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path toVersion:(long)toVersion
{
    if (!rootId || !path) {
        return;
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/rollback"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                  [NSNumber numberWithLong:toVersion], @"to_version",
                                   nil];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidRollbackOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidRollbackOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:rollbackOfFileOpsFailedWithError:)]) {
            [delegate restClient:self rollbackOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseRollbackOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseRollbackOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseRollbackOfFileOpsMetadata:) failSelector:@selector(parseRollbackOfFileOpsMetadataFailedForRequest:)];
}

- (void)didParseRollbackOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:rollbackedOfFileOps:)]) {
        [delegate restClient:self rollbackedOfFileOps:metadata];
    }
}


- (void)parseRollbackOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:rollbackOfFileOpsFailedWithError:)]) {
        [delegate restClient:self rollbackOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Thunder Upload
- (void)thunderUploadOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path md5:(NSString *)md5 bytes:(long)bytes modifiedAtMillis:(long)modifiedAtMillis
{
    if (!rootId || !path || !md5) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/thunder_upload"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   md5, @"md5",
                                   [NSNumber numberWithLong:bytes], @"bytes",
                                   [NSNumber numberWithLong:modifiedAtMillis], @"modified_at_millis",
                                   nil];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidThunderUpdateOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidThunderUpdateOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:thunderUploadOfFileOpsFailedWithError:)]) {
            [delegate restClient:self thunderUploadOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseThunderUploadOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseThunderUploadOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseThunderUploadOfFileOpsMetadata:) failSelector:@selector(parseThunderUploadOfFileOpsMetadataFailedForRequest:)];
}

- (void)didParseThunderUploadOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:thunderUploadedOfFileOps:)]) {
        [delegate restClient:self thunderUploadedOfFileOps:metadata];
    }
}


- (void)parseThunderUploadOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:thunderUploadOfFileOpsFailedWithError:)]) {
        [delegate restClient:self thunderUploadOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Utime Folder
- (void)utimeFolderOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path modifiedAtMillis:(long)modifiedAtMillis
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/utime_folder"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   [NSNumber numberWithLong:modifiedAtMillis], @"modified_at_millis",
                                   nil];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidUtimeFolderOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidUtimeFolderOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:utimeFolderOfFileOpsFailedWithError:)]) {
            [delegate restClient:self utimeFolderOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseUtimeFolderOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseUtimeFolderOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseUtimeFolderOfFileOpsMetadata:) failSelector:@selector(parseUtimeFolderOfFileOpsMetadataFailedForRequest:)];
}

- (void)didParseUtimeFolderOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:utimedFolderOfFileOps:)]) {
        [delegate restClient:self utimedFolderOfFileOps:metadata];
    }
}


- (void)parseUtimeFolderOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:utimeFolderOfFileOpsFailedWithError:)]) {
        [delegate restClient:self utimeFolderOfFileOpsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Fileops Set Permission
- (void)setPermissionOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path insertableToOwner:(BOOL)insertableOwner readableToOwner:(BOOL)readableOwner writableToOwner:(BOOL)writableOwner deletableToOwner:(BOOL)deletableOwner insertableToOthers:(BOOL)insertableOthers readableToOthers:(BOOL)readableOthers writableToOthers:(BOOL)writableOthers deletableToOthers:(BOOL)deletableOthers
{
    if (!rootId || !path) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/set_permission"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   path, @"path",
                                   nil];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (insertableOwner) {
        [bodyDict setObject:@"true" forKey:@"insertable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"insertable_to_owner"];
    }
    
    if (readableOwner) {
        [bodyDict setObject:@"true" forKey:@"readable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"readable_to_owner"];
    }
    
    if (writableOwner) {
        [bodyDict setObject:@"true" forKey:@"writable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"writable_to_owner"];
    }
    
    if (deletableOwner) {
        [bodyDict setObject:@"true" forKey:@"deletable_to_owner"];
    }else{
        [bodyDict setObject:@"false" forKey:@"deletable_to_owner"];
    }
    
    if (insertableOthers) {
        [bodyDict setObject:@"true" forKey:@"insertable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"insertable_to_others"];
    }
    if (readableOthers) {
        [bodyDict setObject:@"true" forKey:@"readable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"readable_to_others"];
    }
    
    if (writableOthers) {
        [bodyDict setObject:@"true" forKey:@"writable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"writable_to_others"];
    }
    
    if (deletableOthers) {
        [bodyDict setObject:@"true" forKey:@"deletable_to_others"];
    }else{
        [bodyDict setObject:@"false" forKey:@"deletable_to_others"];
    }
    NSString *bodyStr = [bodyDict JSONRepresentation];
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = bodyData;
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSetPermissionOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}

- (void)requestDidSetPermissionOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:setPermissionOfFileOpsFailedWithError:)]) {
            [delegate restClient:self setPermissionOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSetPermissionOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}

- (void)parseSetPermissionOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseSetPermissionOfFileOpsMetadata:) failSelector:@selector(parseSetPermissionrOfFileOpsMetadataFailedForRequest:)];
}


- (void)didParseSetPermissionOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:doneSetPermissionOfFileOps:)]) {
        [delegate restClient:self doneSetPermissionOfFileOps:metadata];
    }
}


- (void)parseSetPermissionrOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:setPermissionOfFileOpsFailedWithError:)]) {
        [delegate restClient:self setPermissionOfFileOpsFailedWithError:error];
    }
}

#pragma mark -
#pragma mark - Fileops List Permissions

- (void)listPermissionsOfFileOpsWithRootId:(NSString *)rootId
{
    if (!rootId) {
        return;
    }
    NSString *fullPath = [NSString stringWithFormat:@"/fileops/list_permissions"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   rootId, BANMAYUN_ROOT_ID_KEY,
                                   nil];
    
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListPermissionsOfFileOps:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidListPermissionsOfFileOps:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listPermissionsOfFileOpsFailedWithError:)]) {
            [delegate restClient:self listPermissionsOfFileOpsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListPermissionsOfFileOpsMetadataWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListPermissionsOfFileOpsMetadataWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseMetadataObject:request resultThread:thread succSelector:@selector(didParseListPermissionsOfFileOpsMetadata:) failSelector:@selector(parseListPermissionsOfFileOpsMetadataFailedForRequest:)];
}


- (void)didParseListPermissionsOfFileOpsMetadata:(BMYMetadata *)metadata
{
    if ([delegate respondsToSelector:@selector(restClient:listedPermissionsOfFileOps:)]) {
        [delegate restClient:self listedPermissionsOfFileOps:metadata];
    }
}

- (void)parseListPermissionsOfFileOpsMetadataFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing metadata");
    if ([delegate respondsToSelector:@selector(restClient:listPermissionsOfFileOpsFailedWithError:)]) {
        [delegate restClient:self listPermissionsOfFileOpsFailedWithError:error];
    }
}


#pragma mark - 
#pragma mark - Chunked Upload

- (void)chunkedUploadWithUploadId:(NSString *)uploadId usingOffset:(BOOL)usingOffset offset:(long)offset fromPath:(NSString *)localPath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:localPath];
	if (!file) {
		if ([delegate respondsToSelector:@selector(restClient:chunkedUploadFailedWithError:)]) {
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  localPath, @"fromPath",
                                      nil];
            if (usingOffset) {
                [userInfo setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
            }
            if (uploadId) {
                [userInfo setObject:uploadId forKey:@"upload_id"];
            }
			NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorFileNotFound userInfo:userInfo];
			[delegate restClient:self chunkedUploadFailedWithError:error];
		} else {
			BMYLogWarning(@"BanMaYunSDK: unable to read file in -[BMYRestClient chunkedUploadWithUploadId:usingOffset:offset:fromPath:] (fromPath=%@)", localPath);
		}
		return;
	}
	[file seekToFileOffset:offset];
	NSData *data = [file readDataOfLength:1024*1024];
    
	if (![data length]) {
		BMYLogWarning(@"BanMaYunSDK: did not read any data from file (fromPath=%@)", localPath);
	}
    
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    }
    if (uploadId) {
        [params setObject:uploadId forKey:@"upload_id"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/chunked_upload"];

	NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    
	NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
	[urlRequest addValue:contentLength forHTTPHeaderField:@"Content-Length"];
	[urlRequest addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setHTTPBody:data];
    
	BMYRequest *request =
    [[BMYRequest alloc]
      initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidChunkedUpload:)];
	request.uploadProgressSelector = @selector(requestChunkedUploadProgress:);
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							  localPath, @"fromPath",
							  nil];
    if (usingOffset) {
        [userInfo setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];
    }
    if (uploadId) {
        [userInfo setObject:uploadId forKey:@"upload_id"];
    }
	request.userInfo = userInfo;
	request.sourcePath = localPath;
	[requests addObject:request];
}

- (void)requestChunkedUploadProgress:(BMYRequest*)request {
	NSString *uploadId = [request.userInfo objectForKey:@"upload_id"];
    long offset = [[request.userInfo objectForKey:@"offset"] longValue];
	NSString *fromPath = [request.userInfo objectForKey:@"fromPath"];
    
    if ([delegate respondsToSelector:@selector(restClient:chunkedUploadProgress:forFile:offset:fromPath:)]) {
		[delegate restClient:self chunkedUploadProgress:request.uploadProgress
                     forFile:uploadId offset:offset fromPath:fromPath];
    }
}


- (void)requestDidChunkedUpload:(BMYRequest *)request
{
    NSDictionary *resp = [request parseResponseAsType:[NSDictionary class]];
	if (!resp) {
		if ([delegate respondsToSelector:@selector(restClient:chunkedUploadFailedWithError:)]) {
			[delegate restClient:self chunkedUploadFailedWithError:request.error];
		}
	} else {
		NSString *uploadId = [resp objectForKey:@"upload_id"];
		long newOffset = [[resp objectForKey:@"offset"] longValue];
		NSString *localPath = [request.userInfo objectForKey:@"fromPath"];
		if ([delegate respondsToSelector:@selector(restClient:chunkedUpload:newOffset:fromFile:)]) {
			[delegate restClient:self chunkedUpload:uploadId newOffset:newOffset fromFile:localPath];
		}
	}
	[requests removeObject:request];
}


#pragma mark -
#pragma mark - Create Comment

- (void)createComment:(NSString *)rootId metaId:(NSString *)metaId contents:(NSString *)contents
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/comments", rootId, metaId];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (contents) {
        [bodyDict setObject:contents forKey:@"contents"];
    }else{
        [bodyDict setObject:@"" forKey:@"contents"];
    }
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    urlRequest.HTTPBody = [[bodyDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCreateComment:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     contents?contents:@"", @"contents",
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidCreateComment:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createCommentFailedWithError:)]) {
            [delegate restClient:self createCommentFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCreateCommentWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseCreateCommentWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseCommentObject:request resultThread:thread succSelector:@selector(didParseCreateComment:) failSelector:@selector(parseCreateCommentFailedForRequest:)];
}


- (void)didParseCreateComment:(BMYComment *)comment
{
    if ([delegate respondsToSelector:@selector(restClient:createdComment:)]) {
        [delegate restClient:self createdComment:comment];
    }
}


- (void)parseCreateCommentFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing comment");
    if ([delegate respondsToSelector:@selector(restClient:createCommentFailedWithError:)]) {
        [delegate restClient:self createCommentFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Get Comment

- (void)getComment:(NSString *)rootId metaId:(NSString *)metaId commentId:(NSString *)commentId
{
    if (!rootId || !metaId || !commentId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/comments/%@", rootId, metaId, commentId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetComment:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     commentId, BANMAYUN_COMMENT_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetComment:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getCommentFailedWithError:)]) {
            [delegate restClient:self getCommentFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetCommentWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseGetCommentWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseCommentObject:request resultThread:thread succSelector:@selector(didParseGetComment:) failSelector:@selector(parseGetCommentFailedForRequest:)];
}


- (void)didParseGetComment:(BMYComment *)comment
{
    if ([delegate respondsToSelector:@selector(restClient:gotComment:)]) {
        [delegate restClient:self gotComment:comment];
    }
}


- (void)parseGetCommentFailedForRequest:(BMYRequest *)request
{
    NSError *error= [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing comment");
    if ([delegate respondsToSelector:@selector(restClient:getCommentFailedWithError:)]) {
        [delegate restClient:self getCommentFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List Comments

- (void)listComments:(NSString *)rootId metaId:(NSString *)metaId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/comments", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListComments:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listComments:(NSString *)rootId metaId:(NSString *)metaId
{
    [self listComments:rootId metaId:metaId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidListComments:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listCommentsFailedWithError:)]) {
            [delegate restClient:self listCommentsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListCommentsResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListCommentsResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYComment class] resultThread:thread succSelector:@selector(didParseListCommentsResultList:) failSelector:@selector(parseListCommentsResultListFailedForRequest:)];
}


- (void)didParseListCommentsResultList:(BMYResultList *)commentsList
{
    if ([delegate respondsToSelector:@selector(restClient:listedComments:)]) {
        [delegate restClient:self listedComments:commentsList];
    }
}


- (void)parseListCommentsResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:listCommentsFailedWithError:)]) {
        [delegate restClient:self listCommentsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Delete Comment

- (void)deleteComment:(NSString *)rootId metaId:(NSString *)metaId commentId:(NSString *)commentId
{
    if (!rootId || !metaId || !commentId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/comments/%@", rootId, metaId, commentId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteComment:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId,BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     commentId, BANMAYUN_COMMENT_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteComment:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteCommentFailedWithError:)]) {
            [delegate restClient:self deleteCommentFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseDeleteCommentWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseDeleteCommentWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseCommentObject:request resultThread:thread succSelector:@selector(didParseDeleteComment:) failSelector:@selector(parseDeleteCommentFailedForRequest:)];
}

- (void)didParseDeleteComment:(BMYComment *)comment
{
    if ([delegate respondsToSelector:@selector(restClient:deletedComment:)]) {
        [delegate restClient:self deletedComment:comment];
    }
}


- (void)parseDeleteCommentFailedForRequest:(BMYRequest *)request
{
    NSError *err = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing comment");
    if ([delegate respondsToSelector:@selector(restClient:deleteCommentFailedWithError:)]) {
        [delegate restClient:self deleteCommentFailedWithError:err];
    }
}


#pragma mark - 
#pragma mark - Delete All Comments

- (void)deleteAllComments:(NSString *)rootId metaId:(NSString *)metaId
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/comments", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteAllComments:)];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
    
}


- (void)requestDidDeleteAllComments:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteAllCommentsFailedWithError:)]) {
            [delegate restClient:self deleteAllCommentsFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientDeletedAllComments:)]) {
            [delegate restClientDeletedAllComments:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Create Share

- (void)createShare:(NSString *)rootId metaId:(NSString *)metaId password:(NSString *)passwd expiresAt:(long)expiresAt
{
    if (!rootId || !metaId) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (passwd) {
        [params setObject:passwd forKey:@"password"];
    }
    if (expiresAt) {
        [params setObject:[NSNumber numberWithLong:expiresAt] forKey:@"expires_at"];
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/shares", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidCreateShare:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidCreateShare:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createShareFailedWithError:)]) {
            [delegate restClient:self createShareFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseCreateShareWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseCreateShareWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseShareObject:request resultThread:thread succSelector:@selector(didParseCreateShare:) failSelector:@selector(parseCreateShareFailedForRequest:)];
}


- (void)didParseCreateShare:(BMYShare *)share
{
    if ([delegate respondsToSelector:@selector(restClient:createdShare:)]) {
        [delegate restClient:self createdShare:share];
    }
}

- (void)parseCreateShareFailedForRequest:(BMYRequest *)request
{
    NSError *err = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing share");
    if ([delegate respondsToSelector:@selector(restClient:createShareFailedWithError:)]) {
        [delegate restClient:self createShareFailedWithError:err];
    }
}


#pragma mark -
#pragma mark - Get Share

- (void)getShare:(NSString *)rootId metaId:(NSString *)metaId shareId:(NSString *)shareId
{
    if (!rootId || !metaId || !shareId) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/shares/%@", rootId, metaId, shareId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetShare:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     shareId, BANMAYUN_SHARE_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetShare:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getShareFailedWithError:)]) {
            [delegate restClient:self getShareFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetShareWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject: request];
}


- (void)parseGetShareWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseShareObject:request resultThread:thread succSelector:@selector(didParseGetShare:) failSelector:@selector(parseGetShareFailedForRequest:)];
}


- (void)didParseGetShare:(BMYShare *)share
{
    if ([delegate respondsToSelector:@selector(restClient:gotShare:)]) {
        [delegate restClient:self gotShare:share];
    }
}


- (void)parseGetShareFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing share");
    if ([delegate respondsToSelector:@selector(restClient:getShareFailedWithError:)]) {
        [delegate restClient:self getShareFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List Shares

- (void)listShares:(NSString *)rootId metaId:(NSString *)metaId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/shares", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListShares:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listShares:(NSString *)rootId metaId:(NSString *)metaId
{
    [self listShares:rootId metaId:metaId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidListShares:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listSharesFailedWithError:)]) {
            [delegate restClient:self listSharesFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListSharesResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListSharesResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYShare class] resultThread:thread succSelector:@selector(didParseListSharesResultList:) failSelector:@selector(parseListSharesResultListFailedForRequest:)];
}


- (void)didParseListSharesResultList:(BMYResultList *)sharesList
{
    if ([delegate respondsToSelector:@selector(restClient:listedShares:)]) {
        [delegate restClient:self listedShares:sharesList];
    }
}


- (void)parseListSharesResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:listSharesFailedWithError:)]) {
        [delegate restClient:self listSharesFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Delete Share

- (void)deleteShare:(NSString *)rootId metaId:(NSString *)metaId shareId:(NSString *)shareId
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/shares/%@", rootId, metaId, shareId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteShare:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     metaId, BANMAYUN_META_ID_KEY,
                                     shareId, BANMAYUN_SHARE_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteShare:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteShareFailedWithError:)]) {
            [delegate restClient:self deleteShareFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseDeleteShareWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseDeleteShareWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseShareObject:request resultThread:thread succSelector:@selector(didParseDeleteShare:) failSelector:@selector(parseDeleteShareFailedForRequest:)];
}


- (void)didParseDeleteShare:(BMYShare *)share
{
    if ([delegate respondsToSelector:@selector(restClient:deletedShare:)]) {
        [delegate restClient:self deletedShare:share];
    }
}


- (void)parseDeleteShareFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing share");
    if ([delegate respondsToSelector:@selector(restClient:deleteShareFailedWithError:)]) {
        [delegate restClient:self deleteShareFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Delete All Shares

- (void)deleteAllShares:(NSString *)rootId metaId:(NSString *)metaId
{
    if (!rootId || !metaId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/files/%@/shares", rootId, metaId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteAllShares:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      rootId, BANMAYUN_ROOT_ID_KEY,
                                      metaId, BANMAYUN_META_ID_KEY,
                                      [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteAllShares:(BMYRequest *)request
{
    if (request.error) {
        if ([delegate respondsToSelector:@selector(restClient:deleteAllSharesFailedWithError:)]) {
            [delegate restClient:self deleteAllSharesFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientDeletedAllComments:)]) {
            [delegate restClientDeletedAllComments:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Get Trash

- (void)getTrash:(NSString *)rootId trashId:(NSString *)trashId
{
    if (!rootId || !trashId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/trashes/%@", rootId, trashId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidGetTrash:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     trashId, BANMAYUN_TRASH_ID_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidGetTrash:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getTrashFailedWithError:)]) {
            [delegate restClient:self getTrashFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseGetTrashWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseGetTrashWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseTrashObject:request resultThread:thread succSelector:@selector(didParseGetTrash:) failSelector:@selector(parseGetTrashFailedForRequest:)];
}


- (void)didParseGetTrash:(BMYTrash *)trash
{
    if ([delegate respondsToSelector:@selector(restClient:gotTrash:)]) {
        [delegate restClient:self gotTrash:trash];
    }
}


- (void)parseGetTrashFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing trash");
    if ([delegate respondsToSelector:@selector(restClient:getTrashFailedWithError:)]) {
        [delegate restClient:self getTrashFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - List Trashes

- (void)listTrashes:(NSString *)rootId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!rootId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/trashes", rootId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListTrashes:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     nil];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)listTrashes:(NSString *)rootId
{
    [self listTrashes:rootId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidListTrashes:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listTrashesFailedWithError:)]) {
            [delegate restClient:self listTrashesFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseListTrashesResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseListTrashesResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYTrash class] resultThread:thread succSelector:@selector(didParseListTrashesResultList:) failSelector:@selector(parseListTrashesResultListFailedForRequest:)];
}


- (void)didParseListTrashesResultList:(BMYResultList *)trashesList
{
    if ([delegate respondsToSelector:@selector(restClient:listedTrashes:)]) {
        [delegate restClient:self listedTrashes:trashesList];
    }
}


- (void)parseListTrashesResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing list");
    if ([delegate respondsToSelector:@selector(restClient:listTrashesFailedWithError:)]) {
        [delegate restClient:self listTrashesFailedWithError:error];
    }
}



#pragma mark - 
#pragma mark - Delete Trash

- (void)deleteTrash:(NSString *)rootId trashId:(NSString *)trashId
{
    if (!rootId || !trashId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/trashes/%@", rootId, trashId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteTrash:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     trashId, BANMAYUN_TRASH_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteTrash:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteTrashFailedWithError:)]) {
            [delegate restClient:self deleteTrashFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseDeleteTrashWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseDeleteTrashWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseTrashObject:request resultThread:thread succSelector:@selector(didParseDeleteTrash:) failSelector:@selector(parseDeleteTrashFailedForRequest:)];
}


- (void)didParseDeleteTrash:(BMYTrash *)trash
{
    if ([delegate respondsToSelector:@selector(restClient:deletedTrash:)]) {
        [delegate restClient:self deletedTrash:trash];
    }
}


- (void)parseDeleteTrashFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing trash");
    if ([delegate respondsToSelector:@selector(restClient:deleteTrashFailedWithError:)]) {
        [delegate restClient:self deleteTrashFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Delete All Trashes

- (void)deleteAllTrashes:(NSString *)rootId
{
    if (!rootId) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/trashes", rootId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"DELETE";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidDeleteAllTrashes:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidDeleteAllTrashes:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteAllTrashesFailedWithError:)]) {
            [delegate restClient:self deleteAllTrashesFailedWithError:request.error];
        }
    }else{
        if ([delegate respondsToSelector:@selector(restClientDeletedAllTrashes:)]) {
            [delegate restClientDeletedAllTrashes:self];
        }
    }
    [requests removeObject:request];
}


#pragma mark -
#pragma mark - Restore Trash

- (void)restoreTrash:(NSString *)rootId trashId:(NSString *)trashId toPath:(NSString *)toPath
{
    if (!rootId || !trashId) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (toPath) {
        [params setObject:toPath forKey:@"to_path"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/roots/%@/trashes/%@/restore", rootId, trashId];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"POST";
    
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidRestoreTrash:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     rootId, BANMAYUN_ROOT_ID_KEY,
                                     trashId, BANMAYUN_TRASH_ID_KEY,
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (toPath) {
        [userInfo setObject:toPath forKey:@"to_path"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)requestDidRestoreTrash:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:restoreTrashFailedWithError:)]) {
            [delegate restClient:self restoreTrashFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseRestoreTrashWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseRestoreTrashWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseTrashObject:request resultThread:thread succSelector:@selector(didParseRestoreTrash:) failSelector:@selector(parseRestoreTrashFailedForRequest:)];
}


- (void)didParseRestoreTrash:(BMYTrash *)trash
{
    if ([delegate respondsToSelector:@selector(restClient:restoredTrash:)]) {
        [delegate restClient:self restoredTrash:trash];
    }
}


- (void)parseRestoreTrashFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing trash");
    if ([delegate respondsToSelector:@selector(restClient:restoreTrashFailedWithError:)]) {
        [delegate restClient:self restoreTrashFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Search Users

- (void)searchUsers:(NSString *)query groupId:(NSString *)groupId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!query) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   query, @"query",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (groupId) {
        [params setObject:groupId forKey:BANMAYUN_GROUP_ID_KEY];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/search/users"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSearchUsers:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     query, @"query",
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (groupId) {
        [userInfo setObject:groupId forKey:BANMAYUN_GROUP_ID_KEY];
    }
    if (usingOffset) {
        [userInfo setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [userInfo setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)searchUsers:(NSString *)query groupId:(NSString *)groupId
{
    [self searchUsers:query groupId:groupId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)searchUsers:(NSString *)query
{
    [self searchUsers:query groupId:nil];
}


- (void)requestDidSearchUsers:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:searchUsersFailedWithError:)]) {
            [delegate restClient:self searchUsersFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSearchUsersResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseSearchUsersResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYUser class] resultThread:thread succSelector:@selector(didParseSearchUsersResultList:) failSelector:@selector(parseSearchUsersResultListFailedForRequest:)];
}


- (void)didParseSearchUsersResultList:(BMYResultList *)usersList
{
    if ([delegate respondsToSelector:@selector(restClient:searchedUsers:)]) {
        [delegate restClient:self searchedUsers:usersList];
    }
}


- (void)parseSearchUsersResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:searchUsersFailedWithError:)]) {
        [delegate restClient:self searchUsersFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Search Groups

- (void)searchGroups:(NSString *)query userId:(NSString *)aUserId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!query) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   query, @"query",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (aUserId) {
        [params setObject:aUserId forKey:BANMAYUN_USER_ID_KEY];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/search/groups"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSearchGroups:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     query, @"query",
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (aUserId) {
        [userInfo setObject:aUserId forKey:BANMAYUN_USER_ID_KEY];
    }
    if (usingOffset) {
        [userInfo setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [userInfo setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)searchGroups:(NSString *)query userId:(NSString *)aUserId
{
    [self searchGroups:query userId:aUserId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)searchGroups:(NSString *)query
{
    [self searchGroups:query userId:nil];
}


- (void)requestDidSearchGroups:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:searchGroupsFailedWithError:)]) {
            [delegate restClient:self searchGroupsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSearchGroupsResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseSearchGroupsResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYGroup class] resultThread:thread succSelector:@selector(didParseSearchGroupsResultList:) failSelector:@selector(parseSearchGroupsResultListFailedForRequest:)];
}


-(void)didParseSearchGroupsResultList:(BMYResultList *)groupsList
{
    if ([delegate respondsToSelector:@selector(restClient:searchedGroups:)]) {
        [delegate restClient:self searchedGroups:groupsList];
    }
}


- (void)parseSearchGroupsResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:searchGroupsFailedWithError:)]) {
        [delegate restClient:self searchGroupsFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Search Files

- (void)searchFiles:(NSString *)query rootId:(NSString *)rootId path:(NSString *)path usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!query) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   query, @"query",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (rootId) {
        [params setObject:rootId forKey:BANMAYUN_ROOT_ID_KEY];
    }
    if (path) {
        [params setObject:path forKey:@"path"];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/search/files"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidSearchFiles:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     query, @"query",
                                     [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                     nil];
    if (rootId) {
        [userInfo setObject:rootId forKey:BANMAYUN_ROOT_ID_KEY];
    }
    if (path) {
        [userInfo setObject:path forKey:@"path"];
    }
    if (usingOffset) {
        [userInfo setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [userInfo setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)searchFiles:(NSString *)query rootId:(NSString *)rootId path:(NSString *)path
{
    [self searchFiles:query rootId:rootId path:path usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)searchFiles:(NSString *)query
{
    [self searchFiles:query rootId:nil path:nil];
}


- (void)requestDidSearchFiles:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:searchFilesFailedWithError:)]) {
            [delegate restClient:self searchFilesFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseSearchFilesResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseSearchFilesResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYMetadata class] resultThread:thread succSelector:@selector(didParseSearchFilesResultList:) failSelector:@selector(parseSearchFilesResultListFailedForRequest:)];
}


- (void)didParseSearchFilesResultList:(BMYResultList *)filesList
{
    if ([delegate respondsToSelector:@selector(restClient:searchedFiles:)]) {
        [delegate restClient:self searchedFiles:filesList];
    }
}


- (void)parseSearchFilesResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:searchFilesFailedWithError:)]) {
        [delegate restClient:self searchFilesFailedWithError:error];
    }
}



#pragma mark -
#pragma mark - Top Users

- (void)topUsers:(NSString *)orderBy usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!orderBy) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   orderBy, @"order_by",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/top/users"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidTopUsers:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)topUsers:(NSString *)orderBy
{
    [self topUsers:orderBy usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidTopUsers:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:topUsersFailedWithError:)]) {
            [delegate restClient:self topUsersFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseTopUsersResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseTopUsersResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYUser class] resultThread:thread succSelector:@selector(didParseTopUsersResultList:) failSelector:@selector(parseTopUsersResultListFailedForRequest:)];
}


- (void)didParseTopUsersResultList:(BMYResultList *)usersList
{
    if ([delegate respondsToSelector:@selector(restClient:doneTopUsers:)]) {
        [delegate restClient:self doneTopUsers:usersList];
    }
}


- (void)parseTopUsersResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:topUsersFailedWithError:)]) {
        [delegate restClient:self topUsersFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Top Groups

- (void)topGroups:(NSString *)orderBy usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!orderBy) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   orderBy, @"order_by",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/top/groups"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidTopGroups:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)topGroups:(NSString *)orderBy
{
    [self topGroups:orderBy usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidTopGroups:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:topGroupsFailedWithError:)]) {
            [delegate restClient:self topGroupsFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseTopGroupsResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseTopGroupsResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYGroup class] resultThread:thread succSelector:@selector(didParseTopGroupsResultList:) failSelector:@selector(parseTopGroupsResultListFailedForRequest:)];
}


- (void)didParseTopGroupsResultList:(BMYResultList *)groupsList
{
    if ([delegate respondsToSelector:@selector(restClient:doneTopGroups:)]) {
        [delegate restClient:self doneTopGroups:groupsList];
    }
}


- (void)parseTopGroupsResultListFailedForRequest:(BMYRequest *)request
{
    NSError *error = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:topGroupsFailedWithError:)]) {
        [delegate restClient:self topGroupsFailedWithError:error];
    }
}


#pragma mark -
#pragma mark - Top Files

- (void)topFiles:(NSString *)orderBy rootId:(NSString *)rootId usingOffset:(BOOL)usingOffset offset:(NSInteger)offset usingLimit:(BOOL)usingLimit limit:(NSInteger)limit
{
    if (!orderBy) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   orderBy, @"order_by",
                                   [self accessToken], BANMAYUN_ACCESS_TOKEN_KEY,
                                   nil];
    if (rootId) {
        [params setObject:rootId forKey:BANMAYUN_ROOT_ID_KEY];
    }
    if (usingOffset) {
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if (usingLimit) {
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    NSString *fullPath = [NSString stringWithFormat:@"/top/files"];
    NSMutableURLRequest *urlRequest = [self requestWithHost:kBMYBanMaYunAPIHost path:fullPath parameter:params];
    urlRequest.HTTPMethod = @"GET";
    BMYRequest *request = [[BMYRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidTopFiles:)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (params) {
        [userInfo addEntriesFromDictionary:params];
    }
    request.userInfo = userInfo;
    [requests addObject:request];
}


- (void)topFiles:(NSString *)orderBy rootId:(NSString *)rootId
{
    [self topFiles:orderBy rootId:rootId usingOffset:NO offset:0 usingLimit:NO limit:0];
}


- (void)requestDidTopFiles:(BMYRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:topFilesFailedWithError:)]) {
            [delegate restClient:self topFilesFailedWithError:request.error];
        }
    }else{
        SEL sel = @selector(parseTopFilesResultListWithRequest:resultThread:);
        [self genInvocationObjectForCallingParseFun:sel request:request];
    }
    [requests removeObject:request];
}


- (void)parseTopFilesResultListWithRequest:(BMYRequest *)request resultThread:(NSThread *)thread
{
    [self parseResultListObject:request memberType:[BMYMetadata class] resultThread:thread succSelector:@selector(didParseTopFilesResultList:) failSelector:@selector(parseTopFilesResultListFailedForRequest:)];
}


-(void)didParseTopFilesResultList:(BMYResultList *)filesList
{
    if ([delegate respondsToSelector:@selector(restClient:doneTopFiles:)]) {
        [delegate restClient:self doneTopFiles:filesList];
    }
}


- (void)parseTopFilesResultListFailedForRequest:(BMYRequest *)request
{
    NSError *err = [NSError errorWithDomain:BMYErrorDomain code:BMYErrorInvalidResponse userInfo:request.userInfo];
    BMYLogWarning(@"BanMaYunSDK: error parsing result list");
    if ([delegate respondsToSelector:@selector(restClient:topFilesFailedWithError:)]) {
        [delegate restClient:self topFilesFailedWithError:err];
    }
}

#pragma mark -
#pragma mark - Private Common Use Method

- (void)parseUserObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYUser *resultUser = [[BMYUser alloc] initWithDictionary:result];
    if (resultUser) {
        [self performSelector:aSuccSelector onThread:thread withObject:resultUser waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)parseRootObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *dict = (NSDictionary *)[request resultJSON];
    BMYRoot *theRoot = [[BMYRoot alloc] initWithDictionary:dict];
    if (theRoot) {
        [self performSelector:aSuccSelector onThread:thread withObject:theRoot waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}

- (void)parseResultListObject:(BMYRequest *)request memberType:(Class)type resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYResultList *resultList = [[BMYResultList alloc] initWithDictionary:result];
    if (resultList) {
        if (type == [BMYUser class]) {
            
        }else if (type == [BMYGroup class]){
            
        }
        [self performSelector:aSuccSelector onThread:thread withObject:resultList waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)parseMetadataObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYMetadata *theMeta = [[BMYMetadata alloc] initWithDictionary:result];
    if (theMeta) {
        [self performSelector:aSuccSelector onThread:thread withObject:theMeta waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}

- (void)parseCommentObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYComment *theComment = [[BMYComment alloc] initWithDictionary:result];
    if (theComment) {
        [self performSelector:aSuccSelector onThread:thread withObject:theComment waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)parseShareObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector
            failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYShare *share = [[BMYShare alloc] initWithDictionary:result];
    if (share) {
        [self performSelector:aSuccSelector onThread:thread withObject:share waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)parseTrashObject:(BMYRequest *)request resultThread:(NSThread *)thread succSelector:(SEL)aSuccSelector failSelector:(SEL)aFailSelector
{
    NSDictionary *result = (NSDictionary *)[request resultJSON];
    BMYTrash *trash = [[BMYTrash alloc] initWithDictionary:result];
    if (trash) {
        [self performSelector:aSuccSelector onThread:thread withObject:trash waitUntilDone:NO];
    }else{
        [self performSelector:aFailSelector onThread:thread withObject:request waitUntilDone:NO];
    }
}


- (void)genInvocationObjectForCallingParseFun:(SEL)selector request:(BMYRequest *)request
{
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:selector];
    [inv setArgument:&request atIndex:2];
    NSThread *thread = [NSThread currentThread];
    [inv setArgument:&thread atIndex:3];
    [inv retainArguments];
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
}

#pragma mark -
#pragma mark - Construct Request private method

- (NSMutableURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path parameter:(NSDictionary *)params
{
    return [self requestWithHost:host path:path parameter:params method:nil];
}



- (NSMutableURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path parameter:(NSDictionary *)params method:(NSString *)method
{
    NSString *latterEscapedRequestString = [BMYRestClient composeURLString:path parameters:params];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@%@", kBMYProtocolHTTPS, kBMYBanMaYunAPIHost, kBMYBanMaYunAPIVersion, latterEscapedRequestString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;
    return request;
}


#pragma mark -
#pragma mark - Private methods

+ (NSString *)escapeStr:(NSString *)str
{
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    NSString *escapedStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, (CFStringRef)@":?=,!$&'()*+;[]@#~", encoding));
    return escapedStr;
}


+ (NSString *)bestLanguage
{
    NSString *lang = nil;
    lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    lang = [lang isEqualToString:@"zh-Hans"] ? @"zh_CN" : @"en_US";
    return lang;
}


+ (NSString *)composeURLString:(NSString *)preString parameters:(NSDictionary *)params
{
    NSString *language = [BMYRestClient bestLanguage];
    NSMutableString *escapedPreStr = [NSMutableString stringWithString:[BMYRestClient escapeStr:preString]];
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"?locale=%@", language];
    for (NSString *key in [params allKeys]) {
        NSString *keyString = [key description];
        NSString *valueString = [[params objectForKey:key] description];
        [urlString appendFormat:@"&%@=%@", [BMYRestClient escapeStr:keyString], [BMYRestClient escapeStr:valueString]];
    }
    return [escapedPreStr stringByAppendingString:urlString];
}



@end
