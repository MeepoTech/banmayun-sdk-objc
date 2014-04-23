#import <Foundation/Foundation.h>

@interface BMYUserRole : NSObject<NSCoding>
{
    NSString *name;                 // simple name string, value can be "root", "admin" or "user"
    NSString *display_value;        // concrete description info
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *display_value;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
