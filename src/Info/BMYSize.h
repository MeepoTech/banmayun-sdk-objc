//
//  BMYSize.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYSize : NSObject<NSCoding>
{
    long        bytes;                      // bytes count
    NSString    *display_value;             // value used for displaying
}


- (id)initWithDictionary:(NSDictionary *)dict;


@property (nonatomic, readonly)long bytes;
@property (nonatomic, readonly)NSString *display_value;

@end
