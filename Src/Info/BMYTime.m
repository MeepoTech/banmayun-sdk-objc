#import "BMYTime.h"

@implementation BMYTime

@synthesize millis;
@synthesize display_value;


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        millis = [[dict objectForKey:@"millis"] longLongValue];
        display_value = [dict objectForKey:@"display_value"];
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithLongLong:millis] forKey:@"millis"];
    [aCoder encodeObject:display_value forKey:@"display_value"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        millis = [[aDecoder decodeObjectForKey:@"millis"] longLongValue];
        display_value = [aDecoder decodeObjectForKey:@"display_value"];
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *timeDict = [NSMutableDictionary dictionary];

    [timeDict setObject:[NSNumber numberWithLongLong:millis] forKey:@"millis"];

    if (display_value) {
        [timeDict setObject:display_value forKey:@"display_value"];
    }

    return timeDict;
}

@end
