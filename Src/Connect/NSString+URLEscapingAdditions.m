#import "NSString+URLEscapingAdditions.h"

@implementation NSString (BMYURLEscapingAdditions)

- (BOOL)isIPAddress {
    BOOL isIPAddress = NO;
    NSArray *components = [self componentsSeparatedByString:@"."];
    NSCharacterSet *invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];

    if ([components count] == 4) {
        NSString *part1 = [components objectAtIndex:0];
        NSString *part2 = [components objectAtIndex:1];
        NSString *part3 = [components objectAtIndex:2];
        NSString *part4 = [components objectAtIndex:3];

        if ([part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound) {
            if ([part1 intValue] < 255 &&
                [part2 intValue] < 255 &&
                [part3 intValue] < 255 &&
                [part4 intValue] < 255) {
                isIPAddress = YES;
            }
        }
    }

    return isIPAddress;
}

- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding {
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)@":/?=,!$&'()*+;[]@#", CFStringConvertNSStringEncodingToEncoding(inEncoding)));

    return escapedString;
}

@end


@implementation NSURL (BMYURLEscapingAdditions)

- (NSString *)stringByAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding {
    return [[self absoluteString] stringByAddingURIPercentEscapesUsingEncoding:inEncoding];
}

@end
