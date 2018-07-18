//
//  MNBaseBidStoreImpl.m
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseBidStoreImpl.h"
#import "MNBaseAdSizeConstants.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseMultiQueue.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

// Amounts to 10k secs
static NSUInteger EXTENDED_TIME_PERIOD_MS = 10000000;

// TODO; This should be taken from the SDK config
static NSUInteger TIMESTAMP_DELTA_MS = 300;

@interface MNBaseBidStoreImpl ()
@property (atomic) MNBaseMultiQueue *multiQueue;
@end

@implementation MNBaseBidStoreImpl

- (instancetype)init {
    self        = [super init];
    _multiQueue = [[MNBaseMultiQueue alloc] init];
    return self;
}

- (BOOL)insert:(MNBaseBidResponse *)response {
    if (response == nil) {
        return NO;
    }

    @synchronized(self) {
        NSString *adUnitId = [response creativeId];
        NSString *bidderId = [[response bidderId] stringValue];

        return [self.multiQueue pushData:response withFirstKey:adUnitId andSecondKey:bidderId];
    }
}

- (NSArray<MNBaseBidResponse *> *)getBidsForReqUrl:(NSString *)reqUrl fromQueue:(MNBaseQueue *)queue {
    if (queue == nil || reqUrl == nil || [reqUrl isEqualToString:@""]) {
        return nil;
    }

    NSMutableArray<MNBaseBidResponse *> *bidsWithReqUrl = [NSMutableArray<MNBaseBidResponse *> new];
    NSUInteger queueLen                                 = [queue queueLen];
    for (int i = 0; i < queueLen; i++) {
        MNBaseBidResponse *bidResponse = (MNBaseBidResponse *) [queue dequeue];
        if (bidResponse == nil) {
            continue;
        }

        NSString *respUrl = [bidResponse viewContextLink];
        // check for expiry
        if ([self isExpired:bidResponse]) {
            MNLogD(@"EXPIRE: Response %@ expired!", [bidResponse creativeId]);
            [self processExpiredResponseAsync:bidResponse];
            continue;
        }
        // Check if the links match
        if (respUrl != nil && [respUrl isEqualToString:reqUrl]) {
            [bidsWithReqUrl addObject:bidResponse];
            continue;
        }

        // Add the element back into the queue if not used at this point
        [queue enqueue:bidResponse];
    }
    if ([bidsWithReqUrl count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:bidsWithReqUrl];
}

- (NSArray<MNBaseBidResponse *> *)getBidsForAdSizes:(NSArray<MNBaseAdSize *> *)sizes
                                           fromList:(NSArray<MNBaseBidResponse *> *)responsesList {
    if (responsesList == nil || sizes == nil) {
        return nil;
    }

    NSMutableArray<MNBaseBidResponse *> *matchedResponses = [NSMutableArray new];
    for (MNBaseAdSize *adSize in sizes) {
        MNBaseBidResponse *response = [self getBidForSize:adSize fromList:responsesList];
        if (response != nil) {
            [matchedResponses addObject:response];
        }
    }
    if (matchedResponses == nil || [matchedResponses count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:matchedResponses];
}

// NOTE: that this does not handle empty ad-sizes in the required way
- (MNBaseBidResponse *)getBidForSize:(MNBaseAdSize *)adSize fromList:(NSArray<MNBaseBidResponse *> *)responsesList {
    if (adSize == nil || responsesList == nil) {
        return nil;
    }

    NSString *reqAdSizeStr = [MNBaseUtil getAdSizeString:MNBaseCGSizeFromAdSize(adSize)];
    for (MNBaseBidResponse *bidResponse in responsesList) {
        NSString *respSize = [bidResponse size];
        if (respSize != nil && [respSize isEqualToString:reqAdSizeStr]) {
            return bidResponse;
        }
    }
    return nil;
}

- (NSArray<MNBaseBidResponse *> *)fetchForAdUnitId:(NSString *)adUnitId
                                       withAdSizes:(NSArray<MNBaseAdSize *> *)sizes
                                         andReqUrl:(NSString *)reqUrl {
    if (adUnitId == nil) {
        return nil;
    }

    @synchronized(adUnitId) {
        NSDictionary<NSString *, MNBaseQueue *> *bidderQueueMap = [self.multiQueue getInnerMapForKey:adUnitId];
        if (bidderQueueMap == nil || [bidderQueueMap count] == 0) {
            return nil;
        }

        NSMutableArray<MNBaseBidResponse *> *bidResponseslist = [NSMutableArray<MNBaseBidResponse *> new];
        for (NSString *bidderId in bidderQueueMap) {
            MNBaseQueue *queue = [bidderQueueMap objectForKey:bidderId];
            if (queue == nil) {
                continue;
            }
            NSArray<MNBaseBidResponse *> *queueContents = [queue getQueueContents];
            if (queueContents == nil || [queueContents count] == 0) {
                continue;
            }

            NSMutableArray<MNBaseBidResponse *> *matchedBidResponses  = [NSMutableArray<MNBaseBidResponse *> new];
            NSMutableArray<MNBaseBidResponse *> *filteredBidResponses = [NSMutableArray<MNBaseBidResponse *> new];

            // Filter 1 - Fetching the matched req-urls(if bidder-id is ybnc)
            if (reqUrl != nil && [bidderId isEqualToString:[YBNC_BIDDER_ID stringValue]]) {
                NSArray<MNBaseBidResponse *> *responsesList = [self getBidsForReqUrl:reqUrl fromQueue:queue];
                if (responsesList != nil) {
                    [filteredBidResponses addObjectsFromArray:responsesList];
                }
            }

            if ([filteredBidResponses count] == 0) {
                // Pop everything out from the queue since it'll be just simpler to add them back later on
                NSMutableArray<MNBaseBidResponse *> *queueContents = [NSMutableArray<MNBaseBidResponse *> new];
                do {
                    MNBaseBidResponse *response = (MNBaseBidResponse *) [queue dequeue];
                    if (response == nil) {
                        break;
                    }
                    if ([self isExpired:response]) {
                        [self processExpiredResponseAsync:response];
                    } else {
                        [queueContents addObject:response];
                    }
                } while (YES);
                if ([queueContents count] > 0) {
                    [filteredBidResponses addObjectsFromArray:queueContents];
                }
            }

            // At this point, if there is nothing, then go to the next-queue
            if ([filteredBidResponses count] == 0) {
                continue;
            }

            // Filter 2 - Fetching one response for each ad-size from filter-1
            if (sizes != nil && [sizes count] > 0) {
                NSArray<MNBaseBidResponse *> *responses = [self getBidsForAdSizes:sizes fromList:filteredBidResponses];
                if (responses != nil && [responses count] > 0) {
                    [matchedBidResponses addObjectsFromArray:responses];
                    for (MNBaseBidResponse *response in responses) {
                        [filteredBidResponses removeObject:response];
                    }
                }
            } else {
                // Just pop one out from filtered
                if ([filteredBidResponses count] > 0) {
                    [matchedBidResponses addObject:[filteredBidResponses objectAtIndex:0]];
                    [filteredBidResponses removeObjectAtIndex:0];
                }
            }
            // Push the remaining filtered-bid-responses back into the queue
            for (MNBaseBidResponse *response in filteredBidResponses) {
                [queue enqueue:response];
            }

            // Push into the bid-responses list
            if ([matchedBidResponses count] > 0) {
                [bidResponseslist addObjectsFromArray:matchedBidResponses];
            }
        }

        if ([bidResponseslist count] == 0) {
            return nil;
        }
        return [NSArray arrayWithArray:bidResponseslist];
    }
}

- (void)flushStore {
    @synchronized(self) {
        [self.multiQueue flushQueueEntries];
    }
}

#pragma mark - Helpers

- (BOOL)doesResponse:(MNBaseBidResponse *)bidResponse containValidAdSizes:(NSArray<MNBaseAdSize *> *)adSizes {
    if (adSizes == nil || [adSizes count] == 0) {
        // If adSizes is empty, then any size is valid size
        return YES;
    }
    CGSize bidResponseSize = [MNBaseUtil getAdSizeFromStringFormat:bidResponse.size];

    for (MNBaseAdSize *adSize in adSizes) {
        if ([adSize.w floatValue] == bidResponseSize.width && [adSize.h floatValue] == bidResponseSize.height) {
            return YES;
        }
    }
    return NO;
}

- (void)processExpiredResponseAsync:(MNBaseBidResponse *)bidResponse {
    // Call the bidstore expiry methods
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      @try {
          if (bidResponse == nil) {
              return;
          }

          NSArray<NSString *> *expiredLogsList = bidResponse.elogs;
          if (expiredLogsList == nil) {
              return;
          }

          // Call the expiry event, if the prediction-id exists
          if ([bidResponse predictionId] != nil && NO == [[bidResponse predictionId] isEqualToString:@""]) {
              NSString *predictionId = [bidResponse predictionId];
              [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventPredictedBidExpired
                                             andCustomData:@{@"prediction_id" : predictionId}];
          }

          // Make the expiry log requests
          for (NSString *elog in expiredLogsList) {
              [MNBaseHttpClient doGetWithStrResponseOn:elog
                  headers:nil
                  shouldRetry:NO
                  success:^(NSString *_Nonnull responseDict) {
                    MNLogD(@"Successfully called the elog");
                  }
                  error:^(NSError *_Nonnull error) {
                    if (error) {
                        MNLogRemote(@"Error - %@", error);
                    }
                  }];
          }
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - processIfExpired %@", e);
      }
    });
}

- (BOOL)isExpired:(MNBaseBidResponse *)bidResponse {
    NSUInteger expiryTimestampMs;

    // NOTE: All the timestamps are in ms
    NSUInteger currentTimestamp = [[MNBaseUtil getTimestampInMillis] unsignedIntegerValue];

    if (bidResponse.expiry != nil) {
        expiryTimestampMs = [bidResponse.expiry unsignedIntegerValue];
    } else {
        // If no expiry time given, then assume it won't expire.
        // Give it a arbitrarily large amount of extended period
        expiryTimestampMs = currentTimestamp + EXTENDED_TIME_PERIOD_MS;
    }
    // Removing extra time-delay, considering network latency and other factors
    expiryTimestampMs = expiryTimestampMs - TIMESTAMP_DELTA_MS;

    return currentTimestamp >= expiryTimestampMs;
}

/// Get the number of bids count per bid for specified ad-unit-id
- (BID_STORE_COUNT_MAP_TYPE _Nullable)getBidStoreCountForAdUnit:(NSString *_Nullable)adUnitId {
    if (adUnitId == nil) {
        return nil;
    }

    @synchronized(self) {
        if ([self multiQueue] == nil) {
            return nil;
        }

        NSDictionary<NSString *, NSNumber *> *bidStoreCountForAdUnitId =
            [[self multiQueue] getBidStoreCountForAdUnit:adUnitId];
        if (bidStoreCountForAdUnitId == nil) {
            return nil;
        }

        return @{adUnitId : bidStoreCountForAdUnitId};
    }
}

/// Get the number of bids count per bid for all the ad-unit-ids in the bid-store
- (BID_STORE_COUNT_MAP_TYPE _Nullable)getBidStoreCount {
    @synchronized(self) {
        if (self.multiQueue == nil) {
            return nil;
        }

        return [self.multiQueue getBidStoreCount];
    }
}

@end
