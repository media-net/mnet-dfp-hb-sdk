//
//  MNBaseAuctionManager.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 17/10/17.
//

#import "MNBaseBidRequest.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseAuctionManager : NSObject
+ (instancetype)getInstance;

/// Performs the auction for the given responses. The bid-request is sent for logging purposes. Returns the
/// responsesContainer with the winning-bids and meta-data.
- (MNBaseBidResponsesContainer *_Nullable)performAuctionForResponses:(NSArray<MNBaseBidResponse *> *)responsesList
                                                   madeForBidRequest:(MNBaseBidRequest *)bidRequest;
@end

NS_ASSUME_NONNULL_END
