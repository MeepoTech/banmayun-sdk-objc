//
//  BMYComment.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYComment.h"
#import "BMYTime.h"
#import "BMYUser.h"

@implementation BMYComment


@synthesize commentId;
@synthesize root_id;
@synthesize meta_id;
@synthesize contents;
@synthesize created_at;
@synthesize created_by;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        commentId = [dict objectForKey:@"id"];
        root_id   = [dict objectForKey:@"root_id"];
        meta_id   = [dict objectForKey:@"meta_id"];
        contents    = [dict objectForKey:@"contents"];
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
        if ([dict objectForKey:@"created_by"]) {
            created_by  = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"created_by"]];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:commentId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:meta_id forKey:@"meta_id"];
    [aCoder encodeObject:contents forKey:@"contents"];
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [aCoder encodeObject:created_by forKey:@"created_by"];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        commentId   = [aDecoder decodeObjectForKey:@"id"];
        root_id     = [aDecoder decodeObjectForKey:@"root_id"];
        meta_id     = [aDecoder decodeObjectForKey:@"meta_id"];
        contents    = [aDecoder decodeObjectForKey:@"contents"];
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at  = [aDecoder decodeObjectForKey:@"created_at"];
        }
        if ([aDecoder containsValueForKey:@"created_by"]) {
            created_by  = [aDecoder decodeObjectForKey:@"created_by"];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
    if (commentId) {
        [commentDict setObject:commentId forKey:@"id"];
    }
    if (root_id) {
        [commentDict setObject:root_id forKey:@"root_id"];
    }
    if (meta_id) {
        [commentDict setObject:meta_id forKey:@"meta_id"];
    }
    if (contents) {
        [commentDict setObject:contents forKey:@"contents"];
    }
    if (created_at) {
        [commentDict setObject:created_at forKey:@"created_at"];
    }
    if (created_by) {
        [commentDict setObject:created_by forKey:@"created_by"];
    }
    return commentDict;
}
@end
