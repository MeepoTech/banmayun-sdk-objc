#import "BMYJsonBase.h"
#import "BMYJsonParser.h"
#import "BMYJsonWriter.h"

/**
   @brief Facade for BMYJsonWriter/BMYJsonParser.

   Requests are forwarded to instances of BMYJsonWriter and BMYJsonParser.
 */
@interface BMYJson : BMYJsonBase<BMYJsonParser, BMYJsonWriter> {
   @private
    BMYJsonParser *jsonParser;
    BMYJsonWriter *jsonWriter;
}

// Return the fragment represented by the given string
- (id)fragmentWithString:(NSString *)jsonrep error:(NSError **)error;

// Return the object represented by the given string
- (id)objectWithString:(NSString *)jsonrep error:(NSError **)error;

// Parse the string and return the represented object (or scalar)
- (id)objectWithString:(id)value allowScalar:(BOOL)x error:(NSError **)error;

// Return Json representation of an array  or dictionary
- (NSString *)stringWithObject:(id)value error:(NSError **)error;

// Return Json representation of any legal Json value
- (NSString *)stringWithFragment:(id)value error:(NSError **)error;

// Return Json representation (or fragment) for the given object
- (NSString *)stringWithObject:(id)value allowScalar:(BOOL)x error:(NSError **)error;

@end
