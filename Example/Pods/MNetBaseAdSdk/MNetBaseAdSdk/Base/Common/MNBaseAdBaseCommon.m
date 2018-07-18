//
//  MNBaseAdBaseCommon.m
//  Pods
//
//  Created by nithin.g on 28/02/17.
//
//

#import "MNBase.h"
#import "MNBaseAdAnalytics.h"
#import "MNBaseAdBaseCommon+Internal.h"
#import "MNBaseAdController.h"
#import "MNBaseAdDetailsStore.h"
#import "MNBaseAdLoader.h"
#import "MNBaseAdSizeConstants.h"
#import "MNBaseAdViewStore.h"
#import "MNBaseAuctionLoggerManager.h"
#import "MNBaseBidRequest.h"
#import "MNBaseBidResponseTypeInfo.h"
#import "MNBaseConstants.h"
#import "MNBaseDefaultBidsManager.h"
#import "MNBaseError.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLinkStore.h"
#import "MNBaseLogger.h"
#import "MNBaseMacroManager.h"
#import "MNBasePulseTracker.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"
#import "MNBaseWeakTimerTarget.h"
#import <MNALAppLink/MNALAppLink.h>
#import <objc/runtime.h>

@implementation MNBaseAdBaseCommon {
    MNBaseAdController *adControllerObj;
    void (^MNSuccessCallback)(MNBaseBidResponse *bidResponse);
    void (^MNErrorCallback)(NSError *error);
}

#pragma mark - Init methods

/// Initialise with the surrogate instance, and if the ad is interstitial or not.
- (MNBaseAdBaseCommon *)initWithSurrogate:(id)surrogateModule andInterstitial:(BOOL)isInterstitial {
    self = [super init];
    if (self) {
        _surrogateModule = surrogateModule;
        _isInterstitial  = isInterstitial;
        _autoRefresh     = [[MNBaseSdkConfig getInstance] getIsAutorefresh];
        [self initializeListeners];
        _responsesContainer = [MNBaseBidResponsesContainer getInstanceWithBidResponses:nil];
        _isAdShown          = NO;
        _isAdLoaded         = NO;
        _isLoggingCallMade  = NO;
        _isReuseReady       = NO;
        _adViewStatus       = MNBaseAdViewStatusInit;
        _videoAdStatus      = MNBaseVideoStatusInit;
        _adViewLock         = [[NSLock alloc] init];
    }
    return self;
}

/// Initialize all the notification listeners for the app
- (void)initializeListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationHasEnteredForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationHasEnteredBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark - Listeners
- (void)applicationHasEnteredForeground {
    self.isRefreshDisabled = NO;

    /*
     Reasoning for viewBasedRefreshConditions:
     This is based on the assumption that video refreshing will start after the player has finished
     playing the video once.
     If video has not been played fully once, then on coming to foreground, the video should resume.
     If video has been played fully, then refresh starts.
     If the app comes to the foreground long after refresh ended, then the video needs to be refreshed
     */

    BOOL basicRefreshFlagConditions = (self && self.autoRefresh && !self.isRefreshing);
    BOOL viewBasedRefreshConditions = (!self.isInterstitial && (self.adRequest && self.videoPlayerCompleted));

    if (basicRefreshFlagConditions && viewBasedRefreshConditions) {
        [self forceRefreshwithSuccessCb:MNSuccessCallback withErrorCb:MNErrorCallback];
    }
}

- (void)applicationHasEnteredBackground {
    self.isRefreshDisabled = YES;
}

- (void)adViewLayoutChanged {
    MNLogD(@"AD_VIEW_STATUS_DIFF: MNBaseAdViewStatusLayoutChanged");
    [self fireLoggingEventsConditionally];
}

- (void)adViewStatusChange:(MNBaseAdViewStatus)status {
    switch (status) {
    case MNBaseAdViewStatusShown:
        MNLogD(@"AD_VIEW_STATUS_DIFF: MNBaseAdViewStatusShown");
        self.isAdShown = YES;
        break;
    case MNBaseAdViewStatusLoaded:
        MNLogD(@"AD_VIEW_STATUS_DIFF: MNBaseAdViewStatusLoaded");
        self.isAdLoaded = YES;
        break;
    case MNBaseAdViewStatusFailed:
    case MNBaseAdViewStatusInit:
    case MNBaseAdViewStatusInvalid:
    case MNBaseAdViewStatusAdReqSent:
    case MNBaseAdViewStatusAdRespReceived:
    default:
        break;
    }
    [self fireLoggingEventsConditionally];
}

- (void)fireLoggingEventsConditionally {
    // Make sure to fire logging calls only when ad is loaded and visible
    if (self.isAdShown && self.isAdLoaded && [self isLayoutValid]) {
        @synchronized(self) {
            // Check if the call has already been made
            if (self.isLoggingCallMade) {
                MNLogD(@"AD_VIEW_STATUS_DIFF: logging call has already been made. Ignoring it");
                return;
            }
            MNLogD(@"AD_VIEW_STATUS_DIFF: Making logging calls!");
            [self makeViewVisibleLogRequests];
            self.isLoggingCallMade = YES;
        }
    }
}

/// Checks if the ad size is valid. Returns YES if ad-view is interstitial
- (BOOL)isLayoutValid {
    // Return early if the ad-view is interstitial
    if (self.isInterstitial) {
        return YES;
    }

    if (self.surrogateModule == nil || NO == [self.surrogateModule isKindOfClass:[UIView class]]) {
        return NO;
    }
    UIView *adView          = (UIView *) self.surrogateModule;
    CGSize adViewDimensions = [adView bounds].size;
    if (CGSizeEqualToSize(adViewDimensions, CGSizeZero)) {
        return NO;
    }

    // get the response adview-size
    if (adControllerObj == nil || [adControllerObj adResponse] == nil) {
        return NO;
    }
    MNBaseBidResponse *bidResponse = [adControllerObj adResponse];
    CGSize responseAdViewSize      = [MNBaseUtil getAdSizeFromStringFormat:[bidResponse size]];
    if (CGSizeEqualToSize(responseAdViewSize, CGSizeZero)) {
        return NO;
    }

    // Check if adViewDimensions is atleast as big as responseAdViewSize
    return (adViewDimensions.width >= responseAdViewSize.width && adViewDimensions.height >= responseAdViewSize.height);
}

#pragma mark - Setters and getters

@synthesize contextLink = _contextLink;
- (NSString *)contextLink {
    return _contextLink;
}

- (void)setContextLink:(NSString *)contextLink {
    if ([MNBaseUtil isHttpUrl:contextLink]) {
        _contextLink = contextLink;
    }
}

@synthesize adViewStatus = _adViewStatus;
- (MNBaseAdViewStatus)adViewStatus {
    return _adViewStatus;
}

- (void)setAdViewStatus:(MNBaseAdViewStatus)adViewStatus {
    MNLogD(@"ADVIEW_STATUS: Called %@ !", [self getStrForStatus:adViewStatus]);
    // NOTE: Update ad-loaded status only if the internal webview is not already added to the view-tree.
    // If the ad-view is added to the view-tree before,(no-shimmer-view case) shown will never be the last entry
    if (NO == (adViewStatus == MNBaseAdViewStatusLoaded && _adViewStatus == MNBaseAdViewStatusShown)) {
        MNLogD(@"ADVIEW_STATUS: Setting %@", [self getStrForStatus:adViewStatus]);
        _adViewStatus = adViewStatus;
    }

    // Miscellaneous calls on status change

    // ad-view-status-change call
    // Do not unnecessarily call the adviewStatusChange for other keys
    switch (adViewStatus) {
    case MNBaseAdViewStatusLoaded:
    case MNBaseAdViewStatusShown: {
        [self adViewStatusChange:adViewStatus];
        break;
    }
    default: {
        // pass
        break;
    }
    }

    // Call adx logs on status-loaded
    if (self.isInterstitial == NO && adViewStatus == MNBaseAdViewStatusLoaded) {
        [self adxCallbacks];
    }

    // Release the locks if ad-failed or loaded
    if (adViewStatus == MNBaseAdViewStatusLoaded || adViewStatus == MNBaseAdViewStatusFailed) {
        [self releaseLock];
    }
}

@synthesize videoAdStatus = _videoAdStatus;
- (MNBaseVideoAdStatus)videoAdStatus {
    return _videoAdStatus;
}

- (void)setVideoAdStatus:(MNBaseVideoAdStatus)videoAdStatus {
    _videoAdStatus = videoAdStatus;

    // Mapping video-ad-status into the relevant ad-view-statuses
    switch (videoAdStatus) {
    case MNBaseVideoStatusInvalid: {
        [self setAdViewStatus:MNBaseAdViewStatusInvalid];
        break;
    }
    case MNBaseVideoStatusInit: {
        [self setAdViewStatus:MNBaseAdViewStatusInit];
        break;
    }
    case MNBaseVideoStatusLoaded: {
        [self setAdViewStatus:MNBaseAdViewStatusLoaded];
        break;
    }
    case MNBaseVideoStatusFailed: {
        [self setAdViewStatus:MNBaseAdViewStatusFailed];
        break;
    }
    default:
        break;
    }
}

- (NSString *)getStrForStatus:(MNBaseAdViewStatus)adViewStatus {
    NSString *adViewStatusStr = @"unknown";
    switch (adViewStatus) {
    case MNBaseAdViewStatusInvalid: {
        adViewStatusStr = @"MNBaseAdViewStatusInvalid";
        break;
    }
    case MNBaseAdViewStatusFailed: {
        adViewStatusStr = @"MNBaseAdViewStatusFailed";
        break;
    }
    case MNBaseAdViewStatusInit: {
        adViewStatusStr = @"MNBaseAdViewStatusInit";
        break;
    }
    case MNBaseAdViewStatusAdReqSent: {
        adViewStatusStr = @"MNBaseAdViewStatusAdReqSent";
        break;
    }
    case MNBaseAdViewStatusAdRespReceived: {
        adViewStatusStr = @"MNBaseAdViewStatusAdRespReceived";
        break;
    }
    case MNBaseAdViewStatusLoaded: {
        adViewStatusStr = @"MNBaseAdViewStatusLoaded";
        break;
    }
    case MNBaseAdViewStatusShown: {
        adViewStatusStr = @"MNBaseAdViewStatusShown";
        break;
    }

    default:
        break;
    }
    return adViewStatusStr;
}

#pragma mark - Loader Helpers

- (MNBaseAdRequest *)createAdRequestWithSelf {
    MNBaseAdRequest *request = [MNBaseAdRequest newRequest];
    [request setAdUnitId:self.adUnitId];
    [request setCustomGeoLocation:self.customGeoLocation];

    if (NO == self.isInterstitial && self.adSizes != nil && [self.adSizes count] > 0) {
        [request setAdSizes:[self getUniqueAdSizes:self.adSizes]];
    }

    if (self.contextLink != nil && [self.contextLink isEqualToString:@""] == NO) {
        [request setContextLink:self.contextLink];
    }
    return request;
}

/// Validate non-prefetch ads. This internally calls validateAndModifyRequest
- (NSError *)validateAndModifyNonPrefetchRequest {
    if (self.onGoingTask) {
        return [MNBaseError createErrorWithCode:MNBaseErrCodeAdViewBusy withFailureReason:nil];
    }

    // Every non-interstitial ad is expected to have the rootViewController set.
    if (!self.rootViewController && !self.isInterstitial) {
        NSString *rootVCErrStr = @"rootViewController is a mandatory property to be set on the adview!";
        return [MNBaseError createErrorWithCode:MNBaseErrCodeRootViewControllerNil withFailureReason:rootVCErrStr];
    }

    // Validating the request and adding from self, if some properties aren't defined
    if (self.adRequest == nil) {
        self.adRequest = [self createAdRequestWithSelf];
    }

    NSError *invalidRequestErr = [self validateAndModifyRequest];

    if (invalidRequestErr != nil) {
        return invalidRequestErr;
    } else if (self.adRequest == nil) {
        return [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdRequest withFailureReason:nil];
    }

    return nil;
}

/// Validate the ad request and fill it's contents from the adBaseCommon
- (NSError *)validateAndModifyRequest {
    // If adUnitId is not defined anywhere, then request is invalid
    if (self.adUnitId == nil && self.adRequest.adUnitId == nil) {
        return [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdUnitId
                              withFailureReason:@"Ad unit id for is nil while modifiying dfp request"];
        ;
    }

    if (self.adRequest.adUnitId == nil) {
        self.adRequest.adUnitId = self.adUnitId;
    }

    // This needs to be taken in from the base, regardless of what is set
    self.adRequest.isInterstitial = [self isInterstitial];
    // Set the size for interstitial. Better explicit than implicit :)
    if (self.adRequest.isInterstitial) {
        self.adRequest.adSizes = [[NSArray alloc] init];
    }

    if (self.adRequest.isInterstitial == NO && self.adSizes == nil && self.adRequest.adSizes == nil) {
        return [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdSize withFailureReason:nil];
    }

    if (self.adRequest.isInterstitial == NO && self.adRequest.adSizes == nil) {
        [self.adRequest setAdSizes:[self getUniqueAdSizes:self.adSizes]];
    }

    [self.adRequest setVisitId:[[MNBase getInstance] getVisitId]];
    [self.adRequest setAdCycleId:[MNBaseUtil generateAdCycleId]];

    // Checking for keywords
    // NOTE: The adRequest object takes precedence.
    // If the ad Request has keywords, then it's not over-written
    // (The keywords is not public for adRequests, hence, the above mentioned will only
    // happen during prefetch)
    NSString *requestKeywords = [self.adRequest keywords];
    if (requestKeywords == nil || [requestKeywords isEqualToString:@""]) {
        if (self.keywords && [self.keywords isEqualToString:@""] == NO) {
            self.adRequest.keywords = self.keywords;
        }
    }

    if (self.contextLink != nil && [self.contextLink isEqualToString:@""] == NO) {
        self.adRequest.contextLink = self.contextLink;
    }

    self.adRequest.rootViewController = self.rootViewController;
    [self.adRequest updateContextLink];
    [self.adRequest updateVCTitle];

    MNBaseUser *userDetails;
    if (self.requestSpecficUser != nil) {
        userDetails = self.requestSpecficUser;
    } else if (self.adRequest.userDetails == nil) {
        userDetails = [[MNBase getInstance] user];
    }
    self.adRequest.userDetails = userDetails;

    // Update the custom-extras in the ad-request
    [self.adRequest setCustomExtras:self.customExtras];

    return nil;
}

- (NSArray<MNBaseAdSize *> *)getUniqueAdSizes:(NSArray<MNBaseAdSize *> *)adSizes {
    if (adSizes == nil || [adSizes count] == 0) {
        return @[];
    }

    // Iterate over available ad sizes and store it as NSValue to get unique values
    NSMutableArray<MNBaseAdSize *> *sizes = [NSMutableArray new];
    NSMutableDictionary *sizesValueDict   = [NSMutableDictionary new];

    for (MNBaseAdSize *adSize in adSizes) {
        [sizesValueDict setObject:@"MNBaseAdSize" forKey:[NSValue valueWithCGSize:MNBaseCGSizeFromAdSize(adSize)]];
    }
    for (NSValue *value in [sizesValueDict allKeys]) {
        [sizes addObject:MNBaseAdSizeFromCGSize([value CGSizeValue])];
    }
    return [sizes copy];
}

#pragma mark - Lock methods

- (BOOL)tryAcquireLock {
    BOOL finalVal = NO;
    if (self.adViewLock == nil) {
        MNLogD(@"AD_VIEW_LOCK: Cannot try to acquire lock since the ad-view-lock is not initialized!");
        finalVal = NO;
    } else {
        finalVal = [self.adViewLock tryLock];
    }
    MNLogD(@"AD_VIEW_LOCK: Acquiring lock success? - %@", (finalVal) ? @"YES" : @"NO");
    return finalVal;
}

- (BOOL)releaseLock {
    BOOL finalVal = NO;
    @try {
        if (self.adViewLock == nil) {
            MNLogD(@"AD_VIEW_LOCK: Cannot try to release lock since the ad-view-lock is not initialized!");
            finalVal = NO;
        } else {
            [self.adViewLock unlock];
            finalVal = YES;
        }
    } @catch (NSException *lockErr) {
        MNLogE(@"AD_VIEW_LOCK: Release lock exception - %@", lockErr);
        finalVal = NO;
    }
    MNLogD(@"AD_VIEW_LOCK: Releasing lock success? - %@", (finalVal) ? @"YES" : @"NO");
    return finalVal;
}

#pragma mark - Loader methods

- (void)loadAdWithSuccessResp:(void (^)(MNBaseBidResponse *bidResponse))successCb
                  withErrorCb:(void (^)(NSError *error))errorCb {
    if (NO == [self tryAcquireLock]) {
        MNLogPublic(@"Load-ad called repeatedly on same instance");
        return;
    }

    // Performing all sorts of validations
    if (self.isPrefetchMode) {
        if (self.adViewStatus == MNBaseAdViewStatusAdRespReceived) {
            [self handleAdControllerWithSuccess:successCb andError:errorCb];
        } else {
            NSString *errReason = @"Prefetching failed!";
            if (self.adViewStatus < MNBaseAdViewStatusAdRespReceived) {
                errReason = @"Prefetching is not complete!";
            }
            errorCb([MNBaseError createErrorWithCode:MNBaseErrCodePrefetchLoadFailed withFailureReason:errReason]);
        }

        return;
    }

    NSError *errValidatingAdRequest = [self validateAndModifyNonPrefetchRequest];
    if (errValidatingAdRequest != nil) {
        errorCb(errValidatingAdRequest);
        return;
    }

    // Storing the callbacks for when the refresh event is called!
    MNErrorCallback   = errorCb;
    MNSuccessCallback = successCb;

    // Setting the video player status before loading.
    self.videoPlayerCompleted = NO;

    [self loadAdForRequest:self.adRequest withSuccessCb:successCb withErrorCb:errorCb];
}

- (void)loadAdForRequest:(MNBaseAdRequest *)request
           withSuccessCb:(void (^)(MNBaseBidResponse *bidResponse))successCb
             withErrorCb:(void (^)(NSError *error))errorCb {
    if (self.onGoingTask) {
        errorCb([MNBaseError createErrorWithCode:MNBaseErrCodeAdViewBusy withFailureReason:nil]);
        return;
    }
    NSString *adCycleId = request.adCycleId;

    // Update the status
    [self setAdViewStatus:MNBaseAdViewStatusAdReqSent];

    __block NSTimeInterval timestampBeforeRequest = [[NSDate date] timeIntervalSince1970];
    MNBaseAdLoader *loader                        = [MNBaseAdLoader getSharedInstance];
    self.onGoingTask                              = [loader loadAdFor:request
        withOptions:nil
        onViewController:self.rootViewController
        success:^(MNBaseBidResponsesContainer *bidResponsesContainer) {
          [self postAdLoaderResponseWithContainer:bidResponsesContainer];
          [self setAdViewStatus:MNBaseAdViewStatusAdRespReceived];

          NSTimeInterval timestampAfterRequest = [[NSDate date] timeIntervalSince1970];
          NSTimeInterval responseTime          = timestampAfterRequest - timestampBeforeRequest;

          id customData = @{@"time" : [NSString stringWithFormat:@"%f", responseTime], @"adCycleId" : adCycleId};
          [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventResponseDuration andCustomData:customData];

          [self handleAdControllerWithSuccess:successCb andError:errorCb];
        }
        fail:^(NSError *error) {
          MNLogD(@"Got error %@", error);
          MNLogRemote(@"Error - %@", error);
          [self setAdViewStatus:MNBaseAdViewStatusFailed];

          [self postAdLoaderResponseWithContainer:nil];
          if (errorCb) {
              errorCb(error);
          }
        }];
}

#pragma mark - Prefetch methods

- (void)prefetchForRequest:(MNBaseAdRequest *)request
           timeoutInMillis:(NSNumber *_Nullable)timeoutInMillis
                   success:(void (^)(NSDictionary *_Nonnull, NSString *_Nonnull, BOOL))successHandler
                   failure:(void (^)(NSError *_Nonnull, NSString *_Nonnull))failureHandler {
    if (NO == [self tryAcquireLock]) {
        MNLogPublic(@"Prefetch called repeatedly on same instance");
        return;
    }

    if (self.onGoingTask) {
        MNLogE(@"Aborting prefetching View is already performing loadAD");
        self.adViewStatus = MNBaseAdViewStatusFailed;
        [self releaseLock];
        return;
    }

    request.isInternal  = YES;
    self.isPrefetchMode = YES;
    self.adRequest      = request;

    NSError *adRequestError = [self validateAndModifyRequest];

    if (adRequestError != nil || self.adRequest == nil) {
        if (adRequestError != nil) {
            failureHandler(adRequestError, [self.adRequest adCycleId]);
        } else if (self.adRequest == nil) {
            failureHandler([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdRequest withFailureReason:nil], @"");
        }
        [self releaseLock];
        return;
    }

    // Update the status
    [self setAdViewStatus:MNBaseAdViewStatusAdReqSent];

    NSNumber *timeoutInSecs;
    if (timeoutInMillis == nil) {
        timeoutInSecs = [NSNumber numberWithDouble:DEFAULT_NETWORK_PREFETCH_TIMEOUT];
    } else {
        timeoutInSecs = [NSNumber numberWithDouble:([timeoutInMillis doubleValue] / 1000)];
    }

    MNBaseAdLoaderOptions *options = [[MNBaseAdLoaderOptions alloc] init];
    [options setTimeout:timeoutInSecs];

    __block MNBaseAdBaseCommon *selfRef = self;

    MNBaseAdLoader *loader = [MNBaseAdLoader getSharedInstance];
    self.onGoingTask       = [loader loadAdFor:request
        withOptions:options
        onViewController:self.rootViewController
        success:^(MNBaseBidResponsesContainer *bidResponsesContainer) {
          [self releaseLock];

          [selfRef setAdViewStatus:MNBaseAdViewStatusAdRespReceived];
          [selfRef postAdLoaderResponseWithContainer:bidResponsesContainer];

          BOOL areDefaultBids = NO;
          if (bidResponsesContainer) {
              areDefaultBids = bidResponsesContainer.areDefaultBids;
          }
          successHandler(self.serverExtrasDict, selfRef.adRequest.adCycleId, areDefaultBids);
        }
        fail:^(NSError *error) {
          [self releaseLock];

          MNLogRemote(@"Got error %@", error);
          [selfRef postAdLoaderResponseWithContainer:nil];
          [selfRef setAdViewStatus:MNBaseAdViewStatusFailed];
          failureHandler(error, selfRef.adRequest.adCycleId);
        }];
}

#pragma mark - Ad-Refresh and Timer related methods

- (void)refreshSelfWithExtraDuration:(NSNumber *)duration {
    if (!self.isInterstitial && self.autoRefresh && !self.isRefreshing && !self.isRefreshDisabled) {
        MNBaseWeakTimerTarget *timerTarget = [[MNBaseWeakTimerTarget alloc] init];
        [timerTarget setTarget:self];

        [timerTarget setSelector:NSSelectorFromString(@"timerCallback:")];

        if (self.refreshDuration == nil) {
            self.refreshDuration = [NSNumber numberWithInteger:DEFAULT_REFRESH_RATE];
        }

        long refreshDurationVal = [self.refreshDuration longValue];

        if (duration != nil) {
            long durationVal = [duration longValue];
            if (durationVal > 0) {
                refreshDurationVal += durationVal;
            }
        }

        [NSTimer scheduledTimerWithTimeInterval:refreshDurationVal
                                         target:timerTarget
                                       selector:timerTarget.timerFireTargetSelector
                                       userInfo:nil
                                        repeats:NO];
        self.isRefreshing = YES;
    } else {
        MNLogD(@"Not refreshing the ad");
    }
}

- (void)timerCallback:(NSTimer *)timer {
    [timer invalidate];
    timer = nil;

    if (self) {
        self.isRefreshing = NO;
        if (!self.isRefreshDisabled) {
            adControllerObj = nil;
            [self forceRefreshwithSuccessCb:MNSuccessCallback withErrorCb:MNErrorCallback];
        } else {
            MNLogD(@"Not refreshing ad since isRefreshStopped is set");
        }
    }
}

- (void)forceRefreshwithSuccessCb:(void (^)(MNBaseBidResponse *bidResponse))successCb
                      withErrorCb:(void (^)(NSError *error))errorCb {
    if (self.onGoingTask != nil) {
        [self cancelCurrentTask];
    }

    [self loadAdWithSuccessResp:successCb withErrorCb:errorCb];
}

- (void)checkAndUpdateAutoRefreshDetails {
    if (!self.adUnitId || self.isInterstitial) {
        NSString *errStr = @"Not updating auto-refresh params for interstitial ad";
        if (!self.adUnitId) {
            errStr = @"Cannot update auto-refresh params for empty adunit";
        }
        MNLogD(@"%@", errStr);
        return;
    }

    // this will be set from the creative id config
    MNBaseSdkConfig *sdkConfig = [MNBaseSdkConfig getInstance];
    BOOL isAutoRefreshEnabled  = [sdkConfig getAutoRefreshStatusForAdUnitId:[self adUnitId]];

    if (isAutoRefreshEnabled) {
        NSNumber *autoRefreshInterval = [sdkConfig getAutoRefreshIntervalForAdUnitId:[self adUnitId]];

        if (autoRefreshInterval != nil && [autoRefreshInterval intValue] > 0) {
            [self setAutoRefresh:YES];
            [self setRefreshDuration:autoRefreshInterval];
        }
    }
}

#pragma mark - AdEx methods
- (BOOL)checkIfAdExPresentInResponse {
    self.isAdxEnabled   = NO;
    self.adxBidResponse = [self.responsesContainer getBidResponseForBidType:BID_TYPE_ADX];
    if (self.adxBidResponse == nil) {
        return NO;
    }

    MNBaseBidResponse *selectedBidResponse = [self.responsesContainer getSelectedBidResponseCandidate];
    if (selectedBidResponse != nil) {
        NSString *bidType = selectedBidResponse.bidType;

        if (bidType) {
            BOOL firstPartyCheck = [bidType isEqualToString:BID_TYPE_FIRST_PARTY];
            BOOL thirdPartyCheck = ([bidType isEqualToString:BID_TYPE_THIRD_PARTY] &&
                                    [[MNBaseSdkConfig getInstance] getIsAdxEnabledForThirdParty]);
            self.isAdxEnabled    = (firstPartyCheck || thirdPartyCheck);
        }

        MNLogD(@"ADX: The bidType that's won - %@", bidType);
        MNLogD(@"ADX: The bidder Id that's won - %@", [selectedBidResponse.bidderId stringValue]);
        MNLogD(@"ADX: Inside checkIfAdExPresentInResponse - %@", (self.isAdxEnabled) ? @"YES" : @"NO");
    }

    return self.isAdxEnabled;
}

- (void)updateAdDetailsForAdx {
    // Adding the current bid in the adx response to ad details
    [[MNBaseAdDetailsStore getSharedInstance] updateAdxBid:self.adxBidResponse.ogBid
                                                 forAdunit:self.adxBidResponse.creativeId
                                                  andPubId:self.adxBidResponse.publisherId];

    // Adding the fpd response bid to the ad details
    MNBaseBidResponse *fpdBidResponse = [self.responsesContainer getBidResponseForBidType:BID_TYPE_FIRST_PARTY];
    if (fpdBidResponse != nil) {
        [[MNBaseAdDetailsStore getSharedInstance] updateBid:fpdBidResponse.ogBid
                                                  forAdunit:fpdBidResponse.creativeId
                                                   andPubId:fpdBidResponse.publisherId];
    }
}

- (void)initializeAdxFlowWithSuccess:(void (^)(MNBaseBidResponse *bidResponse))successCb
                            andError:(void (^)(NSError *error))errorCb {
    if (nil == self.adxBidResponse) {
        MNLogRemote(@"No adx response for initializing the ad ex flow!");
        [self selectAndInitializeAdWithSuccess:successCb andError:errorCb];
        return;
    }

    [self updateAdDetailsForAdx];

    [self cloneAndStoreAd];

    NSString *classStr           = MNET_DFP_AD_CONTROLLER;
    NSString *instanceMethodName = SEL_MNET_DFP_AD_CONTROLLER;

    [self performLoggingForAdxOfLogKey:MNBaseAdxLogLoad];

    [self createAdControllerForClassStr:classStr
                 withInstanceMethodName:instanceMethodName
                            forResponse:self.adxBidResponse
                          withSuccessCb:successCb
                            withErrorCb:errorCb];
}

- (void)performLoggingForAdxOfLogKey:(MNBaseAdxLoggingUrlsMapper)logKey {
    MNLogD(@"ADX: inside perform logging for adx key - %ld", (long) logKey);

    // Adding the log entry
    MNBaseBidResponseExtension *extension = [self.adxBidResponse extension];
    if (extension == nil) {
        return;
    }

    NSArray<NSString *> *loggingUrlList = [extension getAdxLogListForKey:logKey];
    if (loggingUrlList == nil) {
        return;
    }

    if (loggingUrlList && [loggingUrlList count] > 0) {
        for (NSString *loggingUrl in loggingUrlList) {
            if (loggingUrl && ![loggingUrl isEqualToString:@""]) {
                [MNBaseHttpClient doGetWithStrResponseOn:loggingUrl
                    headers:nil
                    shouldRetry:YES
                    success:^(NSString *_Nonnull response) {
                      MNLogD(@"Call to %@ is successful", loggingUrl);
                    }
                    error:^(NSError *_Nonnull error) {
                      MNLogD(@"Call to %@ failed with error - %@", loggingUrl, error);
                    }];
            }
        }
    }
}

- (void)cloneAndStoreAd {
    // TODO MNBase Move this block of code to dedicated ad slot SDK
    /*
        MNBaseAdRequest *adRequestClone                    = self.adRequest;
        NSString *bidderIdStrClone                         = [self.selectedBidderIdStr copy];
        NSString *adViewKey                                = [self generateAdViewKeyFromRequestForAdx:self.adRequest];
        NSArray<MNBaseBidResponse *> *bidResponsesArrClone = [self.responsesContainer getBidResponsesCloneWithoutAdx];

        UIView *adViewClone;
        if (self.isInterstitial) {
            MNBaseInterstitialAd *interstitialAdView = [[MNBaseInterstitialAd alloc] init];
            [interstitialAdView setAdRequest:adRequestClone];
            [interstitialAdView setBidResponses:bidResponsesArrClone];
            [interstitialAdView selectBidderIdStr:bidderIdStrClone];

            adViewClone = (UIView *) interstitialAdView;

        } else {
            MNBaseAdView *bannerAdView = [[MNBaseAdView alloc] init];
            [bannerAdView setAdRequest:adRequestClone];
            // TODO Why are we setting frame here? Need to discuss!!
            MNBaseBidResponse *bidResponse = [bidResponsesArrClone firstObject];
            CGSize bidResponseAdSize       = [MNBaseUtil getAdSizeFromStringFormat:bidResponse.size];
            [bannerAdView setFrame:CGRectMake(0, 0, bidResponseAdSize.width, bidResponseAdSize.height)];
            [bannerAdView setRootViewController:self.rootViewController];
            [bannerAdView setBidResponses:bidResponsesArrClone];
            [bannerAdView selectBidderIdStr:bidderIdStrClone];

            adViewClone = bannerAdView;
        }
        if (adViewKey) {
            [[MNBaseAdViewStore getsharedInstance] addViewToStore:adViewClone withKey:adViewKey];
        } else {
            MNLogRemote(@"Failed to store the ad-view clone in cloneAndStoreAd since the adViewKey failed to generate");
        }
     */
}

- (NSString *)generateAdViewKeyFromRequestForAdx:(MNBaseAdRequest *)adRequest {
    if (!adRequest) {
        return nil;
    }

    NSString *adUnitId  = adRequest.adUnitId;
    NSString *adCycleId = adRequest.adCycleId;
    NSString *adViewKey = [MNBaseUtil generateKeyWithAdUnit:adUnitId andKeyGenStr:adCycleId];

    return adViewKey;
}

#pragma mark - Response handlers

- (void)postAdLoaderResponseWithContainer:(MNBaseBidResponsesContainer *)bidResponsesContainer {

    self.responsesContainer = bidResponsesContainer;

    if ([self.responsesContainer auctionDetails] != nil &&
        [[self.responsesContainer auctionDetails] didAuctionHappen] == YES) {
        // Auction happened!
        MNBaseAuctionDetails *auctionDetails = [self.responsesContainer auctionDetails];

        // The process of evaluating the response itself can result in generation of different
        // ad-cycle-id. This block ensures that it's reflected throughout.
        if (self.adRequest != nil) {
            self.adRequest.adCycleId = auctionDetails.updatedAdCycleId;
        }

        MNBaseAuctionLogsStatus *auctionLogsStatus = [MNBaseAuctionLogsStatus new];
        [[auctionLogsStatus aplog] setBool:YES];
        [self makeAuctionLoggerRequestsWithLogsStatus:auctionLogsStatus];
    } else {
        [self makeAuctionPredictionLogsReq];
    }

    [self cancelCurrentTask];
    [self populateServerExtrasDict];
}

- (void)makeAuctionLoggerRequestsWithLogsStatus:(MNBaseAuctionLogsStatus *)auctionLogsStatus {
    if (self.responsesContainer == nil || [self.responsesContainer auctionDetails] == nil) {
        return;
    }

    MNBaseAuctionLoggerManager *manager = [MNBaseAuctionLoggerManager getSharedInstance];
    [manager makeAuctionLoggerRequestFromResponsesContainer:self.responsesContainer
        withAuctionLogsStatus:auctionLogsStatus
        withSuccessCb:^{
          MNLogD(@"Performed auction-logging calls!");
        }
        andErrCb:^(NSError *_Nonnull error) {
          MNLogRemote(@"Not able to make to the call for auction logging requests - %@", error);
        }];
}

- (void)populateServerExtrasDict {
    // Merge all the server extras here!
    NSMutableDictionary *serverExtrasDict = [[NSMutableDictionary alloc] init];

    // Remove the bidderId
    NSArray *excludeKeys = @[ @"bidderId" ];

    for (MNBaseBidResponse *bidResponse in [self.responsesContainer bidResponsesArr]) {
        if (![bidResponse.bidType isEqualToString:BID_TYPE_ADX]) {
            NSDictionary *serverExtras = [bidResponse serverExtras];

            for (NSString *key in serverExtras) {
                if ([excludeKeys indexOfObject:key] == NSNotFound) {
                    [serverExtrasDict setObject:[serverExtras objectForKey:key] forKey:key];
                }
            }
        }
    }

    self.serverExtrasDict = serverExtrasDict;
}

- (void)handleAdControllerWithSuccess:(void (^)(MNBaseBidResponse *bidResponse))successCb
                             andError:(void (^)(NSError *error))errorCb {
    if ([self checkIfAdExPresentInResponse]) {
        MNLogD(@"ADX: Is adx flow!");
        [self initializeAdxFlowWithSuccess:successCb andError:errorCb];
    } else {
        MNLogD(@"ADX: Is not adx flow");
        [self selectAndInitializeAdWithSuccess:successCb andError:errorCb];
    }
    [self makeImpressionsLogsWithEventName:MNBasePulseEventImpressionLoad didReuse:NO];
}

- (void)selectAndInitializeAdWithSuccess:(void (^)(MNBaseBidResponse *bidResponse))successCb
                                andError:(void (^)(NSError *error))errorCb {
    MNBaseBidResponse *selectedBidResponse = [self.responsesContainer getSelectedBidResponseCandidate];
    if (selectedBidResponse == nil) {
        MNLogD(@"No selected bid response");
        NSString *errStr = @"There is no selected bid response";
        errorCb(
            [MNBaseError createErrorWithCode:MNBaseErrCodeAdLoadFailed errorDescription:errStr andFailureReason:nil]);

        return;
    }

    // Detect if expectation is matched by the response
    if (self.responseExpectation != nil) {
        NSError *expectationErr = self.responseExpectation(selectedBidResponse);
        if (expectationErr != nil) {
            MNLogD(@"EXPECTATION: Response does not match expectation - %@", expectationErr);
            errorCb(expectationErr);
            return;
        } else {
            MNLogD(@"EXPECTATION: Expectation satisfied");
        }
    } else {
        MNLogD(@"EXPECTATION: There are no expecations to match!");
    }

    [self.responsesContainer setSelectedBidResponse:selectedBidResponse];
    [self makePredictionProcessedLog];

    [self.responsesContainer recycleAllBidsExceptSelectedResponse];

    // Logging the analytics with adunit Id and bid information
    NSString *adCycleId             = [selectedBidResponse getAdCycleId];
    MNBaseAdAnalytics *analyticsObj = [MNBaseAdAnalytics getSharedInstance];

    [analyticsObj logAdUnitId:selectedBidResponse.creativeId forAdCycleId:adCycleId];
    [analyticsObj logBid:selectedBidResponse.ogBid forAdCycleId:adCycleId];
    [analyticsObj logBidderId:selectedBidResponse.bidderId forAdCycleId:adCycleId];

    MNLogD(@"ADX: Rendering ad for - %@", selectedBidResponse.bidderId);
    [self initializeAdControllerForBidResponse:selectedBidResponse
                                      outError:nil
                                 withSuccessCb:successCb
                                   withErrorCb:errorCb];
}

- (void)initializeAdControllerForBidResponse:(MNBaseBidResponse *_Nonnull)bidResponse
                                    outError:(NSError *)error
                               withSuccessCb:(void (^)(MNBaseBidResponse *bidResponse))successCb
                                 withErrorCb:(void (^)(NSError *error))errorCb {
    BOOL isResponseClassFound    = NO;
    NSError *errorObj            = error;
    NSString *errorMsg           = nil;
    NSString *classStr           = nil;
    NSString *instanceMethodName = nil;

    if (bidResponse) {
        MNBaseBidResponseTypeInfo *respTypeInfo = [MNBaseBidResponseTypeInfo getSharedInstance];
        NSString *respType                      = bidResponse.adType;
        if ([respTypeInfo isResponseType:respType]) {
            isResponseClassFound = YES;
            classStr             = [respTypeInfo getAdControllerClassStrForResponseType:respType];
            instanceMethodName   = [respTypeInfo getAdControllerSelStrForResponseType:respType];

        } else {
            errorMsg = [NSString stringWithFormat:@"AdType is not supported! - %@", respType];
        }
    } else {
        errorMsg = [NSString stringWithFormat:@"BidResponse is nil"];
    }

    if (!isResponseClassFound || !classStr || !instanceMethodName) {
        if (!errorObj) {
            if (!errorMsg) {
                if (!isResponseClassFound) {
                    errorMsg = @"Error while resolving ad type: No such adtype found!";
                } else if (!classStr || !instanceMethodName) {
                    errorMsg = @"Internal error when resolving ad type";
                    MNLogRemote(@"NOTE: Response class and instance is found but has not been assigned to classStr or "
                                @"instanceMethod. This is a programming error!");
                }
            }
            errorObj = [MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdType withFailureReason:errorMsg];
        }

        if (errorCb) {
            errorCb(errorObj);
        }
        return;
    }

    [self createAdControllerForClassStr:classStr
                 withInstanceMethodName:instanceMethodName
                            forResponse:bidResponse
                          withSuccessCb:successCb
                            withErrorCb:errorCb];
}

- (void)createAdControllerForClassStr:(NSString *)classStr
               withInstanceMethodName:(NSString *)instanceMethodStr
                          forResponse:(MNBaseBidResponse *)bidResponse
                        withSuccessCb:(void (^)(MNBaseBidResponse *bidResponse))successCb
                          withErrorCb:(void (^)(NSError *error))errorCb {
    // Fetch the ad-code before processing the response
    __weak MNBaseAdBaseCommon *weakSelf = self;
    [self fetchAdCodeFromResponseAsync:bidResponse
                      withCompletionCb:^(NSError *_Nullable adCodeErr) {
                        MNBaseAdBaseCommon *strongSelf = weakSelf;
                        if (strongSelf == nil) {
                            NSString *errMsg = @"Could not create the ad-controller";
                            if (errorCb) {
                                errorCb([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdController
                                                       withFailureReason:errMsg]);
                            }
                            MNLogRemote(@"%@", errMsg);
                            return;
                        }

                        if (adCodeErr != nil) {
                            if (errorCb) {
                                errorCb(adCodeErr);
                            }
                            MNLogRemote(@"Error encountered when fetching the ad-code - %@", adCodeErr);
                            return;
                        }

                        // Create the ad-controller
                        BOOL adControllerCreated = [self createAdControllerForClassStr:classStr
                                                                withInstanceMethodName:instanceMethodStr
                                                                           forResponse:bidResponse];
                        if (NO == adControllerCreated) {
                            if (errorCb != nil) {
                                errorCb([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdController
                                                       withFailureReason:@"Unable to create ad-controller"]);
                            }
                            return;
                        }
                        if (successCb != nil) {
                            successCb(bidResponse);
                        }
                      }];
}

- (BOOL)createAdControllerForClassStr:(NSString *)classStr
               withInstanceMethodName:(NSString *)instanceMethodStr
                          forResponse:(MNBaseBidResponse *)bidResponse {
    MNLogD(@"%@ is used by user", classStr);

    Class controllerClass              = objc_getClass([classStr UTF8String]);
    SEL controllerInstanceSel          = NSSelectorFromString(instanceMethodStr);
    NSMethodSignature *methodSignature = [controllerClass methodSignatureForSelector:controllerInstanceSel];

    if (!controllerClass || !methodSignature) {
        MNLogRemote(@"%@ Ad-controller is not available", classStr);
        return NO;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:controllerInstanceSel];
    [invocation setTarget:controllerClass];
    [invocation invoke];

    [invocation getReturnValue:&adControllerObj];

    if (self.surrogateModule != nil) {
        [adControllerObj setDelegate:self.surrogateModule];
        [adControllerObj setAdSizeControllerDelegate:self.surrogateModule];
        if ([bidResponse.adType isEqualToString:VIDEO_STRING] ||
            [bidResponse.adType isEqualToString:REWARDED_VIDEO_STRING]) {
            [adControllerObj setVideoControllerDelegate:self.surrogateModule];
        }
    } else {
        MNLogD(@"Couldn't set delegates for ad-controllers since surrogateModule is nil!");
    }

    adControllerObj.rootViewController = self.rootViewController;
    adControllerObj.isInterstitial     = self.isInterstitial;
    adControllerObj.responsesContainer = self.responsesContainer;
    adControllerObj.adResponse         = bidResponse;
    [adControllerObj processResponse];
    return YES;
}

// Fetch the ad-code if it does not exist from the ad-url, asynchronously
- (void)fetchAdCodeFromResponseAsync:(MNBaseBidResponse *)adResponse
                    withCompletionCb:(void (^_Nonnull)(NSError *_Nullable))completionCb {
    if (adResponse == nil) {
        completionCb([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidResponse
                                    withFailureReason:@"Ad response cannot be nil"]);
        return;
    }

    // Check if ad-code is already available
    if (adResponse.adCode != nil) {
        adResponse.adCode = [adResponse.adCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (NO == [adResponse.adCode isEqualToString:@""]) {
            completionCb(nil);
            return;
        }
    }

    // Make the ad-url request
    adResponse.adUrl = [adResponse.adUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (adResponse.adUrl == nil || [adResponse.adUrl isEqualToString:@""]) {
        completionCb([MNBaseError createErrorWithCode:MNBaseErrCodeInvalidAdUrl withFailureReason:@"Invalid ad-url"]);
    }

    [MNBaseHttpClient doGetWithStrResponseOn:adResponse.adUrl
        headers:nil
        shouldRetry:NO
        success:^(NSString *_Nonnull responseStr) {
          adResponse.adCode = responseStr;
          completionCb(nil);
        }
        error:^(NSError *_Nonnull error) {
          completionCb([MNBaseError createErrorWithCode:MNBaseErrCodeAdUrlRequestFailed
                                      withFailureReason:@"Fetching data from ad-url failed"]);
        }];
}

#pragma mark - Post ad load logging pixels

- (void)makeAuctionPredictionLogsReq {
    NSArray<NSString *> *apLogs = [self.responsesContainer apLogs];
    if (apLogs == nil) {
        MNLogD(@"DEBUG_LOGS: Skipping ap-logs since no logs were found!");
        return;
    }

    MNBaseMacroManager *macroManager    = [MNBaseMacroManager getSharedInstance];
    NSArray<NSString *> *modifiedApLogs = [macroManager processMacrosForApLogsForBidders:apLogs withResponse:nil];

    MNLogD(@"DEBUG_LOGS: Calling ap-logs. Found %lu",
           (unsigned long) ((modifiedApLogs != nil) ? [modifiedApLogs count] : 0));
    for (NSString *apLog in modifiedApLogs) {
        MNLogD(@"DEBUG_LOGS: Calling ap-log for : url - %@", apLog);
        [MNBaseHttpClient doGetWithStrResponseOn:apLog
            headers:nil
            shouldRetry:YES
            success:^(NSString *_Nonnull response) {
              MNLogD(@"DEBUG_LOGS: Success response on ap-logs request");
            }
            error:^(NSError *_Nonnull error) {
              MNLogRemote(@"DEBUG_LOGS: Error Making ap-logs request - %@", error);
            }];
    }
}

- (void)makeAuctionWinReqWithCb:(void (^)(id response))successCb withErrorCb:(void (^)(NSError *_Nonnull))errorCb {
    MNBaseBidResponse *bidResponse = [self.responsesContainer selectedBidResponse];
    NSString *auctionWinUrl        = bidResponse.auctionWinUrl;

    if (auctionWinUrl != nil) {
        MNLogD(@"DEBUG_LOGS: Calling auction win url for ad-cycle-id %@, bidder-id %@, bidder-name %@",
               [bidResponse getAdCycleId], [bidResponse bidderId], [bidResponse bidderName]);
        MNLogD(@"DEBUG_LOGS: Calling auction win url request %@", auctionWinUrl);
        [MNBaseHttpClient doGetWithStrResponseOn:auctionWinUrl
            headers:nil
            shouldRetry:YES
            success:^(NSString *_Nonnull response) {
              MNLogD(@"Success response on auctionWinUrl - %@", response);
              MNLogD(@"DEBUG_LOGS: Success response on auctionWinUrl");

              if (successCb != nil) {
                  successCb(response);
              }
            }
            error:^(NSError *_Nonnull error) {
              MNLogRemote(@"Error Making auctionWinUrl request - %@", error);
              MNLogD(@"DEBUG_LOGS: Err response on auctionWinUrl - %@", error);
              if (errorCb != nil) {
                  errorCb(error);
              }
            }];
    }
}

#pragma mark - Public Helper methods

- (void)setBidResponses:(NSArray<MNBaseBidResponse *> *)bidResponsesArr {
    if (self.onGoingTask) {
        MNLogD(@"Cannot set bidResponse to an ongoing task!");
        return;
    }

    // Explicitly not performing nil-checks on bidResponsesArr
    // Calling loadAd will automatically fail and send the callback
    self.responsesContainer = [MNBaseBidResponsesContainer getInstanceWithBidResponses:bidResponsesArr];

    // Making this into prefetch since calling loadAd will directly
    // load the bidResponses without making the request.
    self.isPrefetchMode = YES;
    self.adViewStatus   = MNBaseAdViewStatusAdRespReceived;
}

- (void)selectBid:(NSString *)bidderIdStr {
    [self.responsesContainer setSelectedBidderIdStr:bidderIdStr];
}

- (void)adxCallbacks {
    if (self.isAdxEnabled) {
        NSString *adViewKey = [self generateAdViewKeyFromRequestForAdx:self.adRequest];

        NSString *adunitId                 = self.adxBidResponse.creativeId;
        NSString *pubId                    = self.adxBidResponse.publisherId;
        NSNumber *bid                      = self.adxBidResponse.ogBid;
        MNBaseAdDetailsStore *detailsStore = [MNBaseAdDetailsStore getSharedInstance];

        // Check if the adview store contains the cached entry
        // If it does, then adx has won (our ad was not shown)
        if ([[MNBaseAdViewStore getsharedInstance] getViewForKey:adViewKey]) {
            [self performLoggingForAdxOfLogKey:MNBaseAdxLogSuccess1];
            [self performLoggingForAdxOfLogKey:MNBaseAdxLogSuccess2];

            // Adx won
            [detailsStore updateAdxWinStatus:YES forAdunit:adunitId andPubId:pubId];
            [detailsStore updateAdxWinBid:bid forAdunit:adunitId andPubId:pubId];
        } else {
            // Adx lost
            [detailsStore updateAdxWinStatus:NO forAdunit:adunitId andPubId:pubId];
        }
    }
}

- (NSDictionary *)fetchServerParams {
    if (self.serverExtrasDict == nil) {
        return nil;
    }
    return self.serverExtrasDict;
}

- (NSString *)fetchAdCycleId {
    if (self.adRequest != nil) {
        return [self.adRequest adCycleId];
    }

    return nil;
}

- (void)showAdFromViewController:(UIViewController *)viewController andErrorCb:(void (^)(NSError *))errorCb {
    if (self.isInterstitial && adControllerObj != nil && !self.interstitialAdIsShownOnce) {
        adControllerObj.rootViewController = viewController;
        [adControllerObj showAdFromRootViewController];
        self.interstitialAdIsShownOnce = YES;
    } else {
        NSString *errorMessage = @"Controller is not initialized!";
        if (!self.isInterstitial) {
            errorMessage = @"Trying to show an ad on a non-interstitial adType";
        } else if (self.interstitialAdIsShownOnce) {
            errorMessage = @"Interstitial Ad cannot be shown more than once";
        }
        errorCb([MNBaseError createErrorWithCode:MNBaseErrCodeAdLoadFailed
                                errorDescription:errorMessage
                                andFailureReason:nil]);
    }
}

- (void)cancelCurrentTask {
    if (!self.onGoingTask) {
        MNLogD(@"No ongoing loadAD found to stop");
        return;
    }

    [self.onGoingTask cancel];
    [self setOnGoingTask:nil];
}

// This is async. Will probably not be available immediately.
- (void)setCustomLocation:(CLLocation *)customLocation {
    double lat = customLocation.coordinate.latitude;
    double lon = customLocation.coordinate.longitude;

    NSString *locationKey = [NSString stringWithFormat:@"location:%.3f-%.3f", lat, lon];

    NSData *locationDataFromStore = [MNBaseUtil getFromStoreForKey:locationKey];
    if (locationDataFromStore != nil) {
        NSString *jsonStr              = [NSKeyedUnarchiver unarchiveObjectWithData:locationDataFromStore];
        MNBaseGeoLocation *storeOutput = [[MNBaseGeoLocation alloc] init];
        [MNJMManager fromJSONStr:jsonStr toObj:storeOutput];

        self.customGeoLocation = storeOutput;
        return;
    }

    __block MNBaseGeoLocation *locationObj = [[MNBaseGeoLocation alloc] init];
    locationObj.latitude                   = lat;
    locationObj.longitude                  = lon;
    [locationObj setAccuracy:(int) (fabs(customLocation.horizontalAccuracy))];

    self.customGeoLocation = locationObj;

    // Mapping available info to geoLocation
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];

    // Not making this sync.
    // Storing the results so that subsequent requests can get the response
    [geoCoder reverseGeocodeLocation:customLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (error != nil) {
                         MNLogD(@"Error in reverse geocode location");
                         MNLogD(@"Error - %@", error);
                         return;
                     }

                     locationObj = [MNBaseUtil mapPlacemarkToGeoLocation:placemarks withCurrentLocation:customLocation];

                     // This is not required.
                     // But, Explicit is better than implicit.
                     self.customGeoLocation = locationObj;

                     [MNBaseUtil addToStoreForKey:locationKey AndValue:[MNJMManager toJSONStr:locationObj]];
                   }];
}

/// This is used by intersitital ads to remove the adOnceShown restriction.
/// This is required by rewarded video ads (rewarded video is basically interstitial)
- (void)resetAdBaseStatus {
    self.interstitialAdIsShownOnce = NO;
    self.isAdShown                 = NO;
    self.isAdLoaded                = NO;
    self.isLoggingCallMade         = NO;
}

// Reset ad view status before moving to reusue repository.
// This is to make sure logging call gets fired after adview reuse
- (void)prepareAdViewStatusForReuse {
    self.isAdShown         = NO;
    self.isLoggingCallMade = NO;
}

- (void)updateRootVC:(UIViewController *_Nonnull)viewController {
    self.rootViewController = viewController;
    self.vcLink             = [MNBaseUtil getLinkForVC:self.rootViewController];

    if (adControllerObj) {
        adControllerObj.rootViewController = viewController;
    }
}

- (void)makeReuseLogRequestsWithAuctionLogsStatus:(MNBaseAuctionLogsStatus *)auctionLogsStatus
                           shouldRefreshAdCycleId:(BOOL)shouldRefreshAdCycleId {
    if (adControllerObj) {
        [adControllerObj makeInAdLoggingReq];
    }

    if (auctionLogsStatus == nil) {
        MNLogRemote(@"Skipping making the auction logs since auction logs status is empty!");
        return;
    }

    // Need to regenerate the ad-cycle-id for CSA
    if (shouldRefreshAdCycleId) {
        NSString *adCycleId = [MNBaseUtil generateAdCycleId];

        if (self.responsesContainer != nil) {
            if ([self.responsesContainer auctionDetails] != nil) {
                [[self.responsesContainer auctionDetails] setUpdatedAdCycleId:adCycleId];
            }
            MNBaseBidResponse *responseObj = [[self.responsesContainer bidResponsesArr] firstObject];
            if (responseObj != nil) {
                [responseObj setAdCycleId:adCycleId];
            }
        }
    }

    MNBaseAuctionLoggerManager *manager = [MNBaseAuctionLoggerManager getSharedInstance];
    [manager makeAuctionLoggerRequestFromResponsesContainer:self.responsesContainer
        withAuctionLogsStatus:auctionLogsStatus
        withSuccessCb:^{
          MNLogD(@"Performed auction-logging calls!");
        }
        andErrCb:^(NSError *_Nonnull error) {
          MNLogRemote(@"Not able to make to the call for auction logging requests - %@", error);
        }];

    // Update the ad-cycle from the response (irrespective of it being changed by auction/force-update)
    MNBaseBidResponse *responseObj = [[self.responsesContainer bidResponsesArr] firstObject];
    if (responseObj != nil) {
        NSString *adCycleId = [responseObj getAdCycleId];
        if (adCycleId != nil) {
            self.adRequest.adCycleId = adCycleId;
        }
    }
}

- (BOOL)canCacheView {
    if ([[MNBaseSdkConfig getInstance] getIsAdViewReuseEnabled] == NO) {
        return NO;
    }

    if (self.adxBidResponse == nil) {
        NSString *bidderIdStr = [self.responsesContainer selectedBidderIdStr];
        return (bidderIdStr != nil && [bidderIdStr isEqualToString:[YBNC_BIDDER_ID stringValue]]);
    }
    return NO;
}

- (BOOL)recycleAllBidsFromAdResponse {
    return [self.responsesContainer recycleAllBids];
}

- (void)stripAllExceptSelectedBidResponse {
    [self.responsesContainer stripAllExceptSelectedBidResponse];
}

- (void)makeViewVisibleLogRequests {
    if (NO == self.isInterstitial && self.isReuseReady == YES) {
        MNLogD(@"LOGS: Making reuse logs - adViewVisibleReuseLogRequests");
        [self adViewVisibleReuseLogRequests];
    } else {
        MNLogD(@"LOGS: Making normal logs - adViewVisibleLogRequests");
        [self adViewVisibleLogRequests];
    }
}

- (void)adViewVisibleLogRequests {
    if ([self.responsesContainer auctionDetails] != nil &&
        [[self.responsesContainer auctionDetails] didAuctionHappen] == YES) {
        MNBaseAuctionLogsStatus *auctionLogsStatus = [MNBaseAuctionLogsStatus new];
        [[auctionLogsStatus awlog] setBool:YES];

        [self makeAuctionLoggerRequestsWithLogsStatus:auctionLogsStatus];
    }

    [self makeAuctionWinReqWithCb:nil withErrorCb:nil];

    if (adControllerObj != nil) {
        [adControllerObj makeLoggingBeaconsReq];
        [adControllerObj makeInAdLoggingReq];
    }

    [self makeImpressionsLogsWithEventName:MNBasePulseEventImpressionSeen didReuse:NO];
}

- (void)adViewVisibleReuseLogRequests {
    MNBaseAuctionLogsStatus *auctionLogsStatus = [MNBaseAuctionLogsStatus new];
    [[auctionLogsStatus awlog] setBool:YES];
    [[auctionLogsStatus aplog] setBool:NO];
    [[auctionLogsStatus prflog] setBool:NO];
    [[auctionLogsStatus prlog] setBool:NO];
    [self makeReuseLogRequestsWithAuctionLogsStatus:auctionLogsStatus shouldRefreshAdCycleId:NO];

    [self makeImpressionsLogsWithEventName:MNBasePulseEventImpressionSeen didReuse:YES];
}

- (void)makePredictionProcessedLog {
    MNBaseBidResponse *bidResponse = [[self responsesContainer] selectedBidResponse];
    if (bidResponse == nil || bidResponse.predictionId == nil || [bidResponse.predictionId isEqualToString:@""]) {
        return;
    }

    NSString *contentUrl = [bidResponse viewContextLink];
    if (contentUrl == nil) {
        contentUrl = @"";
    }

    NSString *vcTitle = [bidResponse viewControllerTitle];
    if (vcTitle == nil) {
        vcTitle = @"";
    }

    NSString *adCycleId = [bidResponse getAdCycleId];
    if (adCycleId == nil) {
        adCycleId = @"";
    }

    NSString *predictionId = bidResponse.predictionId;
    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventPredictedBidProcessed
                                   andCustomData:@{
                                       @"prediction_id" : predictionId,
                                       @"content_url" : contentUrl,
                                       @"activity_name" : vcTitle,
                                       @"ad_cycle_id" : adCycleId,
                                   }];
}

- (void)makeImpressionsLogsWithEventName:(NSString *)eventName didReuse:(BOOL)didReuse {
    NSNumber *didReuseObj = [NSNumber numberWithBool:didReuse];

    MNBaseBidResponse *bidResponse = [self.responsesContainer selectedBidResponse];
    if (bidResponse == nil) {
        MNLogRemote(@"Cannot make impression request without selected response");
        return;
    }

    // Pulse request for the ad-view seen
    NSString *contextLink = bidResponse.viewContextLink;
    if (contextLink == nil) {
        contextLink = @"";
    }

    NSString *adCycleId = [bidResponse getAdCycleId];

    NSNumber *didAuctionHappen           = [NSNumber numberWithBool:NO];
    MNBaseAuctionDetails *auctionDetails = [self.responsesContainer auctionDetails];
    if (auctionDetails != nil) {
        didAuctionHappen = [NSNumber numberWithBool:[auctionDetails didAuctionHappen]];
    }

    NSArray *bidResponsesArr = [self.responsesContainer bidResponsesArr];
    if (bidResponsesArr == nil) {
        bidResponsesArr = [NSArray array];
    }

    NSDictionary *customData = @{
        @"winning_bid" : bidResponse,
        @"participants" : bidResponsesArr,
        @"client_side_auction" : didAuctionHappen,
        @"reuse" : didReuseObj,
        @"content_url" : contextLink,
        @"ad_cycle_id" : adCycleId,
    };

    MNLogD(@"IMPR: Making %@ with data - %@", eventName, [MNJMManager toJSONStr:customData]);

    [MNBasePulseTracker logRemoteCustomEventType:eventName andCustomData:customData];
}

- (NSString *)fetchVCLink {
    if (self.contextLink) {
        MNLogD(@"MNBase: Context link : %@", self.contextLink);
        return self.contextLink;
    } else if (self.vcLink) {
        MNLogD(@"MNBase: Context link : %@", self.vcLink);
        return self.vcLink;
    } else if (self.rootViewController) {
        self.vcLink = [MNBaseUtil getLinkForVC:self.rootViewController];
        MNLogD(@"LINK: %@", self.vcLink);
        return self.vcLink;
    }
    return [MNBaseUtil getDefaultBundleUrl];
}

- (BOOL)doesResponseContainOnlyFpd {
    if (self.responsesContainer != nil && [self.responsesContainer bidResponsesArr] != nil &&
        [[self.responsesContainer bidResponsesArr] count] == 1) {
        MNBaseBidResponse *bidResponse = [[self.responsesContainer bidResponsesArr] lastObject];
        return (bidResponse != nil && [bidResponse bidType] != nil &&
                [[bidResponse bidType] caseInsensitiveCompare:BID_TYPE_FIRST_PARTY] == NSOrderedSame);
    }
    return NO;
}

- (NSArray<NSString *> *_Nullable)fetchResponseBidderIds {
    if (self.responsesContainer == nil || [self.responsesContainer bidResponsesArr] == nil ||
        [[self.responsesContainer bidResponsesArr] count] == 0) {
        return nil;
    }

    NSMutableArray<NSString *> *bidderIdsList = [[NSMutableArray alloc] init];
    for (MNBaseBidResponse *response in [self.responsesContainer bidResponsesArr]) {
        NSNumber *bidderId = [response bidderId];
        if (bidderId != nil) {
            [bidderIdsList addObject:[bidderId stringValue]];
        }
    }

    if (bidderIdsList != nil && [bidderIdsList count] > 0) {
        return [NSArray<NSString *> arrayWithArray:bidderIdsList];
    }
    return nil;
}

- (MNBaseAdSize *_Nullable)fetchAdSizeForSelectedBid {
    if (self.responsesContainer != nil && [self.responsesContainer selectedBidderIdStr] != nil) {
        MNBaseBidResponse *bidResponse = [self.responsesContainer getSelectedBidResponseCandidate];
        if (bidResponse != nil) {
            NSString *adSizeStr = [bidResponse size];
            if (adSizeStr != nil) {
                CGSize adCGSize = [MNBaseUtil getAdSizeFromStringFormat:adSizeStr];
                if (NO == CGSizeEqualToSize(adCGSize, CGSizeZero)) {
                    return MNBaseAdSizeFromCGSize(adCGSize);
                }
            }
        }
    }
    return nil;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MNLogD(@"DEALLOC: Dealloc MNBaseAdBaseCommon");
}
@end
