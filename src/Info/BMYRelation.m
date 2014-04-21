//
//  BMYRelation.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYRelation.h"
#import "BMYRelationRole.h"
#import "BMYTime.h"

@implementation BMYRelation

@synthesize role;
@synthesize is_activated;
@synthesize is_blocked;
@synthesize remarks;
@synthesize created_at;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        if ([dict objectForKey:@"role"]) {
            role = [[BMYRelationRole alloc] initWithDictionary:[dict objectForKey:@"role"]];
        }
        is_activated = [[dict objectForKey:@"is_activated"] boolValue];
        is_blocked  = [[dict objectForKey:@"is_blocked"] boolValue];
        remarks = [dict objectForKey:@"remarks"];
        if ([dict objectForKey:@"created_at"]) {
            created_at  = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (role) {
        [aCoder encodeObject:role forKey:@"role"];
    }
    [aCoder encodeBool:is_activated forKey:@"is_activated"];
    [aCoder encodeBool:is_blocked forKey:@"is_blocked"];
    [aCoder encodeObject:remarks forKey:@"remarks"];
    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        if ([aDecoder containsValueForKey:@"role"]) {
            role = [aDecoder decodeObjectForKey:@"role"];
        }
        is_activated = [aDecoder decodeBoolForKey:@"is_activated"];
        is_blocked  = [aDecoder decodeBoolForKey:@"is_blocked"];
        remarks = [aDecoder decodeObjectForKey:@"remarks"];
        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at  = [aDecoder decodeObjectForKey:@"created_at"];
        }
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *relationDict = [NSMutableDictionary dictionary];
    if (role) {
        [relationDict setObject:role forKey:@"role"];
    }
    [relationDict setObject:[NSNumber numberWithBool:is_activated] forKey:@"is_activated"];
    [relationDict setObject:[NSNumber numberWithBool:is_blocked] forKey:@"is_blocked"];
    if (remarks) {
        [relationDict setObject:remarks forKey:@"remarks"];
    }
    if (created_at) {
        [relationDict setObject:created_at forKey:@"created_at"];
    }
    return relationDict;
}

@end
