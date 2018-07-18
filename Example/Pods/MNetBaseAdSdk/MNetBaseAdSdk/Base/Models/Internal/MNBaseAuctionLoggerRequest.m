//
//  MNBaseAuctionLoggerRequest.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import "MNBaseAuctionLoggerRequest.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

@implementation MNBaseAuctionLoggerRequest

#pragma mark - Init methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _auctionToFireDuration = nil;
        _logsStatus            = [MNBaseAuctionLogsStatus new];
    }
    return self;
}

- (instancetype)initFromBidResponseContainer:(MNBaseBidResponsesContainer *)responsesContainer {
    self = [self init];
    if (self) {
        [self createFromResponsesContainer:responsesContainer];
    }
    return self;
}

#pragma mark - Helper methods

- (void)createFromResponsesContainer:(MNBaseBidResponsesContainer *)responsesContainer {
    MNBaseAuctionDetails *auctionDetails = [responsesContainer auctionDetails];
    if (auctionDetails == nil || auctionDetails.failedBidRequest == nil) {
        auctionDetails = [self createAuctionDetailsFromResponsesContainer:responsesContainer];
        if (auctionDetails == nil) {
            MNLogRemote(@"Cannot make auction request");
            return;
        }
    }

    NSNumber *auctionTimestamp = auctionDetails.auctionTimestamp;
    if (auctionTimestamp != nil) {
        double timestampDiff;
        if (auctionTimestamp == nil) {
            timestampDiff = 0;
        } else {
            NSNumber *currentTimestamp = [MNBaseUtil getTimestampInMillis];
            timestampDiff              = [currentTimestamp doubleValue] - [auctionTimestamp doubleValue];
        }
        self.auctionToFireDuration = [NSNumber numberWithDouble:timestampDiff];
    }

    MNBaseBidRequest *failedBidRequest = auctionDetails.failedBidRequest;
    self.hostAppInfo                   = failedBidRequest.hostAppInfo;
    self.adImpressions                 = failedBidRequest.adImpressions;
    self.adDetails                     = failedBidRequest.adDetails;
    self.prefetchEnabledBidder         = failedBidRequest.prefetchEnabledBidder;
    self.viewControllerTitle           = failedBidRequest.viewControllerTitle;
    self.ext                           = failedBidRequest.ext;

    self.adCycleId = [auctionDetails updatedAdCycleId];
    self.bidders   = [auctionDetails participantsBidderInfoArr];
}

- (MNBaseAuctionDetails *)createAuctionDetailsFromResponsesContainer:(MNBaseBidResponsesContainer *)responsesContainer {
    MNBaseAuctionDetails *auctionDetails = [MNBaseAuctionDetails new];
    MNBaseBidResponse *winningResponse   = [responsesContainer selectedBidResponse];
    if (winningResponse == nil) {
        return nil;
    }

    NSString *adUnitId   = [winningResponse creativeId];
    NSString *sizeStr    = [winningResponse size];
    CGSize size          = [MNBaseUtil getAdSizeFromStringFormat:sizeStr];
    MNBaseAdSize *adSize = [MNBaseAdSize new];
    [adSize setH:[NSNumber numberWithFloat:size.height]];
    [adSize setW:[NSNumber numberWithFloat:size.width]];

    NSString *newAdCycleId          = [MNBaseUtil generateAdCycleId];
    auctionDetails.updatedAdCycleId = newAdCycleId;
    [winningResponse setAdCycleId:newAdCycleId];

    MNBaseAdRequest *dummyAdRequest = [MNBaseAdRequest newRequest];
    [dummyAdRequest setAdUnitId:adUnitId];
    [dummyAdRequest setAdSizes:@[ adSize ]];
    [dummyAdRequest setAdCycleId:newAdCycleId];
    [dummyAdRequest updateContextLink];
    [dummyAdRequest updateVCTitle];
    auctionDetails.failedBidRequest = [MNBaseBidRequest create:dummyAdRequest];

    NSMutableArray *bidderInfoList = [[NSMutableArray alloc] init];
    [bidderInfoList addObject:[MNBaseBidderInfo createInstanceFromBidResponse:winningResponse]];
    [auctionDetails setParticipantsBidderInfoArr:bidderInfoList];

    return auctionDetails;
}

#pragma mark - JSON Mapper methods

- (NSDictionary *)propertyKeyMap {
    NSMutableDictionary<NSString *, NSString *> *keyMap = [[super propertyKeyMap] mutableCopy];
    keyMap[@"auctionToFireDuration"]                    = @"acttime";
    keyMap[@"logsStatus"]                               = @"f_logs";
    return [NSDictionary dictionaryWithDictionary:keyMap];
}

@end
