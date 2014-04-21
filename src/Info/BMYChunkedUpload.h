//
//  BMYChunkedUpload.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-9.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMYTime;

@interface BMYChunkedUpload : NSObject<NSCoding>
{
    NSString        *chunkedUploadId;       // chunked upload id
    long            offset;                 // offset
    BMYTime         *expires_at;            // expires time
    BMYTime         *created_at;            // created time
}

@property (nonatomic, readonly)NSString     *chunkedUploadId;
@property (nonatomic, readonly)long         offset;
@property (nonatomic, readonly)BMYTime      *expires_at;
@property (nonatomic, readonly)BMYTime      *created_at;


- (id)initWithDictionary:(NSDictionary *)dict;


@end
