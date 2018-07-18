//
//  MNBaseAdDetails.m
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import "MNBaseAdDetails.h"

@implementation MNBaseAdDetails

- (NSDictionary *)propertyKeyMap {
    return @{
        @"fpBid" : @"bid",
        @"lastAdxBid" : @"last_adx_bd",
        @"lastAdxWinBid" : @"last_adx_win_bd",
        @"lastAdxWinStatus" : @"last_adx_status",
    };
}

@end
