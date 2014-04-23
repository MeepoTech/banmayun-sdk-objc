//
//  BMYUser.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BMYUserRole;
@class BMYTime;
@class BMYRelation;
@class BMYRoot;

@interface BMYUser : NSObject<NSCoding>
{
    NSString    *userId;            // User's id
    NSString    *root_id;           // Root id of User's personal space
    NSString    *name;              // User's name
    NSString    *email;             // User's email
    NSString    *source;            // source
    NSString    *display_name;      // nickname
    BMYUserRole *role;              // role
    NSInteger   groups_can_own;     // the maximum count of groups can own
    BOOL        is_activated;       // is activated
    BOOL        is_blocked;         // is blocked
    NSInteger   group_count;        // all groups count that user is a member
    BMYTime     *created_at;        // created time
    BMYRelation *relation;          // relationship between user and group
    BMYRoot     *root;              // root of user's personal space
}


@property (nonatomic, readonly)NSString     *userId;
@property (nonatomic, readonly)NSString     *root_id;
@property (nonatomic, readonly)NSString     *name;
@property (nonatomic, readonly)NSString     *email;
@property (nonatomic, readonly)NSString     *source;
@property (nonatomic, readonly)NSString     *display_name;
@property (nonatomic, readonly)BMYUserRole  *role;
@property (nonatomic, readonly)NSInteger    groups_can_own;
@property (nonatomic, readonly)BOOL         is_activated;
@property (nonatomic, readonly)BOOL         is_blocked;
@property (nonatomic, readonly)NSInteger    group_count;
@property (nonatomic, readonly)BMYTime      *created_at;
@property (nonatomic, readonly)BMYRelation  *relation;
@property (nonatomic, readonly)BMYRoot      *root;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
