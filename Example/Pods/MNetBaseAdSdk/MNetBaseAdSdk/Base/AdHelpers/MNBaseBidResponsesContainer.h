//
//  MNBaseBidResponsesContainer.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 18/10/17.
//

#import "MNBaseAuctionDetails.h"
#import "MNBaseBidResponse.h"
#import "MNBaseBidStore.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseBidResponsesContainer : NSObject
@property (atomic, nonnull) NSArray<MNBaseBidResponse *> *bidResponsesArr;
@property (atomic, nullable) NSString *selectedBidderIdStr;
@property (atomic, nullable) MNBaseBidResponse *selectedBidResponse;
@property (atomic, nullable) MNBaseAuctionDetails *auctionDetails;
@property (atomic, nullable) NSArray<NSString *> *apLogs;
@property (atomic) BOOL areDefaultBids;

+ (instancetype)getInstanceWithBidResponses:(NSArray<MNBaseBidResponse *> *_Nullable)bidResponsesArr;

/// Returns first instance of bid-response of bidType in the bid-responses array.
- (MNBaseBidResponse *_Nullable)getBidResponseForBidType:(NSString *)bidType;

/// Returns bid-response for bidder-id
- (MNBaseBidResponse *_Nullable)getBidResponseForBidderId:(NSNumber *)bidderId;

/// Returns the selected response candidate, from the current parameters.
- (MNBaseBidResponse *_Nullable)getSelectedBidResponseCandidate;

/// Remove all entries from the bid-response except for the selected bid-response.
- (void)stripAllExceptSelectedBidResponse;

/// Returns a bid-responses array without the adx response entry.
- (NSArray<MNBaseBidResponse *> *_Nullable)getBidResponsesCloneWithoutAdx;

/// Recycle all the bids in the current response.
- (BOOL)recycleAllBids;

/// Recycle all the bids in the current response except for the selected response.
- (BOOL)recycleAllBidsExceptSelectedResponse;

@end

NS_ASSUME_NONNULL_END
