//
//  BMYRelationRole.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYRelationRole : NSObject<NSCoding>
{
    NSString    *name;                  // simple name string, value can be "owner", "admin", "member"
    NSString    *display_value;         // concrete description info
}


@property (nonatomic, readonly)NSString     *name;
@property (nonatomic, readonly)NSString     *display_value;

- (id)initWithDictionary:(NSDictionary *)dict;


@end
