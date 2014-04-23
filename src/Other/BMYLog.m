//
//  BMYLog.m
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYLog.h"

#define LOG_FILE_PATH @"/tmp/run.log"

static BMYLogLevel LogLevel = BMYLogLevelWarning;
static BMYLogCallback *callback = NULL;


NSString* BMYStringFromLevel(BMYLogLevel logLevel)
{
    switch (logLevel) {
        case BMYLogLevelInfo: return @"INFO";
        case BMYLogLevelAnalytics: return @"ANALYTICS";
        case BMYLogLevelWarning: return @"WARNING";
        case BMYLogLevelError: return @"ERROR";
        case BMYLogLevelFatal: return @"FATAL";
        default:
            break;
    }
    return @"";
}


NSString* BMYLogFilePath()
{
    static NSString *logFilePath;
    if (logFilePath == nil) {
        logFilePath = [NSHomeDirectory() stringByAppendingString:LOG_FILE_PATH];
    }
    return logFilePath;
}


void BMYSetupLogToFile()
{
    freopen([BMYLogFilePath() fileSystemRepresentation], "w", stderr);
}


static NSString* BMYLogFormatPrefix(BMYLogLevel logLevel)
{
    return [NSString stringWithFormat:@"[%@]", BMYStringFromLevel(logLevel)];
}


void BMYLogSetLevel(BMYLogLevel logLevel)
{
    LogLevel = logLevel;
}


void BMYLogSetCallback(BMYLogCallback *acallback)
{
    callback = acallback;
}


static void BMYLogv(BMYLogLevel logLevel, NSString *format, va_list args)
{
    if (logLevel >= LogLevel) {
        format = [BMYLogFormatPrefix(logLevel) stringByAppendingString:format];
        NSLogv(format, args);
        if (callback) {
            callback(logLevel, format, args);
        }
    }
}


void BMYLog(BMYLogLevel logLevel, NSString *format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    BMYLogv(logLevel, format, argptr);
    va_end(argptr);
}


void BMYLogWarning(NSString* format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    BMYLogv(BMYLogLevelWarning, format, argptr);
    va_end(argptr);
}


void BMYLogError(NSString* format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    BMYLogv(BMYLogLevelError, format, argptr);
    va_end(argptr);
}


void BMYLogFatal(NSString *format, ...)
{
    va_list argptr;
    va_start(argptr, format);
    BMYLogv(BMYLogLevelFatal, format, argptr);
    va_end(argptr);
}



