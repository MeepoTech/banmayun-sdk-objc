#import "BMYPermission.h"

@implementation BMYPermission

@synthesize insertable_to_owner;
@synthesize readable_to_owner;
@synthesize writable_to_owner;
@synthesize deletable_to_owner;
@synthesize insertable_to_others;
@synthesize readable_to_others;
@synthesize writable_to_others;
@synthesize deletable_to_others;


- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        insertable_to_owner = [[dict objectForKey:@"insertable_to_owner"] boolValue];
        readable_to_owner = [[dict objectForKey:@"readable_to_owner"] boolValue];
        writable_to_owner = [[dict objectForKey:@"writalbe_to_owner"] boolValue];
        deletable_to_owner = [[dict objectForKey:@"deletable_to_owner"] boolValue];

        insertable_to_others = [[dict objectForKey:@"insertable_to_others"] boolValue];
        readable_to_others = [[dict objectForKey:@"readable_to_others"] boolValue];
        writable_to_others = [[dict objectForKey:@"writable_to_others"] boolValue];
        deletable_to_others = [[dict objectForKey:@"deletable_to_others"] boolValue];
    }

    return self;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:insertable_to_owner forKey:@"insertable_to_owner"];
    [aCoder encodeBool:readable_to_owner forKey:@"readable_to_owner"];
    [aCoder encodeBool:writable_to_owner forKey:@"writable_to_owner"];
    [aCoder encodeBool:deletable_to_owner forKey:@"deletable_to_owner"];

    [aCoder encodeBool:insertable_to_others forKey:@"insertable_to_others"];
    [aCoder encodeBool:readable_to_others forKey:@"readable_to_others"];
    [aCoder encodeBool:writable_to_others forKey:@"writable_to_others"];
    [aCoder encodeBool:deletable_to_others forKey:@"deletable_to_others"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        insertable_to_owner = [aDecoder decodeBoolForKey:@"insertable_to_owner"];
        readable_to_owner = [aDecoder decodeBoolForKey:@"readable_to_owner"];
        writable_to_owner = [aDecoder decodeBoolForKey:@"writable_to_owner"];
        deletable_to_owner = [aDecoder decodeBoolForKey:@"deletable_to_owner"];

        insertable_to_others = [aDecoder decodeBoolForKey:@"insertable_to_others"];
        readable_to_others = [aDecoder decodeBoolForKey:@"readable_to_others"];
        writable_to_others = [aDecoder decodeBoolForKey:@"writable_to_others"];
        deletable_to_others = [aDecoder decodeBoolForKey:@"deletable_to_others"];
    }

    return self;
}

#pragma mark -
#pragma mark - Method for Json

- (id)proxyForJson {
    NSMutableDictionary *permissionDict = [NSMutableDictionary dictionary];

    [permissionDict setObject:[NSNumber numberWithBool:insertable_to_owner] forKey:@"insertable_to_owner"];
    [permissionDict setObject:[NSNumber numberWithBool:readable_to_owner] forKey:@"readable_to_owner"];
    [permissionDict setObject:[NSNumber numberWithBool:writable_to_owner] forKey:@"writable_to_owner"];
    [permissionDict setObject:[NSNumber numberWithBool:deletable_to_owner] forKey:@"deletable_to_owner"];
    [permissionDict setObject:[NSNumber numberWithBool:insertable_to_others] forKey:@"insertable_to_owner"];
    [permissionDict setObject:[NSNumber numberWithBool:readable_to_others] forKey:@"readable_to_others"];
    [permissionDict setObject:[NSNumber numberWithBool:writable_to_others] forKey:@"writable_to_others"];
    [permissionDict setObject:[NSNumber numberWithBool:deletable_to_others] forKey:@"deletable_to_others"];
    return permissionDict;
}

@end
