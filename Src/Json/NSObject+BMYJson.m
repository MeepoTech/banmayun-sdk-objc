#import "NSObject+BMYJson.h"
#import "BMYJsonWriter.h"

@implementation NSObject (NSObject_BMYJson)

- (NSString *)JsonFragment {
    BMYJsonWriter *jsonWriter = [BMYJsonWriter new];
    NSString *json = [jsonWriter stringWithFragment:self];

    if (!json) {
        NSLog(@"-JsonFragment failed. Error trace is: %@", [jsonWriter errorTrace]);
    }

    [jsonWriter release];
    return json;
}

- (NSString *)JsonRepresentation {
    BMYJsonWriter *jsonWriter = [BMYJsonWriter new];
    NSString *json = [jsonWriter stringWithObject:self];

    if (!json) {
        NSLog(@"-JsonRepresentation failed. Error trace is: %@", [jsonWriter errorTrace]);
    }

    [jsonWriter release];
    return json;
}

@end
