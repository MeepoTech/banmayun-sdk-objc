#import "NSString+BMYJson.h"
#import "BMYJsonParser.h"

@implementation NSString (NSString_BMYJson)

- (id)JsonFragmentValue {
    BMYJsonParser *jsonParser = [BMYJsonParser new];
    id repr = [jsonParser fragmentWithString:self];

    if (!repr) {
        NSLog(@"-JsonFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
    }

    [jsonParser release];
    return repr;
}

- (id)JsonValue {
    BMYJsonParser *jsonParser = [BMYJsonParser new];
    id repr = [jsonParser objectWithString:self];

    if (!repr) {
        NSLog(@"-JsonValue failed. Error trace is: %@", [jsonParser errorTrace]);
    }

    [jsonParser release];
    return repr;
}

@end
