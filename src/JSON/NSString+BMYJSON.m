//
//  NSString+BMYJSON.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "NSString+BMYJSON.h"
#import "BMYJsonParser.h"

@implementation NSString (NSString_BMYJSON)

- (id)JSONFragmentValue
{
    BMYJsonParser *jsonParser = [BMYJsonParser new];
    id repr = [jsonParser fragmentWithString:self];
    if (!repr)
        NSLog(@"-JSONFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
    [jsonParser release];
    return repr;
}

- (id)JSONValue
{
    BMYJsonParser *jsonParser = [BMYJsonParser new];
    id repr = [jsonParser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
    [jsonParser release];
    return repr;
}
@end

