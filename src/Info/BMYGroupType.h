//
//  BMYGroupType.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYGroupType : NSObject<NSCoding>
{
    NSString    *name;              // simple name string, can be "private", "protected", "public", "system_public"
    NSString    *display_value;     // concrete description info
}

@property (nonatomic, readonly)NSString *name;
@property (nonatomic, readonly)NSString *display_value;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
