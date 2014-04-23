//
//  BMYJSON.h
//  BanmayunSDK
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "BMYJsonBase.h"
#import "BMYJsonParser.h"
#import "BMYJsonWriter.h"

/**
 @brief Facade for BMYJsonWriter/BMYJsonParser.
 
 Requests are forwarded to instances of BMYJsonWriter and BMYJsonParser.
 */
@interface BMYJSON : BMYJsonBase <BMYJsonParser, BMYJsonWriter> {
    
@private
    BMYJsonParser *jsonParser;
    BMYJsonWriter *jsonWriter;
}


/// Return the fragment represented by the given string
- (id)fragmentWithString:(NSString*)jsonrep
                   error:(NSError**)error;

/// Return the object represented by the given string
- (id)objectWithString:(NSString*)jsonrep
                 error:(NSError**)error;

/// Parse the string and return the represented object (or scalar)
- (id)objectWithString:(id)value
           allowScalar:(BOOL)x
    			 error:(NSError**)error;


/// Return JSON representation of an array  or dictionary
- (NSString*)stringWithObject:(id)value
                        error:(NSError**)error;

/// Return JSON representation of any legal JSON value
- (NSString*)stringWithFragment:(id)value
                          error:(NSError**)error;

/// Return JSON representation (or fragment) for the given object
- (NSString*)stringWithObject:(id)value
                  allowScalar:(BOOL)x
    					error:(NSError**)error;


@end
