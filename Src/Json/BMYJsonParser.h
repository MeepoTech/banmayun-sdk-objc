#import "BMYJsonBase.h"

/**
   @brief Options for the parser class.

   This exists so the BMYJson facade can implement the options in the parser without having to re-declare them.
 */
@protocol BMYJsonParser

/**
   @brief Return the object represented by the given string.

   Returns the object represented by the passed-in string or nil on error. The returned object can be
   a string, number, boolean, null, array or dictionary.

   @param repr the json string to parse
 */
- (id)objectWithString:(NSString *)repr;

@end

/**
   @brief The Json parser class.

   Json is mapped to Objective-C types in the following way:

   @li Null -> NSNull
   @li String -> NSMutableString
   @li Array -> NSMutableArray
   @li Object -> NSMutableDictionary
   @li Boolean -> NSNumber (initialised with -initWithBool:)
   @li Number -> NSDecimalNumber

   Since Objective-C doesn't have a dedicated class for boolean values, these turns into NSNumber
   instances. These are initialised with the -initWithBool: method, and
   round-trip back to Json properly. (They won't silently suddenly become 0 or 1; they'll be
   represented as 'true' and 'false' again.)

   Json numbers turn into NSDecimalNumber instances,
   as we can thus avoid any loss of precision. (Json allows ridiculously large numbers.)

 */
@interface BMYJsonParser : BMYJsonBase<BMYJsonParser> {
   @private
    const char *c;
}

@end

// don't use - exists for backwards compatibility with 2.1.x only. Will be removed in 2.3.
@interface BMYJsonParser (Private)
- (id)fragmentWithString:(id)repr;
@end