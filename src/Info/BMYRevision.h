//
//  BMYRevision.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BMYSize;
@class BMYTime;
@class BMYUser;


@interface BMYRevision : NSObject<NSCoding>
{
    long        version;                // version number of the file
    NSString    *md5;                   // hex value of file's md5
    BMYSize     *size;                  // file size
    BMYTime     *modified_at;           // the last modified time of the file
    BMYUser     *modified_by;           // the last modified user's info
    BMYTime     *client_modified_at;    // the modified time provided by client end
}

@property (nonatomic,readonly)long      version;
@property (nonatomic,readonly)NSString  *md5;
@property (nonatomic,readonly)BMYSize   *size;
@property (nonatomic,readonly)BMYTime   *modified_at;
@property (nonatomic,readonly)BMYUser   *modified_by;
@property (nonatomic,readonly)BMYTime   *client_modified_at;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
