//
//  MNBaseAdImpression.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdImpression.h"

@implementation MNBaseAdImpression

+ (MNBaseAdImpression *)newInstance {
    MNBaseAdImpression *adImpression = [[MNBaseAdImpression alloc] init];
    return adImpression;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"adUnitId" : @"tagid",
        @"type" : @"instl",
        @"isSecure" : @"secure",
        @"clickThroughToBrowser" : @"clickbrowser",
    };
}

@end
