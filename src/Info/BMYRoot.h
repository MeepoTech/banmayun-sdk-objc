//
//  BMYRoot.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYSize;
@class BMYPermission;

@interface BMYRoot : NSObject<NSCoding>
{
    NSString        *rootId;                    // root id
    NSString        *type;                      // value can be "user", "group"
    BMYSize         *used;                      // Used Space Size
    BMYSize         *quota;                     // Space quota
    BMYPermission   *default_permission;        // default permission info
    NSInteger       file_count;                 // all files count
    long            byte_count;                 // bytes count
}

@property (nonatomic, readonly)NSString         *rootId;
@property (nonatomic, readonly)NSString         *type;
@property (nonatomic, readonly)BMYSize          *used;
@property (nonatomic, readonly)BMYSize          *quota;
@property (nonatomic, readonly)BMYPermission    *default_permission;
@property (nonatomic, readonly)NSInteger        file_count;
@property (nonatomic, readonly)long             byte_count;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
