//
//  MNetAdUnitFilterManager+Internal.h
//  Pods
//
//  Created by nithin.g on 30/08/17.
//
//

#ifndef MNetAdUnitFilterManager_Internal_h
#define MNetAdUnitFilterManager_Internal_h

#import "MNetAdUnitFilterManager.h"

@interface MNetAdUnitFilterManager ()

- (NSString *)fetchAdUnitIdFromConfig:(NSString *)pubAdUnitId
                  withTargetingParams:(NSDictionary *)targetingParams
                            andAdView:(id)adView;

@end

#endif /* MNetAdUnitFilterManager_Internal_h */
