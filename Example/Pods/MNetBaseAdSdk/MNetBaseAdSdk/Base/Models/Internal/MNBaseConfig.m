//
//  MNBaseConfig.m
//  Pods
//
//  Created by kunal.ch on 23/02/17.
//
//

#import "MNBaseConfig.h"

@implementation MNBaseConfig

- (NSDictionary *)propertyKeyMap {
    return @{
        @"hbConfig" : @"hb_config",
        @"sdkConfig" : @"sdk_config",
        @"publisherTimeoutSettings" : @"publisher_timeout_settings",
        @"pid" : @"pid",
        @"version" : @"version",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"hbConfig" : [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                              andValueType:[MNBaseHbConfigData class]],
        @"sdkConfig" : [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                               andValueType:[MNBaseSdkConfigData class]],
        @"publisherTimeoutSettings" :
            [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                    andValueType:[MNBasePublisherTimeoutSettings class]],
    };
}
@end
