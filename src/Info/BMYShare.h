//
//  BMYShare.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYTime;
@class BMYUser;
@class BMYMetadata;

@interface BMYShare : NSObject<NSCoding>
{
    NSString        *shareId;               // id of forward link
    NSString        *root_id;               // root id of the space
    NSString        *meta_id;               // id of the metadata
    BMYTime         *expires_at;            // expires time
    BMYTime         *created_at;            // created time
    BMYUser         *created_by;            // creator info
    BMYMetadata     *meta;                  // metadata info
}

@property (nonatomic, readonly)NSString     *shareId;
@property (nonatomic, readonly)NSString     *root_id;
@property (nonatomic, readonly)NSString     *meta_id;
@property (nonatomic, readonly)BMYTime      *expires_at;
@property (nonatomic, readonly)BMYTime      *created_at;
@property (nonatomic, readonly)BMYUser      *created_by;
@property (nonatomic, readonly)BMYMetadata  *meta;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
