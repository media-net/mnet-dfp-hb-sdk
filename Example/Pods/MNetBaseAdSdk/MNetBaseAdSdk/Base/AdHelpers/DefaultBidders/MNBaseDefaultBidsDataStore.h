//
//  MNBaseDefaultBidsDataStore.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseBidResponse.h"
#import "MNBaseDefaultBid.h"
#import <Foundation/Foundation.h>

@interface MNBaseDefaultBidsDataStore : NSObject
+ (instancetype _Nonnull)getSharedInstance;

/// Adds the default bid to the store
- (BOOL)addDefaultBids:(NSArray<MNBaseDefaultBid *> *_Nonnull)defaultBidsList;

/// Gets all the bid-responses for all the bidder-ids in
- (NSArray<MNBaseBidResponse *> *_Nullable)getBidResponsesForAdUnitId:(NSString *_Nonnull)adUnitId
                                                        andContextUrl:(NSString *_Nonnull)contextUrl;

@end
