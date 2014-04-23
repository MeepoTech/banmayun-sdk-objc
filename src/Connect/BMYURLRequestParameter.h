//
//  BMYURLRequestParameter.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
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
