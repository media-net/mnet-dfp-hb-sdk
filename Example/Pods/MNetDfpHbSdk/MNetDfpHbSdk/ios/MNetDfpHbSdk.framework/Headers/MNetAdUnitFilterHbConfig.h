//
//  MNetAdUnitFilterHbConfig.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNetAdUnitFilter.h"
#import <Foundation/Foundation.h>

@interface MNetAdUnitFilterHbConfig : NSObject <MNetAdUnitFilter>
- (NSArray<MNBaseAdUnitConfigData *> *)filterConfigData:(NSArray<MNBaseAdUnitConfigData *> *)configData
                                           withAdUnitId:(NSString *)pubAdUnitId
                                    withTargetingParams:(NSDictionary *)hbTargetingParams
                                              andAdView:(UIView *)adView;
@end
