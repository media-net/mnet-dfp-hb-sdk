//
//  MNBaseImpFormat.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 04/04/18.
//

#import "MNBaseImpFormat.h"

@implementation MNBaseImpFormat

+ (MNBaseImpFormat *)newInstance {
    MNBaseImpFormat *instance = [[MNBaseImpFormat alloc] init];
    return instance;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"width" : @"w",
        @"height" : @"h",
    };
}
@end
