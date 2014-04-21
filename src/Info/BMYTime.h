//
//  BMYTime.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYTime : NSObject<NSCoding>
{
//    NSString    *rfc1123;               // timestamp of rfc1123's format
    long long        millis;                 // timestamp:from 1970-1-1 00:00:00
    NSString    *display_value;         // timestamp used for displaying
}


//@property (nonatomic, readonly)NSString *rfc1123;

@property (nonatomic, readonly)long long    millis;
@property (nonatomic, readonly)NSString *display_value;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
