//
//  NSString+URLEscapingAdditions.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-4.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BMYURLEscapingAdditions)

- (BOOL)isIPAddress;
- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end


@interface NSURL (BMYURLEscapingAdditions)

- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end
