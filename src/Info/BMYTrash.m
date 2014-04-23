//
//  BMYTrash.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYTrash.h"
#import "BMYTime.h"
#import "BMYUser.h"
#import "BMYMetadata.h"

@implementation BMYTrash


@synthesize trashedFileId;
@synthesize root_id;
@synthesize meta_id;
@synthesize created_at;
@synthesize created_by;
@synthesize meta;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        trashedFileId   = [dict objectForKey:@"id"];
        root_id         = [dict objectForKey:@"root_id"];
        meta_id         = [dict objectForKey:@"meta_id"];
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
    [aCoder encodeObject:trashedFileId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:meta_id forKey:@"meta_id"];
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
        trashedFileId   = [aDecoder decodeObjectForKey:@"id"];
        root_id         = [aDecoder decodeObjectForKey:@"root_id"];
        meta_id         = [aDecoder decodeObjectForKey:@"meta_id"];
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
    NSMutableDictionary *trashDict = [NSMutableDictionary dictionary];
    if (trashedFileId) {
        [trashDict setObject:trashedFileId forKey:@"id"];
    }
    if (root_id) {
        [trashDict setObject:root_id forKey:@"root_id"];
    }
    if (meta_id) {
        [trashDict setObject:meta_id forKey:@"meta_id"];
    }
    if (created_at) {
        [trashDict setObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [trashDict setObject:created_by forKey:@"created_by"];
    }
    if (meta) {
        [trashDict setObject:meta forKey:@"meta"];
    }
    return trashDict;
}



@end
