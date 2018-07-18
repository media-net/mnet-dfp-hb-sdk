//
//  MNBaseDefaultBiddersManager+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#ifndef MNBaseDefaultBidsManager_Internal_h
#define MNBaseDefaultBidsManager_Internal_h
#import "MNBaseDefaultBid.h"
#import "MNBaseDefaultBidsDataStore+Internal.h"
#import "MNBaseDefaultBidsManager.h"

@interface MNBaseDefaultBidsManager ()
@property (atomic, nonnull) MNBaseDefaultBidsDataStore *dataStore;
@property (atomic, nonnull) id sdkConfigNotificationObj;

/// Fetches the list of default bid-responses from the default-bids store
- (NSArray<MNBaseBidResponse *> *_Nullable)getBidResponsesForAdUnitId:(NSString *_Nonnull)adUnitId
                                                        andContextUrl:(NSString *_Nonnull)contextUrl;

// Update the default bids manager. Returns true only if all the bids have been added
- (BOOL)addDefaultBids:(NSArray<MNBaseDefaultBid *> *_Nonnull)defaultBids;

@end

#endif /* MNBaseDefaultBidsManager_Internal_h */
