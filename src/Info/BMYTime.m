//
//  BMYTime.m
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYTime.h"

@implementation BMYTime

//@synthesize rfc1123;
@synthesize millis;
@synthesize display_value;


- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
//        rfc1123 = [dict objectForKey:@"rfc1123"];
        millis = [[dict objectForKey:@"millis"] longLongValue];
        display_value = [dict objectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    [aCoder encodeObject:rfc1123 forKey:@"rfc1123"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:millis] forKey:@"millis"];
    [aCoder encodeObject:display_value forKey:@"display_value"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
//        rfc1123 = [aDecoder decodeObjectForKey:@"rfc1123"];
        millis = [[aDecoder decodeObjectForKey:@"millis"] longLongValue];
        display_value = [aDecoder decodeObjectForKey:@"display_value"];
    }
    return self;
}


#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson
{
    NSMutableDictionary *timeDict = [NSMutableDictionary dictionary];
//    if (rfc1123) {
//        [timeDict setObject:rfc1123 forKey:@"rfc1123"];
//    }
    [timeDict setObject:[NSNumber numberWithLongLong:millis] forKey:@"millis"];
    if (display_value) {
        [timeDict setObject:display_value forKey:@"display_value"];
    }
    return timeDict;
}

@end
