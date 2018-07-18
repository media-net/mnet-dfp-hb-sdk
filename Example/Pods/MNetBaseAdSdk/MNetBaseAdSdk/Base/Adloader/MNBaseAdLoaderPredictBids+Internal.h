//
//  MNBaseAdLoaderPredictBids+Internal.h
//  Pods
//
//  Created by nithin.g on 14/09/17.
//
//

#ifndef MNBaseAdLoaderPredictBids_Internal_h
#define MNBaseAdLoaderPredictBids_Internal_h

#import "MNBaseAdLoaderPredictBids.h"

@interface MNBaseAdLoaderPredictBids ()

@property (atomic, nullable) NSString *adUnitId;
@property (nonnull) NSArray<MNBaseBidResponse *> *cachedBidResponses;
@property (atomic, nonnull) MNBaseBidRequest *bidRequest;

/// Apply the cached-bids into the bid-request
- (BOOL)updateCachedBidResponsesFromBidStore;

/// Update the bid-request with the cached-bids
- (BOOL)updateBidRequestWithCachedBids;

/// This returns if the auction can be conducted with the current list of cached responses.
- (BOOL)canPerformAuctionWithCachedEntries;

/// Disables post ad load prefetch
+ (void)disablePostAdLoadPrefetch;

@end

#endif /* MNBaseAdLoaderPredictBids_Internal_h */
