//
//  BMYLink.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYTime;

@interface BMYLink : NSObject<NSCoding>
{
    NSString    *userId;            // user id
    NSString    *deviceId;          // device id
    NSString    *name;              // device name
    NSString    *device;            // device type
    NSString    *token;             // token
    BMYTime     *expires_at;        // expires time
    BMYTime     *created_at;        // created time
    BOOL        is_current;         // is current device or not
}

@property (nonatomic, readonly)NSString *userId;
@property (nonatomic, readonly)NSString *deviceId;
@property (nonatomic, readonly)NSString *name;
@property (nonatomic, readonly)NSString *device;
@property (nonatomic, readonly)NSString *token;
@property (nonatomic, readonly)BMYTime  *expires_at;
@property (nonatomic, readonly)BMYTime  *created_at;
@property (nonatomic, readonly)BOOL     is_current;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
