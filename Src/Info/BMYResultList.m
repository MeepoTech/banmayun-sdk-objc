#import "BMYResultList.h"

@implementation BMYResultList

@synthesize total;
@synthesize offset;
@synthesize entries;


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        total = [[dict objectForKey:@"total"] integerValue];
        offset = [[dict objectForKey:@"offset"] integerValue];

        if ([dict objectForKey:@"entries"]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[dict count]];

            for (id obj in [dict objectForKey : @"entries"]) {
                [tempArray addObject:obj];
            }

            entries = tempArray;
        }
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:total forKey:@"total"];
    [aCoder encodeInteger:offset forKey:@"offset"];

    if (entries) {
        [aCoder encodeObject:entries forKey:@"entries"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        total = [aDecoder decodeIntegerForKey:@"total"];
        offset = [aDecoder decodeIntegerForKey:@"offset"];

        if ([aDecoder containsValueForKey:@"entries"]) {
            entries = [aDecoder decodeObjectForKey:@"entries"];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *resultListDict = [NSMutableDictionary dictionary];

    [resultListDict setObject:[NSNumber numberWithInteger:total] forKey:@"total"];
    [resultListDict setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];

    if (entries) {
        [resultListDict setObject:entries forKey:@"entries"];
    }

    return resultListDict;
}

@end
