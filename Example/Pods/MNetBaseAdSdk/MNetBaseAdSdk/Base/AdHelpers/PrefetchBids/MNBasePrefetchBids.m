//
//  MNBasePrefetchBids.m
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import "MNBaseAdLoader.h"
#import "MNBaseBidStore.h"
#import "MNBaseError.h"
#import "MNBaseLogger.h"
#import "MNBasePrefetchBids+Internal.h"
#import "MNBaseSdkConfig.h"

#define RAISE_ERR(errStr) [MNBaseError createErrorWithDescription:errStr]

@implementation MNBasePrefetchBids

+ (instancetype _Nonnull)getInstance {
    return [[MNBasePrefetchBids alloc] init];
}

- (NSURLSessionDataTask *)prefetchBidsForAdRequest:(MNBaseAdRequest *_Nonnull)adRequest
                                            withCb:(void (^_Nullable)(NSError *_Nullable prefetchErr))prefetchCb {
    if (NO == [[MNBaseSdkConfig getInstance] isAggressiveBiddingEnabled]) {
        prefetchCb([MNBaseError createErrorWithDescription:@"aggressive bidding is disabled"]);
        return nil;
    }

    self.adRequest = adRequest;

    NSError *adRequestErr = [self modifyAdRequest];
    if (adRequestErr != nil) {
        prefetchCb(adRequestErr);
        return nil;
    }

    MNLogD(@"PREFETCH_REQ: Prefetching request with link - %@", [adRequest contextLink]);

    // Perform the actual request here
    MNBaseAdLoaderOptions *options = [MNBaseAdLoaderOptions getDefaultOptions];
    options.forceAdLoader          = MNBaseAdLoaderTypePrefetchPredictBids;

    MNBaseAdLoader *adLoader = [MNBaseAdLoader getSharedInstance];
    NSURLSessionDataTask *task;
    task = [adLoader loadAdFor:adRequest
        withOptions:options
        onViewController:adRequest.rootViewController
        success:^(MNBaseBidResponsesContainer *_Nonnull bidResponsesContainer) {
          MNLogD(@"PREFETCH_REQ: Prefetch response obtained!");
          if (bidResponsesContainer == nil) {
              NSError *loaderErr = [MNBaseError createErrorWithDescription:@"Got empty response in prefetch"];
              prefetchCb(loaderErr);
              return;
          }

          NSArray<MNBaseBidResponse *> *bidResponseArr = [bidResponsesContainer bidResponsesArr];

          // Add the list of bid-responses to the bid-store
          id<MNBaseBidStoreProtocol> bidStore = [MNBaseBidStore getStore];
          for (MNBaseBidResponse *bidResponse in bidResponseArr) {
              [bidStore insert:bidResponse];
          }

          prefetchCb(nil);
        }
        fail:^(NSError *_Nonnull loaderErr) {
          MNLogD(@"PREFETCH_REQ: Prefetch response failed!");
          if (loaderErr == nil) {
              loaderErr = [MNBaseError createErrorWithDescription:@"loadAd Failed in prefetching"];
          }
          prefetchCb(loaderErr);
        }];

    return task;
}

- (NSError *_Nullable)modifyAdRequest {
    if (self.adRequest == nil) {
        return RAISE_ERR(@"Ad-request cannot be empty");
    }

    // Check if the adRequest contains info about the link and the launcher activity
    if (self.adRequest.contextLink == nil || self.adRequest.viewControllerTitle == nil) {
        void (^reqLinkUpdate)(void) = ^(void) {
          [self.adRequest updateContextLink];
          [self.adRequest updateVCTitle];
        };
        if ([NSThread isMainThread]) {
            reqLinkUpdate();
        } else {
            dispatch_sync(dispatch_get_main_queue(), reqLinkUpdate);
        }
    }

    return nil;
}

@end
