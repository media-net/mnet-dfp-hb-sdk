//
//  MNJMMapperProtocol.h
//  Pods
//
//  Created by nithin.g on 08/10/17.
//
//

#import "MNJMCollectionsInfo.h"
#import <Foundation/Foundation.h>

@protocol MNJMMapperProtocol <NSObject>
@optional

/// This method returns a dictionary of property-json key name bindings.
/// This is useful when we need the property to be something else in the parsed json, or
/// even when we parse from json to object.
- (NSDictionary<NSString *, NSString *> *)propertyKeyMap;

/// During json->object map, The type of the collections object cannot be found a runtime
/// (this is because of type-erasure). This method basically mentions this explicitly, to
/// help the parser get the correct type.
- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap;

/// During json->object map, we perform a lot of operations on the keys, like camel-casing it and detecting types.
/// The keys listed in the array returned by this method will by-pass all of the processing and will simply be mapped as
/// a dictionary would.
- (NSArray<NSString *> *)directMapForKeys;

@end
