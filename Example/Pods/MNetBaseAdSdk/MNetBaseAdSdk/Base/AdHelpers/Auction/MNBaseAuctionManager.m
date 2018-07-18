//
//  MNBaseAuctionManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 17/10/17.
//

#import "MNBaseAuctionManager+Internal.h"
#import "MNBasePulseEventName.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

@implementation MNBaseAuctionManager

+ (instancetype)getInstance {
    return [[MNBaseAuctionManager alloc] init];
}

- (MNBaseBidResponsesContainer *_Nullable)performAuctionForResponses:(NSArray<MNBaseBidResponse *> *)responsesList
                                                   madeForBidRequest:(MNBaseBidRequest *)bidRequest {
    [self sendParticipantResponsesEvent:responsesList withBidRequest:bidRequest];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MNBaseBidResponsesContainer *responsesContainer = [self performAuctionForResponses:responsesList];
#pragma clang diagnostic pop

    if (responsesContainer != nil && responsesContainer.auctionDetails != nil) {
        [responsesContainer.auctionDetails setFailedBidRequest:bidRequest];
    }

    return responsesContainer;
}

- (MNBaseBidResponsesContainer *_Nullable)performAuctionForResponses:(NSArray<MNBaseBidResponse *> *)responsesList {
    if (responsesList == nil || [responsesList count] == 0) {
        return nil;
    }

    // Filter out the responses by fpd and tpd
    NSUInteger responsesCount = [responsesList count];
    NSMutableArray<MNBaseBidResponse *> *fpdList, *tpdList;
    fpdList = [[NSMutableArray<MNBaseBidResponse *> alloc] initWithCapacity:responsesCount];
    tpdList = [[NSMutableArray<MNBaseBidResponse *> alloc] initWithCapacity:responsesCount];

    for (MNBaseBidResponse *response in responsesList) {
        if ([[response bidType] isEqualToString:BID_TYPE_FIRST_PARTY]) {
            [fpdList addObject:response];
        } else if ([[response bidType] isEqualToString:BID_TYPE_THIRD_PARTY]) {
            [tpdList addObject:response];
        }
    }

    MNBaseBidResponse *winnerResponse = [self getAuctionWinnerWithFpdResponses:fpdList];

    // Add the winner response to the auctions list
    NSMutableArray<MNBaseBidResponse *> *auctionedResponses = [[NSMutableArray alloc] init];
    if (winnerResponse != nil) {
        [auctionedResponses addObject:winnerResponse];
    }
    if (tpdList != nil && [tpdList count] > 0) {
        [auctionedResponses addObjectsFromArray:tpdList];
    }

    // Update the auction details with both the fpd and tpd details
    NSMutableArray<MNBaseBidderInfo *> *bidderInfoList = [[NSMutableArray alloc] init];
    for (MNBaseBidResponse *bidResponse in fpdList) {
        MNBaseBidderInfo *bidderInfo = [MNBaseBidderInfo createInstanceFromBidResponse:bidResponse];
        if (winnerResponse != nil && [bidResponse.bidderId isEqualToValue:winnerResponse.bidderId]) {
            [[bidderInfo bidInfoDetails] setWinnerStatus:YES];
        }
        [bidderInfoList addObject:bidderInfo];
    }
    for (MNBaseBidResponse *bidResponse in tpdList) {
        MNBaseBidderInfo *bidderInfo = [MNBaseBidderInfo createInstanceFromBidResponse:bidResponse];
        [bidderInfoList addObject:bidderInfo];
    }

    MNBaseAuctionDetails *auctionDetails = [MNBaseAuctionDetails new];
    [auctionDetails setDidAuctionHappen:YES];
    [auctionDetails setAuctionTimestamp:[MNBaseUtil getTimestampInMillis]];
    [auctionDetails setParticipantsBidderInfoArr:bidderInfoList];
    [auctionDetails setUpdatedAdCycleId:[MNBaseUtil generateAdCycleId]];

    // Build the responses-container
    MNBaseBidResponsesContainer *bidResponsesContainer =
        [MNBaseBidResponsesContainer getInstanceWithBidResponses:auctionedResponses];
    [bidResponsesContainer setAuctionDetails:auctionDetails];

    return bidResponsesContainer;
}

#pragma mark - Perform auction for fpd responses

- (MNBaseBidResponse *)getAuctionWinnerWithFpdResponses:(NSMutableArray<MNBaseBidResponse *> *)fpdList {
    if (fpdList == nil || [fpdList count] == 0) {
        return nil;
    }

    // Sort the fpd responses by ag_log
    [fpdList sortUsingComparator:^NSComparisonResult(MNBaseBidResponse *obj1, MNBaseBidResponse *obj2) {
      double obj1Bid = [obj1.auctionBid doubleValue];
      double obj2Bid = [obj2.auctionBid doubleValue];

      if (obj1Bid > obj2Bid) {
          return NSOrderedAscending;
      } else if (obj1Bid == obj2Bid) {
          return NSOrderedSame;
      } else {
          return NSOrderedDescending;
      }
    }];

    // Apply the formula for the first element of the fpd responses list.
    MNBaseBidResponse *winnerResponse = [fpdList firstObject];

    // Calculate the og_bid and dfpBid values
    double winnerMainBid = [[winnerResponse mainBid] doubleValue];
    double obdm1         = [[winnerResponse originalBidMultiplier1] doubleValue];
    double obdm2         = [[winnerResponse originalBidMultiplier2] doubleValue];
    double dfpbdm1       = [[winnerResponse dfpBidMultiplier1] doubleValue];
    double dfpbdm2       = [[winnerResponse dfpBidMultiplier2] doubleValue];

    MNBaseBidResponse *runnerUpResponse = winnerResponse;
    if ([fpdList count] > 1) {
        runnerUpResponse = [fpdList objectAtIndex:1];
    }
    double runnerUpMainBid = [[runnerUpResponse mainBid] doubleValue];

    double ogBidVal  = (winnerMainBid * obdm1) + (runnerUpMainBid + 0.1) * (obdm2);
    double dfpBidVal = (winnerMainBid * dfpbdm1) + (runnerUpMainBid + 0.1) * (dfpbdm2);

    NSNumber *finalOgBid  = [NSNumber numberWithDouble:ogBidVal];
    NSNumber *finalDfpBid = [NSNumber numberWithDouble:dfpBidVal];

    [winnerResponse setOgBid:finalOgBid];
    [winnerResponse setDfpbid:finalDfpBid];

    return winnerResponse;
}

- (void)sendParticipantResponsesEvent:(NSArray<MNBaseBidResponse *> *)responsesList
                       withBidRequest:(MNBaseBidRequest *)bidRequest {
    NSString *contentUrl = [bidRequest fetchContextUrl];
    NSString *vcTitle    = [bidRequest viewControllerTitle];
    NSString *adCycleId  = [bidRequest adCycleId];

    for (MNBaseBidResponse *response in responsesList) {
        [self sendParticipationEventForId:[response predictionId]
                           withContentUrl:contentUrl
                              withVcTitle:vcTitle
                             andAdCycleId:adCycleId];
    }
}

- (void)sendParticipationEventForId:(NSString *)predictionId
                     withContentUrl:(NSString *)contentUrl
                        withVcTitle:(NSString *)vcTitle
                       andAdCycleId:(NSString *)adCycleId {
    if (predictionId == nil || [predictionId isEqualToString:@""]) {
        return;
    }
    if (contentUrl == nil) {
        contentUrl = @"";
    }
    if (vcTitle == nil) {
        vcTitle = @"";
    }
    if (adCycleId == nil) {
        adCycleId = @"";
    }

    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventPredictedBidParticipated
                                   andCustomData:@{
                                       @"predicted_id" : predictionId,
                                       @"content_url" : contentUrl,
                                       @"activity_name" : vcTitle,
                                       @"ad_cycle_id" : adCycleId,
                                   }];
}

@end
