//
//  MNBaseAuctionDetails.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 23/10/17.
//

#import "MNBaseAuctionDetails.h"

@implementation MNBaseAuctionDetails
- (instancetype)init {
    self = [super init];
    if (self) {
        _didAuctionHappen          = NO;
        _participantsBidderInfoArr = nil;
        _auctionTimestamp          = nil;
        _failedBidRequest          = nil;
    }
    return self;
}

@end
