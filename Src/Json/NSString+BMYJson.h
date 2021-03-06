#import <Foundation/Foundation.h>

/**
   @brief Adds Json parsing methods to NSString

   This is a category on NSString that adds methods for parsing the target string.
 */
@interface NSString (NSString_BMYJson)

/**
   @brief Returns the object represented in the receiver, or nil on error.

   Returns a a scalar object represented by the string's Json fragment representation.

   @deprecated Given we bill ourselves as a "strict" Json library, this method should be removed.
 */
- (id)JsonFragmentValue;

/**
   @brief Returns the NSDictionary or NSArray represented by the current string's Json representation.

   Returns the dictionary or array represented in the receiver, or nil on error.

   Returns the NSDictionary or NSArray represented by the current string's Json representation.
 */
- (id)JsonValue;

@end
