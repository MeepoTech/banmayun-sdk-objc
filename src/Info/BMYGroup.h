//
//  BMYGroup.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYGroupType;
@class BMYTime;
@class BMYUser;
@class BMYRelation;
@class BMYRoot;

@interface BMYGroup : NSObject<NSCoding>
{
    NSString        *groupId;                   // group id
    NSString        *root_id;                   // root id of group's space
    NSString        *name;                      // group name
    NSString        *source;                    // source
    BMYGroupType    *type;                      // group type
    NSString        *intro;                     // introduction
    NSString        *tags;                      // group's tag
    NSString        *announce;                  // group announcement
    BOOL            is_visible;                 // is visible to search or not
    BOOL            is_activated;               // is activated or not
    BOOL            is_blocked;                 // is blocked or not
    NSInteger       user_count;                 // members count
    BMYTime         *created_at;                // created time
    BMYUser         *created_by;                // created user info
    BMYRelation     *relation;                  // relation between group and the user
    BMYRoot         *root;                      // root of the group
}


@property (nonatomic, readonly) NSString        *groupId;
@property (nonatomic, readonly) NSString        *root_id;
@property (nonatomic, readonly) NSString        *name;
@property (nonatomic, readonly) NSString        *source;
@property (nonatomic, readonly) BMYGroupType    *type;
@property (nonatomic, readonly) NSString        *intro;
@property (nonatomic, readonly) NSString        *tags;
@property (nonatomic, readonly) NSString        *announce;
@property (nonatomic, readonly) BOOL            is_visible;
@property (nonatomic, readonly) BOOL            is_activated;
@property (nonatomic, readonly) BOOL            is_blocked;
@property (nonatomic, readonly) NSInteger       user_count;
@property (nonatomic, readonly) BMYTime         *created_at;
@property (nonatomic, readonly) BMYUser         *created_by;
@property (nonatomic, readonly) BMYRelation     *relation;
@property (nonatomic, readonly) BMYRoot         *root;



- (id)initWithDictionary:(NSDictionary *)dict;

@end
