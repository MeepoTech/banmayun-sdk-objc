//
//  BMYRoot.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYRoot.h"
#import "BMYSize.h"
#import "BMYPermission.h"

@implementation BMYRoot

@synthesize rootId;
@synthesize type;
@synthesize used;
@synthesize quota;
@synthesize default_permission;
@synthesize file_count;
@synthesize byte_count;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        rootId  = [dict objectForKey:@"id"];
        type    = [dict objectForKey:@"type"];
        if ([dict objectForKey:@"used"]) {
            used    = [[BMYSize alloc] initWithDictionary:[dict objectForKey:@"used"]];
        }
        if ([dict objectForKey:@"quota"]) {
            quota   = [[BMYSize alloc] initWithDictionary:[dict objectForKey:@"quota"]];
        }
        if ([dict objectForKey:@"default_permission"]) {
            default_permission  = [[BMYPermission alloc] initWithDictionary:[dict objectForKey:@"default_permission"]];
        }
        file_count = [[dict objectForKey:@"file_count"] integerValue];
        byte_count = [[dict objectForKey:@"byte_count"] longValue];
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:rootId forKey:@"id"];
    [aCoder encodeObject:type forKey:@"type"];
    if (used) {
        [aCoder encodeObject:used forKey:@"used"];
    }
    if (quota) {
        [aCoder encodeObject:quota forKey:@"quota"];
    }
    if (default_permission) {
        [aCoder encodeObject:default_permission forKey:@"default_permission"];
    }
    [aCoder encodeInteger:file_count forKey:@"file_count"];
    [aCoder encodeObject:[NSNumber numberWithLong:byte_count] forKey:@"byte_count"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        rootId  = [aDecoder decodeObjectForKey:@"id"];
        type    = [aDecoder decodeObjectForKey:@"type"];
        if ([aDecoder containsValueForKey:@"used"]) {
            used = [aDecoder decodeObjectForKey:@"used"];
        }
        if ([aDecoder containsValueForKey:@"quota"]) {
            quota   = [aDecoder decodeObjectForKey:@"quota"];
        }
        if ([aDecoder containsValueForKey:@"default_permission"]) {
            default_permission  = [aDecoder decodeObjectForKey:@"default_permission"];
        }
        file_count  = [aDecoder decodeIntegerForKey:@"file_count"];
        byte_count  = [[aDecoder decodeObjectForKey:@"byte_count"] longValue];
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionary];
    if (rootId) {
        [rootDict setObject:rootId forKey:@"id"];
    }
    if (type) {
        [rootDict setObject:type forKey:@"type"];
    }
    if (used) {
        [rootDict setObject:used forKey:@"used"];
    }
    if (quota) {
        [rootDict setObject:quota forKey:@"quota"];
    }
    if (default_permission) {
        [rootDict setObject:default_permission forKey:@"default_permission"];
    }
    [rootDict setObject:[NSNumber numberWithInteger:file_count] forKey:@"file_count"];
    [rootDict setObject:[NSNumber numberWithLong:byte_count] forKey:@"byte_count"];
    return rootDict;
}

@end
