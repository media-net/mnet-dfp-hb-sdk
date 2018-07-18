//
//  AdLoader.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdAnalytics.h"
#import "MNBaseAdLoader+Internal.h"
#import "MNBaseAdLoaderPredictBids.h"
#import "MNBaseAdLoaderPrefetchPredictBids.h"
#import "MNBaseAdRequest+Internal.h"
#import "MNBaseBidRequest.h"
#import "MNBaseBidResponse.h"
#import "MNBaseConstants.h"
#import "MNBaseError.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseUrl.h"
#import "MNBaseUtil.h"

@implementation MNBaseAdLoader

+ (void)load {
    [self getSharedInstance];
}

static MNBaseAdLoader *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[[self class] alloc] init];
      [instance setupAdLoaderClasses];
    });
    return instance;
}

- (instancetype)init {
    self             = [super init];
    _adLoaderClasses = [[NSArray alloc] init];
    return self;
}

- (void)setupAdLoaderClasses {
    NSMutableArray<LOADER_ENTRY_TYPE> *adLoaderClasses = [[NSMutableArray<LOADER_ENTRY_TYPE> alloc] init];

    // NOTE - Order matters here.
    // Add the more generic/accomodating ad-loaders at the end, more specific ones at the top
    [adLoaderClasses addObject:[MNBaseAdLoaderPrefetchPredictBids class]];
    [adLoaderClasses addObject:[MNBaseAdLoaderPredictBids class]];

    self.adLoaderClasses = [NSArray<LOADER_ENTRY_TYPE> arrayWithArray:adLoaderClasses];
}

/// Makes an http request for the MNBaseBidRequest and returns array of bid-responses, with the given options object
- (NSURLSessionDataTask *)loadAdFor:(MNBaseAdRequest *_Nonnull)adRequest
                        withOptions:(MNBaseAdLoaderOptions *)options
                   onViewController:(UIViewController *_Nullable)viewController
                            success:(nonnull void (^)(MNBaseBidResponsesContainer *))successHandler
                               fail:(nonnull void (^)(NSError *_Nonnull))failureHandler {
    if (options == nil) {
        options = [MNBaseAdLoaderOptions getDefaultOptions];
    }
    NSString *adUnitId = adRequest.adUnitId;

    id<MNBaseAdLoaderProtocol> loader = [self getLoaderForAdUnitId:adUnitId andOptions:options];
    if (loader == nil) {
        failureHandler(
            [MNBaseError createErrorWithDescription:@"Cannot make ad-request since there are no ad-loaders"]);
        return nil;
    }

    NSError *requestErr;
    MNBaseBidRequest *bidRequest = [self createBidRequest:adRequest errorOut:&requestErr];
    if (requestErr != nil) {
        failureHandler(requestErr);
        return nil;
    }

    __block NSString *adCycleId = adRequest.adCycleId;
    [[MNBaseAdAnalytics getSharedInstance] logStartTimeForEvent:MnetAdAnalyticsTypeDpResponse withAdCycleId:adCycleId];

    void (^successCbFromAdLoader)(MNBaseBidResponsesContainer *_Nullable) = ^(
        MNBaseBidResponsesContainer *_Nullable bidResponsesContainer) {
      [[MNBaseAdAnalytics getSharedInstance] logEndTimeForEvent:MnetAdAnalyticsTypeDpResponse withAdCycleId:adCycleId];
      successHandler(bidResponsesContainer);
    };

    void (^errorCbFromAdLoader)(NSError *_Nonnull) = ^(NSError *_Nonnull loadErr) {
      [[MNBaseAdAnalytics getSharedInstance] logEndTimeForEvent:MnetAdAnalyticsTypeDpResponse withAdCycleId:adCycleId];
      failureHandler(loadErr);
    };

    return [loader loadAdFor:bidRequest
                 withOptions:options
            onViewController:viewController
                     success:successCbFromAdLoader
                        fail:errorCbFromAdLoader];
}

- (id<MNBaseAdLoaderProtocol> _Nullable)getLoaderForAdUnitId:(NSString *_Nonnull)adUnitId
                                                  andOptions:(MNBaseAdLoaderOptions *_Nullable)options;
{
    if ([self.adLoaderClasses count] == 0) {
        return nil;
    }

    /*
     NOTE:
     Creating an object for every ad-loader call. Why?
     This is so there would not be any sync issues.
     Didn't want to use a lock here
    */
    id<MNBaseAdLoaderProtocol> selectedLoader;
    for (LOADER_ENTRY_TYPE loaderClass in self.adLoaderClasses) {
        id<MNBaseAdLoaderProtocol> loader = [loaderClass getLoaderInstance];
        if (loader != nil) {
            if ([loader canLoadAdForAdUnitId:adUnitId withOptions:options]) {
                selectedLoader = loader;
                break;
            }
        }
    }

    // Pop the last item, if nothing works
    if (selectedLoader == nil) {
        LOADER_ENTRY_TYPE loaderClass = [self.adLoaderClasses lastObject];
        selectedLoader                = [loaderClass getLoaderInstance];
    }

    return selectedLoader;
}

#pragma mark - Helpers

/// Validates the given adRequest and creates a Bid-request
- (MNBaseBidRequest *)createBidRequest:(MNBaseAdRequest *_Nonnull)adRequest errorOut:(NSError **)requestErr {
    if (adRequest == nil) {
        NSString *errString = @"The request cannot be nil";
        if (requestErr != NULL) {
            (*requestErr) = [MNBaseError createErrorWithDescription:errString];
        } else {
            MNLogD(@"%@", errString);
        }
        return nil;
    }

    MNBaseBidRequest *bidRequest = [MNBaseBidRequest create:adRequest];
    return bidRequest;
}

@end

@implementation MNBaseAdLoaderOptions

+ (instancetype)getDefaultOptions {
    return [[MNBaseAdLoaderOptions alloc] init];
}

- (instancetype)init {
    self           = [super init];
    _timeout       = [NSNumber numberWithLong:DEFAULT_NETWORK_TIMEOUT];
    _forceAdLoader = MNBaseAdLoaderTypeNone;
    return self;
}

@end
