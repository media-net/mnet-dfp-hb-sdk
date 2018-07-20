//
//  MNetAdUnitFilterStore.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNetAdUnitFilter.h"
#import <Foundation/Foundation.h>

@interface MNetAdUnitFilterStore : NSObject

+ (instancetype)getSharedInstance;
- (NSArray<id<MNetAdUnitFilter>> *)getAdUnitFilters;

@end
