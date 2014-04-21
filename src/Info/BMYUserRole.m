//
//  BMYUserRole.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYUserRole.h"

@implementation BMYUserRole

@synthesize name;
@synthesize display_value;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        name = [dict objectForKey:@"name"];
        display_value = [dict objectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:display_value forKey:@"display_value"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        name = [aDecoder decodeObjectForKey:@"name"];
        display_value = [aDecoder decodeObjectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *roleDict = [NSMutableDictionary dictionary];
    if (name) {
        [roleDict setObject:name forKey:@"name"];
    }
    if (display_value) {
        [roleDict setObject:display_value forKey:@"display_value"];
    }
    return [NSDictionary dictionaryWithDictionary:roleDict];
}

@end
