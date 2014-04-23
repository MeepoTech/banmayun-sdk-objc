//
//  BMYUser.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYUser.h"
#import "BMYUserRole.h"
#import "BMYTime.h"
#import "BMYRelation.h"
#import "BMYRoot.h"

@implementation BMYUser

@synthesize userId;
@synthesize root_id;
@synthesize name;
@synthesize email;
@synthesize source;
@synthesize display_name;
@synthesize role;
@synthesize groups_can_own;
@synthesize is_activated;
@synthesize is_blocked;
@synthesize group_count;
@synthesize created_at;
@synthesize relation;
@synthesize root;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        userId      = [dict objectForKey:@"id"];
        root_id     = [dict objectForKey:@"root_id"];
        name    = [dict objectForKey:@"name"];
        email   = [dict objectForKey:@"email"];
        source  = [dict objectForKey:@"source"];
        display_name = [dict objectForKey:@"display_name"];
        if ([dict objectForKey:@"role"]) {
            role    = [[BMYUserRole alloc] initWithDictionary:[dict objectForKey:@"role"]];
        }
        groups_can_own = [[dict objectForKey:@"groups_can_own"] integerValue];
        is_activated = [[dict objectForKey:@"is_activated"] boolValue];
        is_blocked  = [[dict objectForKey:@"is_blocked"] boolValue];
        group_count = [[dict objectForKey:@"group_count"] integerValue];
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
        if ([dict objectForKey:@"relation"]) {
            relation    = [[BMYRelation alloc] initWithDictionary:[dict objectForKey:@"relation"]];
        }
        if ([dict objectForKey:@"root"]) {
            root    = [[BMYRoot alloc] initWithDictionary:[dict objectForKey:@"root"]];
        }
    }
    return self;
}



#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:userId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:email forKey:@"email"];
    [aCoder encodeObject:source forKey:@"source"];
    [aCoder encodeObject:display_name forKey:@"display_name"];
    if (role) {
        [aCoder encodeObject:role forKey:@"role"];
    }
    [aCoder encodeInteger:groups_can_own forKey:@"groups_can_own"];
    [aCoder encodeBool:is_activated forKey:@"is_activated"];
    [aCoder encodeBool:is_blocked forKey:@"is_blocked"];
    [aCoder encodeInteger:group_count forKey:@"group_count"];
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
    if (relation) {
        [aCoder encodeObject:relation forKey:@"relation"];
    }
    if (root) {
        [aCoder encodeObject:root forKey:@"root"];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        userId      = [aDecoder decodeObjectForKey:@"id"];
        root_id     = [aDecoder decodeObjectForKey:@"root_id"];
        name    = [aDecoder decodeObjectForKey:@"name"];
        email   = [aDecoder decodeObjectForKey:@"email"];
        source  = [aDecoder decodeObjectForKey:@"source"];
        display_name = [aDecoder decodeObjectForKey:@"display_name"];
        if ([aDecoder containsValueForKey:@"role"]) {
            role    = [aDecoder decodeObjectForKey:@"role"];
        }
        groups_can_own  = [aDecoder decodeIntegerForKey:@"groups_can_own"];
        is_activated    = [aDecoder decodeBoolForKey:@"is_activated"];
        is_blocked      = [aDecoder decodeBoolForKey:@"is_blocked"];
        group_count     = [aDecoder decodeIntegerForKey:@"group_count"];
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at  = [aDecoder decodeObjectForKey:@"created_at"];
        }
        if ([aDecoder containsValueForKey:@"relation"]) {
            relation    = [aDecoder decodeObjectForKey:@"relation"];
        }
        if ([aDecoder containsValueForKey:@"root"]) {
            root        = [aDecoder decodeObjectForKey:@"root"];
        }
    }
    return self;
}

#pragma mark -
#pragma mark - Method for Json

-(id)proxyForJson
{
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
    if (userId) {
        [userDict setObject:userId forKey:@"id"];
    }
    if (root_id) {
        [userDict setObject:root_id forKey:@"root_id"];
    }
    if (name) {
        [userDict setObject:name forKey:@"name"];
    }
    if (email) {
        [userDict setObject:email forKey:@"email"];
    }
    if (source) {
        [userDict setObject:source forKey:@"source"];
    }
    if (display_name) {
        [userDict setObject:display_name forKey:@"display_name"];
    }
    if (role) {
        [userDict setObject:role forKey:@"role"];
    }
    [userDict setObject:[NSNumber numberWithInteger:groups_can_own] forKey:@"groups_can_own"];
    [userDict setObject:[NSNumber numberWithBool:is_activated] forKey:@"is_activated"];
    [userDict setObject:[NSNumber numberWithBool:is_blocked] forKey:@"is_blocked"];
    [userDict setObject:[NSNumber numberWithInteger:group_count] forKey:@"group_count"];
    if (created_at) {
        [userDict setObject:created_at forKey:@"created_at"];
    }
    if (relation) {
        [userDict setObject:relation forKey:@"relation"];
    }
    if (root) {
        [userDict setObject:root forKey:@"root"];
    }
    return userDict;
}


@end
