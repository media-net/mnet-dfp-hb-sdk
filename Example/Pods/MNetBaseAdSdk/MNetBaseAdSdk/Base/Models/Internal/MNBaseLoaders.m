//
//  MNBaseLoaders.m
//  Pods
//
//  Created by kunal.ch on 29/08/17.
//
//

#import "MNBaseLoaders.h"

@implementation MNBaseLoaders

- (NSDictionary *)propertyKeyMap {
    return @{@"defaultLoaders" : @"default", @"adunitLoaders" : @"ad_units"};
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"adUnitLoaders" : [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                                   andValueType:[MNBaseDefaultLoaders class]]
    };
}
@end
