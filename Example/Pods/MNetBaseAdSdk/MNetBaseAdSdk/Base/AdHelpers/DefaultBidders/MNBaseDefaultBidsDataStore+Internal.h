//
//  MNBaseDefaultBidsDataStore+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#ifndef MNBaseDefaultBidsDataStore_Internal_h
#define MNBaseDefaultBidsDataStore_Internal_h

#define DEFAULT_BIDS_ARR_TYPE NSMutableArray<MNBaseDefaultBid *>
#define AD_UNIT_MAP_TYPE NSMutableDictionary<NSString *, DEFAULT_BIDS_ARR_TYPE *>
#define BIDDER_MAP_TYPE NSMutableDictionary<NSNumber *, AD_UNIT_MAP_TYPE *>

#define WILDCARD @"*"

#import "MNBaseDefaultBidsDataStore.h"

@interface MNBaseDefaultBidsDataStore ()
@property (atomic) BIDDER_MAP_TYPE *defaultBidsStore;
@property (atomic) dispatch_queue_t dataStoreReadWriteQueue;

// Fetch the most suitable bid-response from the default-bids-list for the given context-url.
// The default-bids is filtered by contextUrl and, from that, the highest value is returned.
- (MNBaseBidResponse *)applyFiltersOnDefaultBids:(DEFAULT_BIDS_ARR_TYPE *)defaultBidsList
                                  withContextUrl:(NSString *)contextUrl;

@end

#endif /* MNBaseDefaultBidsDataStore_Internal_h */
