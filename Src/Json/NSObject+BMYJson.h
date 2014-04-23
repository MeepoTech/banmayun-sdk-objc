#import <Foundation/Foundation.h>

/**
   @brief Adds Json generation to Foundation classes

   This is a category on NSObject that adds methods for returning Json representations
   of standard objects to the objects themselves. This means you can call the
   -JsonRepresentation method on an NSArray object and it'll do what you want.
 */
@interface NSObject (NSObject_BMYJson)

/**
   @brief Returns a string containing the receiver encoded as a Json fragment.

   This method is added as a category on NSObject but is only actually
   supported for the following objects:
   @li NSDictionary
   @li NSArray
   @li NSString
   @li NSNumber (also used for booleans)
   @li NSNull

   @deprecated Given we bill ourselves as a "strict" Json library, this method should be removed.
 */
- (NSString *)JsonFragment;

/**
   @brief Returns a string containing the receiver encoded in Json.

   This method is added as a category on NSObject but is only actually
   supported for the following objects:
   @li NSDictionary
   @li NSArray
 */
- (NSString *)JsonRepresentation;

@end
