//
//  BMYShare.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYShare.h"
#import "BMYTime.h"
#import "BMYUser.h"
#import "BMYMetadata.h"

@implementation BMYShare


@synthesize shareId;
@synthesize root_id;
@synthesize meta_id;
@synthesize expires_at;
@synthesize created_at;
@synthesize created_by;
@synthesize meta;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        shareId     = [dict objectForKey:@"id"];
        root_id     = [dict objectForKey:@"root_id"];
        meta_id     = [dict objectForKey:@"meta_id"];
        if ([dict objectForKey:@"expires_at"]) {
            expires_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"expires_at"]];
        }
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
        if ([dict objectForKey:@"created_by"]) {
            created_by  = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"created_by"]];
        }
        if ([dict objectForKey:@"meta"]) {
            meta        = [[BMYMetadata alloc] initWithDictionary:[dict objectForKey:@"meta"]];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:shareId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:meta_id forKey:@"meta_id"];
    if (expires_at) {
        [aCoder encodeObject:expires_at forKey:@"expires_at"];
    }
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [aCoder encodeObject:created_by forKey:@"created_by"];
    }
    if (meta) {
        [aCoder encodeObject:meta forKey:@"meta"];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        shareId = [aDecoder decodeObjectForKey:@"id"];
        root_id = [aDecoder decodeObjectForKey:@"root_id"];
        meta_id = [aDecoder decodeObjectForKey:@"meta_id"];
        if ([aDecoder containsValueForKey:@"expires_at"]) {
            expires_at  = [aDecoder decodeObjectForKey:@"expires_at"];
        }
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at  = [aDecoder decodeObjectForKey:@"created_at"];
        }
        if ([aDecoder containsValueForKey:@"created_by"]) {
            created_by  = [aDecoder decodeObjectForKey:@"created_by"];
        }
        if ([aDecoder containsValueForKey:@"meta"]) {
            meta        = [aDecoder decodeObjectForKey:@"meta"];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *shareDict =[NSMutableDictionary dictionary];
    if (shareId) {
        [shareDict setObject:shareId forKey:@"id"];
    }
    if (root_id) {
        [shareDict setObject:root_id forKey:@"root_id"];
    }
    if (meta_id) {
        [shareDict setObject:meta_id forKey:@"meta_id"];
    }
    if (expires_at) {
        [shareDict setObject:expires_at forKey:@"expires_at"];
    }
    if (created_at) {
        [shareDict setObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [shareDict setObject:created_by forKey:@"created_by"];
    }
    if (meta) {
        [shareDict setObject:meta forKey:@"meta"];
    }
    return shareDict;
}

@end
