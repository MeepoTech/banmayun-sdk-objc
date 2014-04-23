//
//  BMYResultList.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYResultList : NSObject<NSCoding>
{
    NSInteger       total;          // total count of results
    NSInteger       offset;         // list's offset
    NSArray         *entries;       // contents
}


@property (nonatomic, readonly)NSInteger    total;
@property (nonatomic, readonly)NSInteger    offset;
@property (nonatomic, readonly)NSArray      *entries;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
