//
//  MNBaseRegulation.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 19/12/17.
//

#import "MNBaseRequestRegulation.h"

@implementation MNBaseRequestRegulation

- (NSDictionary<NSString *, NSString *> *)propertyKeyMap {
    return @{
        @"isChildDirected" : @"coppa",
    };
}

@end
