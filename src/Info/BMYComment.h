//
//  BMYComment.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYTime;
@class BMYUser;

@interface BMYComment : NSObject<NSCoding>
{
    NSString        *commentId;             // comment id
    NSString        *root_id;               // root id of the space
    NSString        *meta_id;               // metadata id
    NSString        *contents;              // comment content
    BMYTime         *created_at;            // created time
    BMYUser         *created_by;            // creator info
}

@property (nonatomic, readonly)NSString     *commentId;
@property (nonatomic, readonly)NSString     *root_id;
@property (nonatomic, readonly)NSString     *meta_id;
@property (nonatomic, readonly)NSString     *contents;
@property (nonatomic, readonly)BMYTime      *created_at;
@property (nonatomic, readonly)BMYUser      *created_by;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
