//
//  NSString+URLEscapingAdditions.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BMYURLEscapingAdditions)

- (BOOL)isIPAddress;
- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end


@interface NSURL (BMYURLEscapingAdditions)

- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end
