//
//  BidResponse.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseConstants.h"
#import "MNBaseMacroManager.h"
@interface MNBaseBidResponse ()

@property NSString *visitId;
@property NSString *adCycleId;

@end

@implementation MNBaseBidResponse

- (NSDictionary *)propertyKeyMap {
    return @{
        @"adCode" : @"adcode",
        @"adType" : @"adtype",
        @"adUrl" : @"adurl",
        @"height" : @"h",
        @"width" : @"w",
        @"auctionWinUrl" : @"auction_win_url",
        @"loggingBeacons" : @"logging_pixels",
        @"extension" : @"ext",
        @"mainBid" : @"m_bid",
        @"providerRequestId" : @"id",
        @"responseType" : @"rt",
        @"auctionBid" : @"a_bid",
        @"originalBidMultiplier1" : @"obidm1",
        @"originalBidMultiplier2" : @"obidm2",
        @"dfpBidMultiplier1" : @"dfpbdm1",
        @"dfpBidMultiplier2" : @"dfpbdm2",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"loggingBeacons" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
        @"actlogs" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
        @"elogs" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]]
    };
}

- (NSArray *)directMapForKeys {
    return @[ @"serverExtras", @"bidInfo" ];
}

- (NSString *)getVisitId {
    return self.visitId;
}

- (NSString *)getAdCycleId {
    return self.adCycleId;
}

@synthesize adCode = _adCode;
- (NSString *)adCode {
    NSString *updatedAdCode = [[MNBaseMacroManager getSharedInstance] processMacrosForAdCode:_adCode withResponse:self];
    return updatedAdCode;
}

- (void)setAdCode:(NSString *)adCode {
    _adCode = adCode;
}

- (NSString *)getRawAdCode {
    return _adCode;
}

@synthesize serverExtras = _serverExtras;
- (NSDictionary *)serverExtras {
    NSDictionary *serverExtras =
        [[MNBaseMacroManager getSharedInstance] processServerExtras:_serverExtras withResponse:self];
    return serverExtras;
}

- (void)setServerExtras:(NSDictionary *)serverExtras {
    _serverExtras = serverExtras;
}

@synthesize elogs = _elogs;
- (NSArray<NSString *> *)elogs {
    NSArray<NSString *> *elogs =
        [[MNBaseMacroManager getSharedInstance] processMacrosForExpiryLogs:_elogs withResponse:self];
    return elogs;
}

- (void)setElogs:(NSArray<NSString *> *)elogs {
    _elogs = elogs;
}

@synthesize loggingBeacons = _loggingBeacons;
- (NSArray<NSString *> *)loggingBeacons {
    NSArray<NSString *> *loggingBeaconsList =
        [[MNBaseMacroManager getSharedInstance] processMacrosForLoggingPixels:_loggingBeacons withResponse:self];
    return loggingBeaconsList;
}

- (void)setLoggingBeacons:(NSArray<NSString *> *)loggingBeacons {
    _loggingBeacons = loggingBeacons;
}

- (BOOL)isYBNCBidder {
    return [self.bidderId isEqual:YBNC_BIDDER_ID];
}
@end
