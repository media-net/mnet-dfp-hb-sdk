//
//  MNBaseAuctionDetails.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 23/10/17.
//

#import "MNBaseBidRequest.h"
#import "MNBaseBidderInfo.h"
#import <Foundation/Foundation.h>

@interface MNBaseAuctionDetails : NSObject

@property BOOL didAuctionHappen;

/// Timestamp for when the auction was completed.
@property NSNumber *auctionTimestamp;

/// The bidder-info of all the participants in the auction.
@property NSArray<MNBaseBidderInfo *> *participantsBidderInfoArr;

/// The bid-request that was cause the auction.
@property MNBaseBidRequest *failedBidRequest;

/// The new ad-cycle-id for the auction.
@property NSString *updatedAdCycleId;

@end
