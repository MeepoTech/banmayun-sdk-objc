#import "BMYRevision.h"
#import "BMYSize.h"
#import "BMYTime.h"
#import "BMYUser.h"

@implementation BMYRevision

@synthesize version;
@synthesize md5;
@synthesize size;
@synthesize modified_at;
@synthesize modified_by;
@synthesize client_modified_at;


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        version = [[dict objectForKey:@"version"] longValue];
        md5 = [dict objectForKey:@"md5"];

        if ([dict objectForKey:@"size"]) {
            size = [[BMYSize alloc] initWithDictionary:[dict objectForKey:@"size"]];
        }

        if ([dict objectForKey:@"modified_at"]) {
            modified_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"modified_at"]];
        }

        if ([dict objectForKey:@"modified_by"]) {
            modified_by = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"modified_by"]];
        }

        if ([dict objectForKey:@"client_modified_at"]) {
            client_modified_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"client_modified_at"]];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithLong:version] forKey:@"version"];
    [aCoder encodeObject:md5 forKey:@"md5"];

    if (size) {
        [aCoder encodeObject:size forKey:@"size"];
    }

    if (modified_at) {
        [aCoder encodeObject:modified_at forKey:@"modified_at"];
    }

    if (modified_by) {
        [aCoder encodeObject:modified_by forKey:@"modified_by"];
    }

    if (client_modified_at) {
        [aCoder encodeObject:client_modified_at forKey:@"client_modified_at"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    version = [[aDecoder decodeObjectForKey:@"version"] longValue];
    md5 = [aDecoder decodeObjectForKey:@"md5"];

    if ([aDecoder containsValueForKey:@"size"]) {
        size = [aDecoder decodeObjectForKey:@"size"];
    }

    if ([aDecoder containsValueForKey:@"modified_at"]) {
        modified_at = [aDecoder decodeObjectForKey:@"modified_at"];
    }

    if ([aDecoder containsValueForKey:@"modified_by"]) {
        modified_by = [aDecoder decodeObjectForKey:@"modified_by"];
    }

    if ([aDecoder containsValueForKey:@"client_modified_at"]) {
        client_modified_at = [aDecoder decodeObjectForKey:@"client_modified_at"];
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *revisionDict = [NSMutableDictionary dictionary];

    [revisionDict setObject:[NSNumber numberWithLong:version] forKey:@"version"];

    if (md5) {
        [revisionDict setObject:md5 forKey:@"md5"];
    }

    if (size) {
        [revisionDict setObject:size forKey:@"size"];
    }

    if (modified_at) {
        [revisionDict setObject:modified_at forKey:@"modified_at"];
    }

    if (modified_by) {
        [revisionDict setObject:modified_by forKey:@"modified_by"];
    }

    if (client_modified_at) {
        [revisionDict setObject:client_modified_at forKey:@"client_modified_at"];
    }

    return revisionDict;
}

@end
