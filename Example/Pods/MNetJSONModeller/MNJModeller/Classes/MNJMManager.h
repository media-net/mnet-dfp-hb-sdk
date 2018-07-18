//
//  MNJMManager.h
//  Pods
//
//  Created by akshay.d on 17/02/17.
//
//

#import "MNJMMapperProtocol.h"
#import <Foundation/Foundation.h>

@interface MNJMManager : NSObject

/// Convert a given object into json-str. If the object or any of it's internal keys implement the
/// MNJMMapper protocol, they'll be parsed accordingly.
+ (NSString *)toJSONStr:(id)object;

/// Converts the given json-string into an object. The object Note that the object cannot be nil.
+ (void)fromJSONStr:(NSString *)jsonString toObj:(id<MNJMMapperProtocol>)object;

/// Converts a given source a dictionary to an object.
+ (void)fromDict:(NSDictionary *)dict toObject:(id<MNJMMapperProtocol>)object;

/// Creates a NSArray or a NSDictionary for the given object.
+ (id)getCollectionFromObj:(id)object;

@end
