#import "BMYChunkedUpload.h"
#import "BMYTime.h"

@implementation BMYChunkedUpload

@synthesize chunkedUploadId;
@synthesize offset;
@synthesize expires_at;
@synthesize created_at;

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        chunkedUploadId = [dict objectForKey:@"id"];
        offset = [[dict objectForKey:@"offset"] longValue];

        if ([dict objectForKey:@"expires_at"]) {
            expires_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"expires_at"]];
        }

        if ([dict objectForKey:@"created_at"]) {
            created_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:chunkedUploadId forKey:@"id"];
    [aCoder encodeObject:[NSNumber numberWithLong:offset] forKey:@"offset"];

    if (expires_at) {
        [aCoder encodeObject:expires_at forKey:@"expires_at"];
    }

    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        chunkedUploadId = [aDecoder decodeObjectForKey:@"id"];
        offset = [[aDecoder decodeObjectForKey:@"offset"] longValue];

        if ([aDecoder containsValueForKey:@"expires_at"]) {
            expires_at = [aDecoder decodeObjectForKey:@"expires_at"];
        }

        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at = [aDecoder decodeObjectForKey:@"created_at"];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *chunkedUploadDict = [NSMutableDictionary dictionary];

    if (chunkedUploadId) {
        [chunkedUploadDict setObject:chunkedUploadId forKey:@"id"];
    }

    [chunkedUploadDict setObject:[NSNumber numberWithLong:offset] forKey:@"offset"];

    if (expires_at) {
        [chunkedUploadDict setObject:expires_at forKey:@"expires_at"];
    }

    if (created_at) {
        [chunkedUploadDict setObject:created_at forKey:@"created_at"];
    }

    return chunkedUploadDict;
}

@end
