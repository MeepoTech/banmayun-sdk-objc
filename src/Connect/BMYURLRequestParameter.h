//
//  BMYURLRequestParameter.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-4.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMYURLRequestParameter : NSObject
{
    NSString *_name;
    NSString *_value;
}

@property (nonatomic, readwrite, copy)NSString *name;
@property (nonatomic, readwrite, copy)NSString *value;


+ (NSArray *)parametersFromString:(NSString *)inString;
+ (NSArray *)parametersFromDictionary:(NSDictionary *)inDictionary;
+ (NSDictionary *)parameterDictionaryFromString:(NSString *)inString;
+ (NSString *)parameterStringForParameters:(NSArray *)inParameters;
+ (NSString *)parameterStringForDictionary:(NSDictionary *)inParameterDictionary;

- (id)initWithName:(NSString *)inName andValue:(NSString *)inValue;

- (NSString *)URLEncodedParameterString;

@end
