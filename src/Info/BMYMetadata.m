//
//  BMYMetadata.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYMetadata.h"
#import "BMYSize.h"
#import "BMYTime.h"
#import "BMYUser.h"
#import "BMYPermission.h"

@implementation BMYMetadata

@synthesize fileId;
@synthesize root_id;
@synthesize name;
@synthesize path;
@synthesize md5;
@synthesize size;
@synthesize version;
@synthesize icon;
@synthesize is_dir;
@synthesize thumb_exists;
@synthesize insertable;
@synthesize readable;
@synthesize writable;
@synthesize deletable;
@synthesize comment_count;
@synthesize share_count;
@synthesize created_at;
@synthesize created_by;
@synthesize modified_at;
@synthesize modified_by;
@synthesize client_modified_at;
@synthesize permission;
@synthesize contents;



- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        fileId          = [dict  objectForKey:@"id"];
        root_id         = [dict  objectForKey:@"root_id"];
        name            = [dict  objectForKey:@"name"];
        path            = [dict  objectForKey:@"path"];
        md5             = [dict  objectForKey:@"md5"];
        if ([dict objectForKey:@"size"]) {
            size        = [[BMYSize alloc] initWithDictionary:[dict objectForKey:@"size"]];
        }
        version         = [[dict objectForKey:@"version"] longValue];
        icon            = [dict  objectForKey:@"icon"];
        is_dir          = [[dict objectForKey:@"is_dir"] boolValue];
        thumb_exists    = [[dict objectForKey:@"thumb_exists"] boolValue];
        insertable      = [[dict objectForKey:@"insertable"] boolValue];
        readable        = [[dict objectForKey:@"readable"] boolValue];
        writable        = [[dict objectForKey:@"writable"] boolValue];
        deletable       = [[dict objectForKey:@"deletable"] boolValue];
        comment_count   = [[dict objectForKey:@"comment_count"] integerValue];
        share_count     = [[dict objectForKey:@"share_count"] integerValue];
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
        if ([dict objectForKey:@"created_by"]) {
            created_by  = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"created_by"]];
        }
        if ([dict objectForKey:@"modified_at"]) {
            modified_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"modified_at"]];
        }
        if ([dict objectForKey:@"modified_by"]) {
            modified_by = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"modified_by"]];
        }
        if ([dict objectForKey:@"client_modified_at"]) {
            client_modified_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"client_modified_at"]];
        }
        if ([dict objectForKey:@"permission"]) {
            permission  = [[BMYPermission alloc] initWithDictionary:[dict objectForKey:@"permission"]];
        }
        if ([dict objectForKey:@"contents"]) {
            NSArray *subfileDicts = [dict objectForKey:@"contents"];
            NSMutableArray *mutableContents = [[NSMutableArray alloc] initWithCapacity:[subfileDicts count]];
            for (NSDictionary *subDict in subfileDicts) {
                BMYMetadata *subfileMetadata = [[BMYMetadata alloc] initWithDictionary:subDict];
                [mutableContents addObject:subfileMetadata];
            }
            contents = mutableContents;
        }
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        fileId      = [aDecoder decodeObjectForKey:@"id"];
        root_id     = [aDecoder decodeObjectForKey:@"root_id"];
        name        = [aDecoder decodeObjectForKey:@"name"];
        path        = [aDecoder decodeObjectForKey:@"path"];
        if ([aDecoder containsValueForKey:@"md5"]) {
            md5     = [aDecoder decodeObjectForKey:@"md5"];
        }
        if ([aDecoder containsValueForKey:@"size"]) {
            size    = [aDecoder decodeObjectForKey:@"size"];
        }
        if ([aDecoder containsValueForKey:@"version"]) {
            version = [[aDecoder decodeObjectForKey:@"version"] longValue];
        }
        if ([aDecoder containsValueForKey:@"icon"]) {
            icon    = [aDecoder decodeObjectForKey:@"icon"];
        }
        is_dir      = [aDecoder decodeBoolForKey:@"is_dir"];
        thumb_exists = [aDecoder decodeBoolForKey:@"thumb_exists"];
        insertable  = [aDecoder decodeBoolForKey:@"insertable"];
        readable    = [aDecoder decodeBoolForKey:@"readable"];
        writable    = [aDecoder decodeBoolForKey:@"writable"];
        deletable   = [aDecoder decodeBoolForKey:@"deletable"];
        comment_count = [aDecoder decodeIntegerForKey:@"comment_count"];
        share_count = [aDecoder decodeIntegerForKey:@"share_count"];
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at = [aDecoder decodeObjectForKey:@"created_at"];
        }
        if ([aDecoder containsValueForKey:@"created_by"]) {
            created_by = [aDecoder decodeObjectForKey:@"created_by"];
        }
        if ([aDecoder containsValueForKey:@"modified_at"]) {
            modified_at = [aDecoder decodeObjectForKey:@"modified_at"];
        }
        if ([aDecoder containsValueForKey:@"modified_by"]) {
            modified_by = [aDecoder decodeObjectForKey:@"modified_by"];
        }
        if ([aDecoder containsValueForKey:@"client_modified_at"]) {
            client_modified_at  = [aDecoder decodeObjectForKey:@"client_modified_at)"];
        }
        if ([aDecoder containsValueForKey:@"permission"]) {
            permission  = [aDecoder decodeObjectForKey:@"permission"];
        }
        if ([aDecoder containsValueForKey:@"contents"]) {
            contents    = [aDecoder decodeObjectForKey:@"contents"];
        }
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:fileId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:path forKey:@"path"];
    if (md5) {
        [aCoder encodeObject:md5 forKey:@"md5"];
    }
    if (size) {
        [aCoder encodeObject:size forKey:@"size"];
    }
    [aCoder encodeObject:[NSNumber numberWithLong:version] forKey:@"version"];
    if (icon) {
        [aCoder encodeObject:icon forKey:@"icon"];
    }
    [aCoder encodeBool:is_dir forKey:@"is_dir"];
    [aCoder encodeBool:thumb_exists forKey:@"thumb_exists"];
    [aCoder encodeBool:insertable forKey:@"insertable"];
    [aCoder encodeBool:readable forKey:@"readable"];
    [aCoder encodeBool:writable forKey:@"writable"];
    [aCoder encodeBool:deletable forKey:@"deletable"];
    [aCoder encodeInteger:comment_count forKey:@"comment_count"];
    [aCoder encodeInteger:share_count forKey:@"share_count"];
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [aCoder encodeObject:created_by forKey:@"created_by"];
    }
    if (modified_at) {
        [aCoder encodeObject:modified_at forKey:@"modified_at"];
    }
    if (modified_by) {
        [aCoder encodeObject:modified_by forKey:@"modified_by"];
    }
    if (client_modified_at) {
        [aCoder encodeObject:client_modified_at forKey:@"client_modified_at"];
    }
    if (permission) {
        [aCoder encodeObject:permission forKey:@"permission"];
    }
    if (contents) {
        [aCoder encodeObject:contents forKey:@"contents"];
    }
}


- (id)proxyForJson
{
    NSMutableDictionary *metaDic = [NSMutableDictionary dictionary];
    if (fileId) {
        [metaDic setObject:fileId forKey:@"id"];
    }
    if (root_id) {
        [metaDic setObject:root_id forKey:@"root_id"];
    }
    if (name) {
        [metaDic setObject:name forKey:@"name"];
    }
    if (path) {
        [metaDic setObject:path forKey:@"path"];
    }
    if (md5) {
        [metaDic setObject:md5 forKey:@"md5"];
    }
    if (size) {
        [metaDic setObject:size forKey:@"size"];
    }
    [metaDic setObject:[NSNumber numberWithLong:version] forKey:@"version"];
    if (icon) {
        [metaDic setObject:icon forKey:@"icon"];
    }
    [metaDic setObject:[NSNumber numberWithBool:is_dir] forKey:@"is_dir"];
    [metaDic setObject:[NSNumber numberWithBool:thumb_exists] forKey:@"thumb_exists"];
    [metaDic setObject:[NSNumber numberWithBool:insertable] forKey:@"insertable"];
    [metaDic setObject:[NSNumber numberWithBool:readable] forKey:@"readable"];
    [metaDic setObject:[NSNumber numberWithBool:writable] forKey:@"writable"];
    [metaDic setObject:[NSNumber numberWithBool:deletable] forKey:@"deletable"];
    [metaDic setObject:[NSNumber numberWithInteger:comment_count] forKey:@"comment_count"];
    [metaDic setObject:[NSNumber numberWithInteger:share_count] forKey:@"share_count"];
    if (created_at) {
        [metaDic setObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [metaDic setObject:created_by forKey:@"created_by"];
    }
    if (modified_at) {
        [metaDic setObject:modified_at forKey:@"modified_at"];
    }
    if (modified_by) {
        [metaDic setObject:modified_by forKey:@"modified_by"];
    }
    if (client_modified_at) {
        [metaDic setObject:client_modified_at forKey:@"client_modified_at"];
    }
    if (permission) {
        [metaDic setObject:permission forKey:@"permission"];
    }
    if (contents) {
        [metaDic setObject:contents forKey:@"contents"];
    }
    return metaDic;
}


@end
