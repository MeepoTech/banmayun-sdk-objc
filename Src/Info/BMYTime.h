#import <Foundation/Foundation.h>

@interface BMYTime : NSObject<NSCoding> {
    long long millis;         // timestamp:from 1970-1-1 00:00:00
    NSString *display_value;  // timestamp used for displaying
}

@property(nonatomic, readonly) long long millis;
@property(nonatomic, readonly) NSString *display_value;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
