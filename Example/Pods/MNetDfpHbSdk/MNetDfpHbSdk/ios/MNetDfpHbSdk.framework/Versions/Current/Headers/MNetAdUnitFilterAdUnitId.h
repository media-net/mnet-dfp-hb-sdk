//
//  MNetAdUnitFilterAdUnitIdFilter.h
//  Pods
//
//  Created by nithin.g on 12/07/17.
//
//

#import "MNetAdUnitFilter.h"
#import "MNetBaseAdSdk/MNBaseAdUnitConfigData.h"
#import <Foundation/Foundation.h>

@interface MNetAdUnitFilterAdUnitId : NSObject <MNetAdUnitFilter>
- (NSArray<MNBaseAdUnitConfigData *> *)filterConfigData:(NSArray<MNBaseAdUnitConfigData *> *)configData
                                           withAdUnitId:(NSString *)pubAdUnitId
                                    withTargetingParams:(NSDictionary *)hbTargetingParams
                                              andAdView:(UIView *)adView;
@end
