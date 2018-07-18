//
//  MNBaseAdUnitConfigData.m
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseAdUnitConfigData.h"
#import "MNBaseConstants.h"

#define AD_UNIT_WILDCARD @"*"

@implementation MNBaseAdUnitConfigData

- (instancetype)init {
    self = [super init];
    if (self) {
        _autorefreshEnabled  = [MNJMBoolean createWithBool:DEFAULT_IS_AUTO_REFRESH];
        _autorefreshInterval = [NSNumber numberWithFloat:DEFAULT_REFRESH_RATE];
    }
    return self;
}

- (BOOL)containsWildcardAdUnitId {
    return self.adUnitId != nil && [self.adUnitId isEqualToString:AD_UNIT_WILDCARD];
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"creativeId" : @"crid",
        @"adUnitId" : @"ad_unit_id",
        @"autorefreshEnabled" : @"autorefresh_enabled",
        @"autorefreshInterval" : @"autorefresh_interval",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"bidderIds" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSNumber class]],
        @"sizes" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
        @"supportedAds" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSNumber class]],
        @"customTargets" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseCustomTargets class]],
    };
}
@end
