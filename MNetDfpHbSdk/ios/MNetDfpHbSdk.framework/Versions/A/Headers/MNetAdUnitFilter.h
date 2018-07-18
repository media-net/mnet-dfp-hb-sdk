//
//  MnetAdUnitFilter.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNetBaseAdSdk/MNBaseAdUnitConfigData.h"
#import <Foundation/Foundation.h>

@protocol MNetAdUnitFilter <NSObject>

- (NSArray<MNBaseAdUnitConfigData *> *)filterConfigData:(NSArray<MNBaseAdUnitConfigData *> *)configData
                                           withAdUnitId:(NSString *)adUnitId
                                    withTargetingParams:(NSDictionary *)customTargetingParams
                                              andAdView:(UIView *)adView;

@end
