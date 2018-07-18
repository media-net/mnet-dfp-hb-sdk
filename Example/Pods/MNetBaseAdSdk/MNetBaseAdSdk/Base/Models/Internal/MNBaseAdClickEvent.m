//
//  MNBaseAdClickEvent.m
//  Pods
//
//  Created by nithin.g on 04/07/17.
//
//

#import "MNBaseAdClickEvent.h"
#import "MNBaseLinkStore.h"

@implementation MNBaseAdClickEvent

+ (instancetype)getInstanceFromBidResponse:(MNBaseBidResponse *)response {
    MNBaseAdClickEvent *instance = [[MNBaseAdClickEvent alloc] init];
    instance.adUnitId            = response.creativeId;
    instance.adCycleId           = [response getAdCycleId];
    instance.bidderId            = response.bidderId;
    instance.bid                 = response.ogBid;
    instance.appLink             = [[MNBaseLinkStore getSharedInstance] getLink];

    return instance;
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

@end
