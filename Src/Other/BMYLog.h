#import <Foundation/Foundation.h>

#if !defined(NS_FORMAT_FUNCTION)
#define NS_FORMAT_FUNCTION(F, A)
#endif

typedef enum {
    BMYLogLevelInfo = 0,
    BMYLogLevelAnalytics,
    BMYLogLevelWarning,
    BMYLogLevelError,
    BMYLogLevelFatal
} BMYLogLevel;

typedef void BMYLogCallback(BMYLogLevel level, NSString *format, va_list args);

NSString *BMYLogFilePath(void);
void BMYSetupLogToFile(void);

NSString *BMYStringFromLogLevel(BMYLogLevel logLevel);

void BMYLogSetLevel(BMYLogLevel logLevel);
void BMYLogSetCallback(BMYLogCallback *callback);

void BMYLog(BMYLogLevel logLevel, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);
void BMYLogInfo(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
void BMYLogWarning(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
void BMYLogError(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
void BMYLogFatal(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
