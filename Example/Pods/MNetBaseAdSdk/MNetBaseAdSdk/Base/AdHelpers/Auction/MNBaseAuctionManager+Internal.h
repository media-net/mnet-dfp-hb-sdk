//
//  MNBaseAuctionManager+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 18/10/17.
//

#ifndef MNBaseAuctionManager_Internal_h
#define MNBaseAuctionManager_Internal_h

#import "MNBaseAuctionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseAuctionManager ()

- (MNBaseBidResponsesContainer *_Nullable)performAuctionForResponses:(NSArray<MNBaseBidResponse *> *)responsesList
    __deprecated_msg("Please do not call this method directly. This is an internal method, exposed for testing "
                     "purposes only. First of all, you shouldn't even be importing this class... oh well :)");

- (MNBaseBidResponse *_Nullable)getAuctionWinnerWithFpdResponses:(NSMutableArray<MNBaseBidResponse *> *)fpdList;

@end

NS_ASSUME_NONNULL_END

#endif /* MNBaseAuctionManager_Internal_h */
