//
//  BMYJsonBase.m
//  testDropBoxJSON
//
//  Created by MeePoTech on 14-4-16.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import "BMYJsonBase.h"

NSString * BMYJSONErrorDomain = @"org.BanMaYun.JSON.ErrorDomain";


@implementation BMYJsonBase

@synthesize errorTrace;
@synthesize maxDepth;

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 512;
    return self;
}

- (void)dealloc {
    [errorTrace release];
    [super dealloc];
}

- (void)addErrorWithCode:(NSUInteger)code description:(NSString*)str {
    NSDictionary *userInfo;
    if (!errorTrace) {
        errorTrace = [NSMutableArray new];
        userInfo = [NSDictionary dictionaryWithObject:str forKey:NSLocalizedDescriptionKey];
        
    } else {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    str, NSLocalizedDescriptionKey,
                    [errorTrace lastObject], NSUnderlyingErrorKey,
                    nil];
    }
    
    NSError *error = [NSError errorWithDomain:BMYJSONErrorDomain code:code userInfo:userInfo];
    
    [self willChangeValueForKey:@"errorTrace"];
    [errorTrace addObject:error];
    [self didChangeValueForKey:@"errorTrace"];
}

- (void)clearErrorTrace {
    [self willChangeValueForKey:@"errorTrace"];
    [errorTrace release];
    errorTrace = nil;
    [self didChangeValueForKey:@"errorTrace"];
}

@end
