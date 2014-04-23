#import "BMYJsonBase.h"

/**
   @brief Options for the writer class.

   This exists so the BMYJson facade can implement the options in the writer without having to re-declare them.
 */
@protocol BMYJsonWriter

/**
   @brief Whether we are generating human-readable (multiline) Json.

   Set whether or not to generate human-readable Json. The default is NO, which produces
   Json without any whitespace. (Except inside strings.) If set to YES, generates human-readable
   Json with linebreaks after each array value and dictionary key/value pair, indented two
   spaces per nesting level.
 */
@property BOOL humanReadable;

/**
   @brief Whether or not to sort the dictionary keys in the output.

   If this is set to YES, the dictionary keys in the Json output will be in sorted order.
   (This is useful if you need to compare two structures, for example.) The default is NO.
 */
@property BOOL sortKeys;

/**
   @brief Return Json representation (or fragment) for the given object.

   Returns a string containing Json representation of the passed in value, or nil on error.
   If nil is returned and @p error is not NULL, @p *error can be interrogated to find the cause of the error.

   @param value any instance that can be represented as a Json fragment

 */
- (NSString *)stringWithObject:(id)value;

@end


/**
   @brief The Json writer class.

   Objective-C types are mapped to Json types in the following way:

   @li NSNull -> Null
   @li NSString -> String
   @li NSArray -> Array
   @li NSDictionary -> Object
   @li NSNumber (-initWithBool:) -> Boolean
   @li NSNumber -> Number

   In Json the keys of an object must be strings. NSDictionary keys need
   not be, but attempting to convert an NSDictionary with non-string keys
   into Json will throw an exception.

   NSNumber instances created with the +initWithBool: method are
   converted into the Json boolean "true" and "false" values, and vice
   versa. Any other NSNumber instances are converted to a Json number the
   way you would expect.

 */
@interface BMYJsonWriter : BMYJsonBase <BMYJsonWriter> {
    @private
    BOOL sortKeys, humanReadable;
}

@end

// don't use - exists for backwards compatibility. Will be removed in 2.3.
@interface BMYJsonWriter (Private)
- (NSString *)stringWithFragment:(id)value;
@end

/**
   @brief Allows generation of Json for otherwise unsupported classes.

   If you have a custom class that you want to create a Json representation for you can implement
   this method in your class. It should return a representation of your object defined
   in terms of objects that can be translated into Json. For example, a Person
   object might implement it like this:

   @code
   - (id)jsonProxyObject {
   return [NSDictionary dictionaryWithObjectsAndKeys:
   name, @"name",
   phone, @"phone",
   email, @"email",
   nil];
   }
   @endcode

 */
@interface NSObject (SBProxyForJson)
- (id)proxyForJson;
@end
