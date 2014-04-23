//
//  BMYSize.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYSize.h"

@implementation BMYSize

@synthesize bytes;
@synthesize display_value;

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        bytes = [[dict objectForKey:@"bytes"] longValue];
        display_value = [dict objectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithLong:bytes] forKey:@"bytes"];
    [aCoder encodeObject:display_value forKey:@"display_value"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        bytes = [[aDecoder decodeObjectForKey:@"bytes"] longValue];
        display_value = [aDecoder decodeObjectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *sizeDict = [NSMutableDictionary dictionary];
    if (display_value) {
        [sizeDict setObject:display_value forKey:@"display_value"];
    }
    [sizeDict setObject:[NSNumber numberWithLong:bytes] forKey:@"bytes"];
    return sizeDict;
}

@end
