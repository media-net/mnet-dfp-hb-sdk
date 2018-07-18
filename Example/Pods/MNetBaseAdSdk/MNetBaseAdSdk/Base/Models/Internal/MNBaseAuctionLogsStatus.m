//
//  MNBaseAuctionLogsStatus.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import "MNBaseAuctionLogsStatus.h"

@implementation MNBaseAuctionLogsStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        _prlog  = [MNJMBoolean createWithBool:NO];
        _prflog = [MNJMBoolean createWithBool:NO];
        _awlog  = [MNJMBoolean createWithBool:NO];
        _aplog  = [MNJMBoolean createWithBool:NO];
    }
    return self;
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

@end
