//
//  MNetDfpAdSizeHelper.h
//  MNetAdSdk
//
//  Created by nithin.g on 04/05/18.
//

#import "MNetBaseAdSdk/MNBaseAdSize.h"
#import "MNetBaseAdSdk/MNBaseAdUnitConfigData.h"
#import <Foundation/Foundation.h>

@interface MNetDfpAdSizeHelper : NSObject
+ (NSArray<MNBaseAdSize *> *)fetchValidAdSizesFromConfigData:(MNBaseAdUnitConfigData *)adUnitDetailsObj
                                               forDfpAdSizes:(NSArray<NSValue *> *)dfpAdSizesList;

/// Get the MNetAdSize from the list of NSValue
+ (NSArray<MNBaseAdSize *> *)getMNetAdSizesFromDfpAdSizes:(NSArray<NSValue *> *)dfpAdSizesList;
@end
