//
//  MNBaseAuctionLoggerRequest.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import "MNBaseAuctionLogsStatus.h"
#import "MNBaseBidRequest.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MNBaseAuctionLoggerRequest : MNBaseBidRequest
@property (atomic, nullable) NSNumber *auctionToFireDuration;
@property (atomic) MNBaseAuctionLogsStatus *logsStatus;

- (instancetype)initFromBidResponseContainer:(MNBaseBidResponsesContainer *)responsesContainer;

@end
NS_ASSUME_NONNULL_END
