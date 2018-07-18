//
//  MNBaseAdLoaderPrefetchPredictBids.m
//  Pods
//
//  Created by nithin.g on 19/09/17.
//
//

#import "MNBaseAdLoaderPrefetchPredictBids+Internal.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseResponseParser.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"

@implementation MNBaseAdLoaderPrefetchPredictBids

+ (instancetype _Nonnull)getLoaderInstance {
    return [[MNBaseAdLoaderPrefetchPredictBids alloc] init];
}

- (BOOL)canLoadAdForAdUnitId:(NSString *_Nonnull)adUnitId withOptions:(MNBaseAdLoaderOptions *_Nullable)options {
    if (options != nil && [options forceAdLoader] == MNBaseAdLoaderTypePrefetchPredictBids) {
        return YES;
    }
    return NO;
}

/// Make the ad-loader call for the bid-request
- (NSURLSessionDataTask *_Nullable)loadAdFor:(MNBaseBidRequest *_Nonnull)bidRequest
                                 withOptions:(MNBaseAdLoaderOptions *_Nullable)options
                            onViewController:(UIViewController *_Nullable)viewController
                                     success:(nonnull void (^)(MNBaseBidResponsesContainer *_Nullable))successHandler
                                        fail:(nonnull void (^)(NSError *_Nonnull))failureHandler {
    self.adCycleId      = [bidRequest adCycleId];
    self.visitId        = [bidRequest visitId];
    self.contextUrl     = [bidRequest fetchContextUrl];
    self.viewController = viewController;
    self.adUnitId       = [bidRequest fetchAdUnitId];
    self.keywords       = [bidRequest fetchKeywords];

    [self updateBidRequestWithBidCounts:bidRequest];

    NSString *url = [[MNBaseURL getSharedInstance] getAdLoaderPrefetchPredictBidsUrl];

    // The callbacks
    void (^successResponseHandler)(NSDictionary *_Nonnull) = ^(NSDictionary *responseDict) {

#if defined(DEBUG) || defined(TEST_RELEASE)
      NSData *jsonData          = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
      NSString *responseDataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      MNLogD(@"PREFETCH: Response - %@", responseDataStr);
#endif

      id<MNBaseResponseParserProtocol> responseParser = [MNBaseResponseParser getParser];
      if (responseParser == nil) {
          failureHandler([MNBaseError createErrorWithDescription:@"Couldn't fetch response-parser"]);
          return;
      }

      MNBaseResponseParserExtras *responseExtras =
          [MNBaseResponseParserExtras getInstanceWithAdCycleId:self.adCycleId
                                                       visitId:self.visitId
                                                    contextUrl:self.contextUrl
                                           viewControllerTitle:[bidRequest viewControllerTitle]
                                                viewController:self.viewController
                                                      keywords:self.keywords];

      NSError *responseError                         = nil;
      NSArray<MNBaseBidResponse *> *bidResponsesList = [responseParser parseResponse:responseDict
                                                              exclusivelyForAdUnitId:nil
                                                                     withExtraParams:responseExtras
                                                                            outError:&responseError];

      if (responseError != nil) {
          failureHandler(responseError);
          return;
      }

      MNBaseBidResponsesContainer *responsesContainer =
          [MNBaseBidResponsesContainer getInstanceWithBidResponses:bidResponsesList];
      successHandler(responsesContainer);
    };

    void (^failureResponseHandler)(NSError *_Nonnull) = ^(NSError *errorObj) {
      MNLogD(@"PREFETCH: Failure - %@", errorObj);
      failureHandler(errorObj);
    };

    double timeout = DEFAULT_NETWORK_PREFETCH_TIMEOUT;
    if (options != nil && options.timeout != nil) {
        timeout = [options.timeout longValue];
    }

    NSString *bidRequestBodyStr;
    @try {
        bidRequestBodyStr = [MNJMManager toJSONStr:bidRequest];
    } @catch (NSException *exception) {
        MNLogE(@"Exception when converting bid-request into json-str - %@", exception);
        NSError *error = [MNBaseError
            createErrorWithDescription:[NSString
                                           stringWithFormat:@"Exception when converting bid-request into json-str - %@",
                                                            exception]];
        failureResponseHandler(error);
        return nil;
    }

    MNLogD(@"PREFETCH: Request - %@", bidRequestBodyStr);

    NSURLSessionDataTask *dataTask;
    if ([MNBaseUtil canMakeGetRequestFromBody:bidRequestBodyStr]) {
        NSDictionary *params;
        if (bidRequestBodyStr != nil) {
            params = @{@"request" : bidRequestBodyStr};
        }
        MNLogD(@"Prefetch call(API-1): Performing get request");
        dataTask = [MNBaseHttpClient doGetOn:url
                                     headers:nil
                                      params:params
                                     timeout:timeout
                                     success:successResponseHandler
                                       error:failureResponseHandler];
    } else {
        MNLogD(@"Prefetch call(API-1): Performing post request");
        dataTask = [MNBaseHttpClient doPostOn:url
                                      headers:nil
                                       params:nil
                                         body:bidRequestBodyStr
                                      timeout:timeout
                                      success:successResponseHandler
                                        error:failureResponseHandler];
    }

    return dataTask;
}

- (void)updateBidRequestWithBidCounts:(MNBaseBidRequest *)bidRequest {
    if (bidRequest == nil) {
        return;
    }

    id<MNBaseBidStoreProtocol> bidStore = [MNBaseBidStore getStore];
    BID_STORE_COUNT_MAP_TYPE bidStoreCountMap;
    if (self.adUnitId != nil) {
        bidStoreCountMap = [bidStore getBidStoreCountForAdUnit:self.adUnitId];
    } else {
        bidStoreCountMap = [bidStore getBidStoreCount];
    }
    bidRequest.cachedBidInfoMap = bidStoreCountMap;
}

@end
