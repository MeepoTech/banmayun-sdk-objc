#import <Foundation/Foundation.h>

@interface NSString (BMYURLEscapingAdditions)

- (BOOL)isIPAddress;
- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end

@interface NSURL (BMYURLEscapingAdditions)

- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end
