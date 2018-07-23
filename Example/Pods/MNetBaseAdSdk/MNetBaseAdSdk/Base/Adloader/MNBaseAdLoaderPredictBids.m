//
//  MNBaseAdLoaderPredictBids.m
//  Pods
//
//  Created by nithin.g on 13/09/17.
//
//

#import "MNBaseAdLoaderPredictBids+Internal.h"
#import "MNBaseAuctionManager.h"
#import "MNBaseBidStore.h"
#import "MNBaseBlockTimerManager.h"
#import "MNBaseConstants.h"
#import "MNBaseDefaultBidsManager.h"
#import "MNBaseError.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBasePrefetchBids.h"
#import "MNBaseResponseParser.h"
#import "MNBaseResponseTransformerRequestProps.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUrl.h"
#import "MNBaseUtil.h"

@interface MNBaseAdLoaderPredictBids ()

@property (atomic) NSString *adCycleId;
@property (atomic) NSString *visitId;
@property (atomic) NSString *contextUrl;
@property (atomic) UIViewController *viewController;
@property (atomic) NSString *keywords;
@end

@implementation MNBaseAdLoaderPredictBids

- (instancetype)init {
    self                = [super init];
    _cachedBidResponses = [[NSArray alloc] init];
    return self;
}

static BOOL isPostAdLoadPrefetchDisabled = NO;
+ (void)disablePostAdLoadPrefetch {
    isPostAdLoadPrefetchDisabled = YES;
}

#pragma mark - MNBaseAdLoader Protocol methods

+ (instancetype)getLoaderInstance {
    return [[MNBaseAdLoaderPredictBids alloc] init];
}

- (BOOL)canLoadAdForAdUnitId:(NSString *)adUnitId withOptions:(MNBaseAdLoaderOptions *)options {
    if (options != nil) {
        MNBaseAdLoaderType forcedType = [options forceAdLoader];
        if (forcedType != MNBaseAdLoaderTypeNone && forcedType != MNBaseAdLoaderTypePredictBids) {
            return NO;
        }
    }
    return YES;
}

- (NSURLSessionDataTask *)loadAdFor:(MNBaseBidRequest *)bidRequestArg
                        withOptions:(MNBaseAdLoaderOptions *)options
                   onViewController:(UIViewController *)viewController
                            success:(void (^)(MNBaseBidResponsesContainer *_Nullable))successHandler
                               fail:(void (^)(NSError *_Nonnull))failureHandler {
    self.bidRequest = bidRequestArg;
    self.adUnitId   = [self.bidRequest fetchAdUnitId];
    if (self.adUnitId == nil) {
        failureHandler([MNBaseError createErrorWithDescription:@"Ad-unit-id is mandatory for making requests"]);
        return nil;
    }

    // Updating the properties
    self.adCycleId      = [self.bidRequest adCycleId];
    self.visitId        = [self.bidRequest visitId];
    self.contextUrl     = [self.bidRequest fetchContextUrl];
    self.viewController = viewController;
    self.keywords       = [self.bidRequest fetchKeywords];

    // Updating the cache from the bid-store
    [self updateCachedBidResponsesFromBidStore];

    if ([self canPerformAuctionWithCachedEntries]) {
        MNLogD(@"CSA: SENDING CACHED RESPONSES! SKIPPING API-2");
        MNBaseBidResponsesContainer *responsesContainer =
            [[MNBaseAuctionManager getInstance] performAuctionForResponses:self.cachedBidResponses
                                                         madeForBidRequest:self.bidRequest];
        responsesContainer = [self transformFinalBidResponsesContainer:responsesContainer];

        [self performPrefetch];
        successHandler(responsesContainer);
        return nil;
    }

    // If timeout == 1, and CSA failed, then return failure. Do not make the bids call
    if (options != nil && [options timeout] != nil) {
        NSTimeInterval timeInMillis = [[options timeout] doubleValue] * 1000;
        if (timeInMillis <= 1) {
            NSString *errStr =
                [NSString stringWithFormat:@"CSA failed when timeout(in millis) is set to - %f", timeInMillis];
            MNLogD(@"CSA: Error - %@", errStr);
            NSError *csaErr =
                [MNBaseError createErrorWithCode:MNBaseErrCodeCSAFailForSetTimeout withFailureReason:errStr];
            failureHandler(csaErr);
            return nil;
        }
    }

    // Perform the actual request

    // Adding the cached responses into the bid-request
    [self updateBidRequestWithCachedBids];

    // Response handlers
    void (^successResponseHandler)(NSDictionary *_Nonnull) = ^(NSDictionary *responseDict) {
      id<MNBaseResponseParserProtocol> responseParser = [MNBaseResponseParser getParser];
      if (responseParser == nil) {
          failureHandler([MNBaseError createErrorWithDescription:@"Couldn't fetch response-parser"]);
          return;
      }

      NSError *responseError = nil;
      MNBaseResponseParserExtras *parserParams =
          [MNBaseResponseParserExtras getInstanceWithAdCycleId:self.adCycleId
                                                       visitId:self.visitId
                                                    contextUrl:self.contextUrl
                                           viewControllerTitle:[self.bidRequest viewControllerTitle]
                                                viewController:self.viewController
                                                      keywords:self.keywords];

      NSArray<MNBaseBidResponse *> *bidResponsesList = [responseParser parseResponse:responseDict
                                                              exclusivelyForAdUnitId:self.adUnitId
                                                                     withExtraParams:parserParams
                                                                            outError:&responseError];

      if (responseError != nil) {
          failureHandler(responseError);
          return;
      }

      if (bidResponsesList == nil || [bidResponsesList count] == 0) {
          failureHandler([MNBaseError createErrorWithDescription:@"There were no bid-responses available"]);
          return;
      }

      // Recycle the final bid-respnse
      [self recycleBidsFromFinalBidResponses:bidResponsesList];

      [self performPrefetch];

      // TODO: This needs to be generalized.
      // It can be moved into responsesParser, which will return the responsesContainer
      // rather than bidResponsesList.
      // Will do it if there are more like ap logs :)
      NSArray<NSString *> *apLogs = [self fetchApLogsFromResponse:responseDict];

      MNBaseBidResponsesContainer *responsesContainer =
          [MNBaseBidResponsesContainer getInstanceWithBidResponses:bidResponsesList];
      [responsesContainer setApLogs:apLogs];

      MNLogD(@"CSA: PREDICT-BIDS RESPONSES FETCHED!");
      successHandler(responsesContainer);
    };

    void (^failureResponseHandler)(NSError *_Nonnull) = ^(NSError *errorObj) {
      if (errorObj != nil) {
          MNLogD(@"Error response in loader-predict-bids - %@", errorObj);
          MNLogD(@"loader-predict-bids - %@", errorObj);
      }
      [self performPrefetch];

      // Perform client-side auction if possible
      [self updateCachedBidResponsesFromBidStore];
      if (self.cachedBidResponses != nil && [self.cachedBidResponses count] > 0) {
          MNLogD(@"CSA: PREDICT-BIDS PERFORMING CSA AFTER API-2 FAILED. RETURNING SUCCESS");

          // Perform auction here
          MNBaseBidResponsesContainer *responsesContainer =
              [[MNBaseAuctionManager getInstance] performAuctionForResponses:self.cachedBidResponses
                                                           madeForBidRequest:self.bidRequest];
          responsesContainer = [self transformFinalBidResponsesContainer:responsesContainer];
          successHandler(responsesContainer);
          return;
      }

      // Check for default bids here
      MNBaseBidResponsesContainer *responsesContainer =
          [[MNBaseDefaultBidsManager getSharedInstance] getDefaultBidsForBidRequest:self.bidRequest];
      if (responsesContainer != nil) {
          MNLogD(@"CSA: PREDICT-BIDS FAILED! SENDING DEFAULT-BIDS!");
          responsesContainer = [self transformFinalBidResponsesContainer:responsesContainer];
          successHandler(responsesContainer);
          return;
      }
      MNLogD(@"CSA: PREDICT-BIDS FAILED! NO CACHED ENTRIES AND NO API-2 RESPONSE!");
      failureHandler(errorObj);
    };

    // Make the actual requests here
    return [self performAdLoadWithResponseHandlerSuccess:successResponseHandler
                                              andFailure:failureResponseHandler
                                             withOptions:options];
}

- (void)performPrefetch {
    if (isPostAdLoadPrefetchDisabled) {
        return;
    }

    // Make a request to the prefetcher
    __block MNBaseAdRequest *adRequest = [MNBaseAdRequest newRequest];
    [adRequest setAdUnitId:self.adUnitId];
    [adRequest updateContextLink];
    [adRequest updateVCTitle];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      @try {
          MNBasePrefetchBids *prefetcher = [MNBasePrefetchBids getInstance];
          [prefetcher prefetchBidsForAdRequest:adRequest
                                        withCb:^(NSError *_Nullable prefetchErr) {
                                          MNLogD(@"PREFETCH: Finished in post-ad-load");
                                          if (prefetchErr) {
                                              MNLogRemote(@"Error: %@", prefetchErr);
                                          }
                                        }];
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - prefetching bids for ad-request - %@", e);
      }
    });
}

- (BOOL)canPerformAuctionWithCachedEntries {
    if (self.cachedBidResponses == nil || [self.cachedBidResponses count] == 0) {
        return NO;
    }

    // Get the list of bidder_ids from the sdk-config
    NSArray<NSNumber *> *expectedBidderIdsArr =
        [[MNBaseSdkConfig getInstance] getBidderIdsListForAdUnitId:self.adUnitId];
    if (expectedBidderIdsArr == nil || [expectedBidderIdsArr count] == 0) {
        return NO;
    }

    NSMutableArray<NSNumber *> *actualBidderIdsArr =
        [[NSMutableArray alloc] initWithCapacity:[self.cachedBidResponses count]];
    for (MNBaseBidResponse *response in self.cachedBidResponses) {
        NSNumber *bidderId = [response bidderId];
        if (bidderId != nil) {
            [actualBidderIdsArr addObject:bidderId];
        }
    }

    if ([actualBidderIdsArr count] < [expectedBidderIdsArr count]) {
        return NO;
    }
    NSSet *expectedBiddersIdsSet = [NSSet setWithArray:expectedBidderIdsArr];
    NSSet *actualBidderIdsSet    = [NSSet setWithArray:actualBidderIdsArr];
    return [expectedBiddersIdsSet isSubsetOfSet:actualBidderIdsSet];
}

#pragma mark - API request

/// Perform the actual api request
- (NSURLSessionDataTask *)performAdLoadWithResponseHandlerSuccess:
                              (void (^)(NSDictionary *_Nonnull))successResponseHandler
                                                       andFailure:(void (^)(NSError *_Nonnull))failureResponseHandler
                                                      withOptions:(MNBaseAdLoaderOptions *)options {
    NSString *url = [[MNBaseURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *bidRequestBodyStr;
    @try {
        bidRequestBodyStr = [MNJMManager toJSONStr:self.bidRequest];
    } @catch (NSException *exception) {
        MNLogE(@"Exception when converting bid-request into json-str - %@", exception);
        NSError *error = [MNBaseError
            createErrorWithDescription:[NSString
                                           stringWithFormat:@"Exception when converting bid-request into json-str - %@",
                                                            exception]];
        failureResponseHandler(error);
        return nil;
    }

    // Fixing the timeout
    double timeout = DEFAULT_NETWORK_TIMEOUT;
    if (options != nil && options.timeout != nil) {
        timeout = [options.timeout doubleValue];
    }

    // Perform the timeout logic here.
    double timeoutMillis = (timeout * 1000.0f);
    MNLogD(@"DEBUG: TIMEOUT(ms) - %f", timeoutMillis);

    __block MNBaseBlockTimerManager *blockManager = [MNBaseBlockTimerManager
        getInstanceWithTimeoutInMillis:timeoutMillis
                                 block:^{
                                   NSString *errStr = @"Timeout happened. Couldn't load ad";
                                   failureResponseHandler([MNBaseError createErrorWithDescription:errStr]);
                                 }];

    void (^reqSuccessHandler)(NSDictionary *) = ^(NSDictionary *entries) {
      @synchronized(blockManager) {
          if ([blockManager didTimeoutHandlerCall]) {
              return;
          }
          [blockManager setShouldCancelExecution:YES];
      }
      successResponseHandler(entries);
    };

    void (^reqErrorHandler)(NSError *error) = ^(NSError *error) {
      @synchronized(blockManager) {
          if ([blockManager didTimeoutHandlerCall]) {
              return;
          }
          [blockManager setShouldCancelExecution:YES];
      }
      failureResponseHandler(error);
    };

    // Performing the actual request
    NSURLSessionDataTask *dataTask;
    MNLogD(@"Request - %@", bidRequestBodyStr);

    if ([MNBaseUtil canMakeGetRequestFromBody:bidRequestBodyStr]) {
        NSDictionary *params;
        if (bidRequestBodyStr != nil) {
            params = @{@"request" : bidRequestBodyStr};
        }
        MNLogD(@"Bids call(API-2): Performing get request");
        dataTask = [MNBaseHttpClient doGetOn:url
                                     headers:nil
                                      params:params
                                     timeout:timeout
                                     success:reqSuccessHandler
                                       error:reqErrorHandler];
    } else {
        MNLogD(@"Bids call(API-2): Performing post request");
        dataTask = [MNBaseHttpClient doPostOn:url
                                      headers:nil
                                       params:nil
                                         body:bidRequestBodyStr
                                      success:reqSuccessHandler
                                        error:reqErrorHandler];
    }
    return dataTask;
}

#pragma mark - bid-request processing

- (BOOL)updateCachedBidResponsesFromBidStore {
    if (self.cachedBidResponses == nil || [self.cachedBidResponses count] == 0) {
        NSString *adUnitId               = [self.bidRequest fetchAdUnitId];
        NSString *reqUrl                 = [self.bidRequest fetchContextUrl];
        NSArray<MNBaseAdSize *> *adSizes = [self.bidRequest fetchAdSizes];

        if (adUnitId != nil) {
            [self fetchAndCacheBidResponsesForAdUnitId:adUnitId withAdSizes:adSizes andReqUrl:reqUrl];
            return YES;
        }
    }
    return NO;
}

/// Updates the bid request with the cached-bids
/// It conditionally checks if the cached-bids
- (BOOL)updateBidRequestWithCachedBids {
    if (self.cachedBidResponses == nil || [self.cachedBidResponses count] == 0) {
        MNLogD(@"Couldn't update bid-request since there were no cached bids");
        return NO;
    }

    NSMutableArray<MNBaseBidderInfo *> *bidderInfoList =
        [[NSMutableArray<MNBaseBidderInfo *> alloc] initWithCapacity:[self.cachedBidResponses count]];

    for (MNBaseBidResponse *bidResponse in self.cachedBidResponses) {
        MNBaseBidderInfo *bidderInfo = [MNBaseBidderInfo createInstanceFromBidResponse:bidResponse];
        if (bidderInfo != nil) {
            [bidderInfoList addObject:bidderInfo];
        }
    }

    if ([bidderInfoList count] == 0) {
        MNLogD(@"Couldn't update bid-request no bids were found in the cached bid-responses");
        return NO;
    }

    self.bidRequest.bidders = [NSArray arrayWithArray:bidderInfoList];
    return YES;
}

- (BOOL)fetchAndCacheBidResponsesForAdUnitId:(NSString *)adUnitId
                                 withAdSizes:(NSArray<MNBaseAdSize *> *)adSizes
                                   andReqUrl:(NSString *)reqUrl {
    // If already stored, then don't call the bid-store again
    if (self.cachedBidResponses != nil && [self.cachedBidResponses count] > 0) {
        return YES;
    }

    if (adUnitId == nil) {
        return NO;
    }

    id<MNBaseBidStoreProtocol> bidStore = [MNBaseBidStore getStore];
    NSArray<MNBaseBidResponse *> *responsesFromBidStore =
        [bidStore fetchForAdUnitId:adUnitId withAdSizes:adSizes andReqUrl:reqUrl];

    if (responsesFromBidStore == nil || [responsesFromBidStore count] == 0) {
        return NO;
    }
    self.cachedBidResponses = responsesFromBidStore;

    return YES;
}

#pragma mark - Process bid-response-container

- (MNBaseBidResponsesContainer *)transformFinalBidResponsesContainer:
    (MNBaseBidResponsesContainer *)finalBidResponsesContainer {
    if (finalBidResponsesContainer == nil || finalBidResponsesContainer.bidResponsesArr == nil) {
        return nil;
    }

    NSMutableArray *bidResponsesCopy = [finalBidResponsesContainer.bidResponsesArr mutableCopy];

    // NOTE: Not copying the prediction-id from the current-request, since it should already
    // be present in the cached-response if any.
    MNBaseResponseValuesFromRequest *responseExtras = [[MNBaseResponseValuesFromRequest alloc] init];
    responseExtras.adUnitId                         = self.adUnitId;
    responseExtras.visitId                          = self.visitId;
    responseExtras.viewController                   = self.viewController;
    responseExtras.contextUrl                       = self.contextUrl;
    responseExtras.viewControllerTitle              = [self.bidRequest viewControllerTitle];

    // Making sure that auction adCycleId is reflected
    NSString *adCycleId                  = self.adCycleId;
    MNBaseAuctionDetails *auctionDetails = [finalBidResponsesContainer auctionDetails];
    if (auctionDetails != nil && auctionDetails.updatedAdCycleId != nil) {
        adCycleId = auctionDetails.updatedAdCycleId;
    }
    responseExtras.adCycleId = adCycleId;

    id<MNBaseResponseTransformer> transformer                  = [[MNBaseResponseTransformerRequestProps alloc] init];
    NSMutableArray<MNBaseBidResponse *> *finalBidResponsesCopy = [transformer transformBidResponseArr:bidResponsesCopy
                                                                                 withOriginalResponse:nil
                                                                                    andResponseExtras:responseExtras];

    NSArray<MNBaseBidResponse *> *finalBidResponses = [NSArray arrayWithArray:finalBidResponsesCopy];
    [finalBidResponsesContainer setBidResponsesArr:finalBidResponses];
    return finalBidResponsesContainer;
}

#pragma mark - Recycle ad-units

/// This pushes the unused final bid-responses back into the bid-store
- (BOOL)recycleBidsFromFinalBidResponses:(NSArray<MNBaseBidResponse *> *)finalBidResponses {
    if (finalBidResponses == nil || self.cachedBidResponses == nil) {
        return NO;
    }

    // NOTE: Assumption here is that the bid-response can only have one fpd response
    NSNumber *finalFpdBidderId = nil;

    for (MNBaseBidResponse *response in finalBidResponses) {
        // Ignore non-fpd responses
        if ([response.bidType isEqualToString:BID_TYPE_FIRST_PARTY]) {
            finalFpdBidderId = response.bidderId;
        }
    }

    if (finalFpdBidderId == nil) {
        return NO;
    }

    BOOL isPushedToBidStore             = NO;
    id<MNBaseBidStoreProtocol> bidStore = [MNBaseBidStore getStore];

    for (MNBaseBidResponse *response in self.cachedBidResponses) {
        if ([response.bidType isEqualToString:BID_TYPE_FIRST_PARTY] && [response.bidderId isEqual:finalFpdBidderId]) {
            [bidStore insert:response];
        }
    }
    return isPushedToBidStore;
}

#pragma mark - Helper

- (NSArray<NSString *> *)fetchApLogsFromResponse:(NSDictionary *)responsesDict {
    NSDictionary *adsDict = [responsesDict objectForKey:@"ads"];
    if (adsDict == nil || [adsDict count] != 1) {
        return nil;
    }

    NSString *adUnitId         = [[adsDict allKeys] firstObject];
    NSDictionary *adDetailsObj = [adsDict objectForKey:adUnitId];

    NSDictionary *extDict = [adDetailsObj objectForKey:@"ext"];
    if (extDict == nil) {
        return nil;
    }

    NSArray<NSString *> *apLogs = [extDict objectForKey:@"ap_logs"];
    if (apLogs == nil || [apLogs count] == 0) {
        return nil;
    }
    return apLogs;
}

@end
