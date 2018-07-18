//
//  MNBaseDefaultBids.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseDefaultBid.h"

@implementation MNBaseDefaultBid

- (NSDictionary<NSString *, NSString *> *)propertyKeyMap {
    return @{@"contextUrlRegex" : @"requrl_re", @"adUnitId" : @"crid", @"bid" : @"m_bid"};
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"bidResponse" : [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class]
                                                                 andValueType:[MNBaseBidResponse class]]
    };
}

@end
