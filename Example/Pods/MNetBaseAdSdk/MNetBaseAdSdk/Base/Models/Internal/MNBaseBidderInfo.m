//
//  MNBaseBidderInfo.m
//  Pods
//
//  Created by nithin.g on 14/09/17.
//
//

#import "MNBaseBidderInfo.h"

@implementation MNBaseBidderInfo

+ (instancetype)createInstanceFromBidResponse:(MNBaseBidResponse *)bidResponse {
    if (bidResponse == nil) {
        return nil;
    }

    MNBaseBidderInfo *bidderInfo = [[MNBaseBidderInfo alloc] init];
    bidderInfo.bidderId          = bidResponse.bidderId;
    bidderInfo.mainBid           = bidResponse.mainBid;
    bidderInfo.providerRequestId = bidResponse.providerRequestId;
    bidderInfo.bidInfo           = bidResponse.bidInfo;

    MNBaseBidderInfoDetails *infoDetails = [[MNBaseBidderInfoDetails alloc] init];
    [infoDetails setCreativeType:bidResponse.creativeType];
    [infoDetails setAdcode:[bidResponse getRawAdCode]];
    [infoDetails setAdurl:[bidResponse adUrl]];
    [infoDetails setWinner:[MNJMBoolean createWithBool:NO]];
    [infoDetails setLoggingPixels:bidResponse.loggingBeacons];
    [infoDetails setSize:bidResponse.size];
    bidderInfo.bidInfoDetails = infoDetails;

    return bidderInfo;
}

- (NSDictionary *)propertyKeyMap {
    return @{@"providerRequestId" : @"id", @"mainBid" : @"m_bid", @"bidInfoDetails" : @"bid_details"};
}

@end
