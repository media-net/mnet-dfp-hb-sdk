//
//  MNetAdUnitFilterTargetingParams.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNetAdUnitFilter.h"
#import <Foundation/Foundation.h>

@interface MNetAdUnitFilterTargetingParams : NSObject <MNetAdUnitFilter>

- (NSArray<MNBaseAdUnitConfigData *> *)filterConfigData:(NSArray<MNBaseAdUnitConfigData *> *)configData
                                           withAdUnitId:(NSString *)adUnitId
                                    withTargetingParams:(NSDictionary *)customTargetingParams
                                              andAdView:(UIView *)adView;

@end
