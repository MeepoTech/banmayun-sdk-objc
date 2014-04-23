//
//  BMYPermission.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYPermission : NSObject<NSCoding>
{
    BOOL    insertable_to_owner;            // can create new file or not in this folder for the owner
    BOOL    readable_to_owner;              // can read the file or not for the owner
    BOOL    writable_to_owner;              // can update the file or not for the owner
    BOOL    deletable_to_owner;             // can delete the file or not for the owner
    BOOL    insertable_to_others;           // can create new file or not in this folder for the others
    BOOL    readable_to_others;             // can read the file or not for the others
    BOOL    writable_to_others;             // can update the file or not for the others
    BOOL    deletable_to_others;            // can delete the file or not for the others
}


@property (nonatomic, readonly)BOOL insertable_to_owner;
@property (nonatomic, readonly)BOOL readable_to_owner;
@property (nonatomic, readonly)BOOL writable_to_owner;
@property (nonatomic, readonly)BOOL deletable_to_owner;
@property (nonatomic, readonly)BOOL insertable_to_others;
@property (nonatomic, readonly)BOOL readable_to_others;
@property (nonatomic, readonly)BOOL writable_to_others;
@property (nonatomic, readonly)BOOL deletable_to_others;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
