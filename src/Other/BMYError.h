//
//  BMYError.h
//  BanMaYunSDK
//
//  Created by MeePoTech on 14-4-4.
//  Copyright (c) 2014年 MeePoTech. All rights reserved.
//

#import <Foundation/Foundation.h>


// This file contains error codes and the HTTP status code if less than 1000
extern NSString *BMYErrorDomain;


// Error codes in the banmayun.com domain represent the HTTP status code if less than 1000
typedef enum
{
    BMYErrorNone = 0,
    BMYErrorGenericError = 1000,
    BMYErrorFileNotFound,
    BMYErrorInsufficientDiskSpace,
    BMYErrorIllegalFileType,         // Error sent if you try to upload a directory
    BMYErrorInvalidResponse,         // Sent when the client does not get valid JSON when it's expecting it
}BMYErrorCode;
