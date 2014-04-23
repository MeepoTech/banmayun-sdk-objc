#import "BMYGroup.h"
#import "BMYGroupType.h"
#import "BMYTime.h"
#import "BMYUser.h"
#import "BMYRelation.h"
#import "BMYRoot.h"

@implementation BMYGroup

@synthesize groupId;
@synthesize root_id;
@synthesize name;
@synthesize source;
@synthesize type;
@synthesize intro;
@synthesize tags;
@synthesize announce;
@synthesize is_visible;
@synthesize is_activated;
@synthesize is_blocked;
@synthesize user_count;
@synthesize created_at;
@synthesize created_by;
@synthesize relation;
@synthesize root;


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        groupId = [dict objectForKey:@"id"];
        root_id = [dict objectForKey:@"root_id"];
        name = [dict objectForKey:@"name"];
        source = [dict objectForKey:@"source"];

        if ([dict objectForKey:@"type"]) {
            type = [[BMYGroupType alloc] initWithDictionary:[dict objectForKey:@"type"]];
        }

        intro = [dict objectForKey:@"intro"];
        tags = [dict objectForKey:@"tags"];
        announce = [dict objectForKey:@"announce"];
        is_visible = [[dict objectForKey:@"is_visible"] boolValue];
        is_activated = [[dict objectForKey:@"is_activated"] boolValue];
        is_blocked = [[dict objectForKey:@"is_blocked"] boolValue];
        user_count = [[dict objectForKey:@"user_count"] integerValue];

        if ([dict objectForKey:@"created_at"]) {
            created_at = [[BMYTime alloc] initWithDictionary:[dict objectForKey:@"created_at"]];
        }

        if ([dict objectForKey:@"created_by"]) {
            created_by = [[BMYUser alloc] initWithDictionary:[dict objectForKey:@"created_by"]];
        }

        if ([dict objectForKey:@"relation"]) {
            relation = [[BMYRelation alloc] initWithDictionary:[dict objectForKey:@"relation"]];
        }

        if ([dict objectForKey:@"root"]) {
            root = [[BMYRoot alloc] initWithDictionary:[dict objectForKey:@"root"]];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:groupId forKey:@"id"];
    [aCoder encodeObject:root_id forKey:@"root_id"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:source forKey:@"source"];

    if (type) {
        [aCoder encodeObject:type forKey:@"type"];
    }

    [aCoder encodeObject:intro forKey:@"intro"];
    [aCoder encodeObject:tags forKey:@"tags"];
    [aCoder encodeObject:announce forKey:@"announce"];
    [aCoder encodeBool:is_visible forKey:@"is_visible"];
    [aCoder encodeBool:is_activated forKey:@"is_activated"];
    [aCoder encodeBool:is_blocked forKey:@"is_blocked"];
    [aCoder encodeInteger:user_count forKey:@"user_count"];

    if (created_at) {
        [aCoder encodeObject:created_at forKey:@"created_at"];
    }

    if (created_by) {
        [aCoder encodeObject:created_by forKey:@"created_by"];
    }

    if (relation) {
        [aCoder encodeObject:relation forKey:@"relation"];
    }

    if (root) {
        [aCoder encodeObject:root forKey:@"root"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        groupId = [aDecoder decodeObjectForKey:@"id"];
        root_id = [aDecoder decodeObjectForKey:@"root_id"];
        name = [aDecoder decodeObjectForKey:@"name"];
        source = [aDecoder decodeObjectForKey:@"source"];

        if ([aDecoder containsValueForKey:@"type"]) {
            type = [aDecoder decodeObjectForKey:@"type"];
        }

        intro = [aDecoder decodeObjectForKey:@"intro"];
        tags = [aDecoder decodeObjectForKey:@"tags"];
        announce = [aDecoder decodeObjectForKey:@"announce"];
        is_visible = [aDecoder decodeBoolForKey:@"is_visible"];
        is_activated = [aDecoder decodeBoolForKey:@"is_activated"];
        is_blocked = [aDecoder decodeBoolForKey:@"is_blocked"];
        user_count = [aDecoder decodeIntegerForKey:@"user_count"];

        if ([aDecoder containsValueForKey:@"created_at"]) {
            created_at = [aDecoder decodeObjectForKey:@"created_at"];
        }

        if ([aDecoder containsValueForKey:@"created_by"]) {
            created_by = [aDecoder decodeObjectForKey:@"created_by"];
        }

        if ([aDecoder containsValueForKey:@"relation"]) {
            relation = [aDecoder decodeObjectForKey:@"relation"];
        }

        if ([aDecoder containsValueForKey:@"root"]) {
            root = [aDecoder decodeObjectForKey:@"root"];
        }
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];

    if (groupId) {
        [groupDict setObject:groupId forKey:@"id"];
    }

    if (root_id) {
        [groupDict setObject:root_id forKey:@"root_id"];
    }

    if (name) {
        [groupDict setObject:name forKey:@"name"];
    }

    if (source) {
        [groupDict setObject:source forKey:@"source"];
    }

    if (type) {
        [groupDict setObject:type forKey:@"type"];
    }

    if (intro) {
        [groupDict setObject:intro forKey:@"intro"];
    }

    if (tags) {
        [groupDict setObject:tags forKey:@"tags"];
    }

    if (announce) {
        [groupDict setObject:announce forKey:@"announce"];
    }

    [groupDict setObject:[NSNumber numberWithBool:is_visible] forKey:@"is_visible"];
    [groupDict setObject:[NSNumber numberWithBool:is_activated] forKey:@"is_activated"];
    [groupDict setObject:[NSNumber numberWithBool:is_blocked] forKey:@"is_blocked"];
    [groupDict setObject:[NSNumber numberWithInteger:user_count] forKey:@"user_count"];

    if (created_at) {
        [groupDict setObject:created_at forKey:@"created_at"];
    }

    if (created_by) {
        [groupDict setObject:created_by forKey:@"created_by"];
    }

    if (relation) {
        [groupDict setObject:relation forKey:@"relation"];
    }

    if (root) {
        [groupDict setObject:root forKey:@"root"];
    }

    return groupDict;
}

@end
