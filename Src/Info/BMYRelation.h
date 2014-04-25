#import <Foundation/Foundation.h>

@class BMYRelationRole;
@class BMYTime;

@interface BMYRelation : NSObject<NSCoding> {
    BMYRelationRole *role;  // User's relation in the group
    BOOL is_activated;      // is already activated
    BOOL is_blocked;        // is blocked
    NSString *remarks;      // remark info
    BMYTime *created_at;    // created time
}

@property(nonatomic, readonly) BMYRelationRole *role;
@property(nonatomic, readonly) BOOL is_activated;
@property(nonatomic, readonly) BOOL is_blocked;
@property(nonatomic, readonly) NSString *remarks;
@property(nonatomic, readonly) BMYTime *created_at;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
