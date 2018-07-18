//
//  MNetAdUnitFilter.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNetBaseAdSdk/MNBaseAdUnitConfigData.h"
#import <Foundation/Foundation.h>

@interface MNetAdUnitFilterManager : NSObject

+ (instancetype)getSharedInstance;

- (MNBaseAdUnitConfigData *)fetchHbConfigFromConfig:(NSString *)pubAdUnitId
                                withTargetingParams:(NSDictionary *)targetingParams
                                          andAdView:(id)adView;

@end
