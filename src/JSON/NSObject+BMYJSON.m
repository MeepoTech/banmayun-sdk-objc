//
//  NSObject+BMYJSON.m
//  testDropBoxJSON
//
//  Created by MeePoTech on 14-4-16.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "NSObject+BMYJSON.h"
#import "BMYJsonWriter.h"

@implementation NSObject (NSObject_BMYJSON)

- (NSString *)JSONFragment {
    BMYJsonWriter *jsonWriter = [BMYJsonWriter new];
    NSString *json = [jsonWriter stringWithFragment:self];
    if (!json)
        NSLog(@"-JSONFragment failed. Error trace is: %@", [jsonWriter errorTrace]);
    [jsonWriter release];
    return json;
}

- (NSString *)JSONRepresentation {
    BMYJsonWriter *jsonWriter = [BMYJsonWriter new];
    NSString *json = [jsonWriter stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error trace is: %@", [jsonWriter errorTrace]);
    [jsonWriter release];
    return json;
}

@end
