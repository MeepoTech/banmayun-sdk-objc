//
//  BMYLink.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYLink.h"
#import "BMYTime.h"

@implementation BMYLink

@synthesize userId;
@synthesize deviceId;
@synthesize name;
@synthesize device;
@synthesize token;
@synthesize expires_at;
@synthesize created_at;
@synthesize is_current;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        userId      = [dict objectForKey:@"userid"];
        deviceId    = [dict objectForKey:@"id"];
        name        = [dict objectForKey:@"name"];
        device      = [dict objectForKey:@"device"];
        token       = [dict objectForKey:@"token"];
        if ([dict objectForKey:@"expires_at"]) {
            expires_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"expires_at"]];
        }
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
        is_current  = [[dict objectForKey:@"is_current"] boolValue];
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:userId forKey:@"userId"];
    [aCoder encodeObject:deviceId forKey:@"id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:device forKey:@"device"];
    [aCoder encodeObject:token forKey:@"token"];
    if (expires_at) {
        [aCoder encodeObject:expires_at forKey:@"expires_at"];
    }
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
    [aCoder encodeBool:is_current forKey:@"is_current"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        userId      = [aDecoder decodeObjectForKey:@"userId"];
        deviceId    = [aDecoder decodeObjectForKey:@"id"];
        name        = [aDecoder decodeObjectForKey:@"name"];
        device      = [aDecoder decodeObjectForKey:@"device"];
        token       = [aDecoder decodeObjectForKey:@"token"];
        if ([aDecoder containsValueForKey:@"expires_at"]) {
            expires_at  = [aDecoder decodeObjectForKey:@"expires_at"];
        }
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at  = [aDecoder decodeObjectForKey:@"created_at"];
        }
        is_current  = [aDecoder decodeBoolForKey:@"is_current"];
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *linkDict = [NSMutableDictionary dictionary];
    if (userId) {
        [linkDict setObject:userId forKey:@"userId"];
    }
    if (deviceId) {
        [linkDict setObject:deviceId forKey:@"deviceId"];
    }
    if (name) {
        [linkDict setObject:name forKey:@"name"];
    }
    if (device) {
        [linkDict setObject:device forKey:@"device"];
    }
    if (token) {
        [linkDict setObject:token forKey:@"token"];
    }
    if (expires_at) {
        [linkDict setObject:expires_at forKey:@"expires_at"];
    }
    if (created_at) {
        [linkDict setObject:created_at forKey:@"created_at"];
    }
    [linkDict setObject:[NSNumber numberWithBool:is_current] forKey:@"is_current"];
    return linkDict;
}

@end
