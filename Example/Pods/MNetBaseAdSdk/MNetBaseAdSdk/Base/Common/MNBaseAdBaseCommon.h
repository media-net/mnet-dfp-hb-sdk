//
//  MNBaseAdBaseCommon.h
//  Pods
//
//  Created by nithin.g on 28/02/17.
//
//

#import <Foundation/Foundation.h>

#import "MNBaseAdRequest+Internal.h"
#import "MNBaseAuctionLogsStatus.h"
#import "MNBaseBidResponse.h"

#pragma mark - Enums

typedef NS_ENUM(NSUInteger, MNBaseAdViewStatus) {
    MNBaseAdViewStatusInvalid = 0,
    MNBaseAdViewStatusFailed,         // Ad-view has failed
    MNBaseAdViewStatusInit,           // When the ad-view is first initialized
    MNBaseAdViewStatusAdReqSent,      // The ad-request is sent
    MNBaseAdViewStatusAdRespReceived, // Got the ad-response. Does not indicate if it's valid
    MNBaseAdViewStatusLoaded,         // Ad has completed loading it-self onto the ad-view
    MNBaseAdViewStatusShown,          // Ad-view is attached to the window
};

typedef NS_ENUM(NSUInteger, MNBaseVideoAdStatus) {
    MNBaseVideoStatusInvalid = 0,
    MNBaseVideoStatusFailed,      // Video ad has failed
    MNBaseVideoStatusInit,        // When the video-ad is first initialized
    MNBaseVideoStatusViewCreated, // When the video-ad view is first created
    MNBaseVideoStatusLoaded,      // When the video-ad has completed loading it-self onto the ad-view
    MNBaseVideoStatusStarted,     // Video-ad has started playing the ad
    MNBaseVideoStatusCompleted,   // Video ad has completed playing the ad
};

@interface MNBaseAdBaseCommon : NSObject
NS_ASSUME_NONNULL_BEGIN
@property bool autoRefresh;
@property (atomic, nullable) NSNumber *refreshDuration;
@property (atomic, nullable) MNBaseAdRequest *adRequest;
@property (atomic, nullable) NSString *auctionWinUrl;
@property (atomic) NSString *adUnitId;
@property (atomic) CGSize adSize;
@property (atomic, nullable) MNBaseGeoLocation *customGeoLocation;
@property (atomic) BOOL videoPlayerCompleted;
@property (atomic) BOOL isPrefetchMode;
@property (atomic, nullable) NSString *keywords;
@property (atomic) BOOL interstitialAdIsShownOnce;
@property (weak, atomic) UIViewController *_Nullable rootViewController;
@property (atomic, nullable) NSString *selectedBidderIdStr;
@property (atomic) NSString *contextLink;
@property (atomic, nullable) MNBaseUser *requestSpecficUser;
@property (atomic, nullable) NSArray<MNBaseAdSize *> *adSizes;
@property (atomic) BOOL isReuseReady;
@property (atomic) NSError *_Nullable (^responseExpectation)(MNBaseBidResponse *);
@property (atomic, copy) NSDictionary<NSString *, NSString *> *customExtras;

// flags to monitor ad view status
@property (atomic) MNBaseAdViewStatus adViewStatus;
@property (atomic) MNBaseVideoAdStatus videoAdStatus;

#pragma mark - Methods
- (MNBaseAdBaseCommon *)initWithSurrogate:(id _Nullable)surrogateModule andInterstitial:(BOOL)isInterstitial;
- (void)resetAdBaseStatus;

- (void)loadAdWithSuccessResp:(void (^_Nullable)(MNBaseBidResponse *bidResponse))successCb
                  withErrorCb:(void (^_Nullable)(NSError *error))errorCb;

- (void)prefetchForRequest:(MNBaseAdRequest *_Nullable)request
           timeoutInMillis:(NSNumber *_Nullable)timeoutInMillis
                   success:(void (^_Nullable)(NSDictionary *, NSString *, BOOL))successHandler
                   failure:(void (^_Nullable)(NSError *, NSString *))failureHandler;

- (void)makeAuctionWinReqWithCb:(void (^_Nullable)(id _Nullable response))successCb
                    withErrorCb:(void (^_Nullable)(NSError *))errorCb;

- (void)refreshSelfWithExtraDuration:(NSNumber *_Nullable)duration;
- (void)showAdFromViewController:(UIViewController *)viewController andErrorCb:(void (^_Nullable)(NSError *))errorCb;
- (void)setCustomLocation:(CLLocation *_Nullable)customLocation;
- (void)cancelCurrentTask;
- (void)checkAndUpdateAutoRefreshDetails;

- (void)setBidResponses:(NSArray<MNBaseBidResponse *> *_Nullable)bidResponsesArr;

- (void)selectBid:(NSString *)bidderIdStr;

- (void)adxCallbacks;
- (NSDictionary *_Nullable)fetchServerParams;
- (NSString *_Nullable)fetchAdCycleId;
- (void)updateRootVC:(UIViewController *_Nonnull)viewController;

- (void)makeReuseLogRequestsWithAuctionLogsStatus:(MNBaseAuctionLogsStatus *)auctionLogsStatus
                           shouldRefreshAdCycleId:(BOOL)shouldRefreshAdCycleId;
- (void)makeImpressionsLogsWithEventName:(NSString *_Nonnull)eventName didReuse:(BOOL)didReuse;

- (BOOL)canCacheView;
- (BOOL)recycleAllBidsFromAdResponse;
- (void)stripAllExceptSelectedBidResponse;
- (void)makeViewVisibleLogRequests;
- (NSString *)fetchVCLink;
- (void)prepareAdViewStatusForReuse;
- (NSArray<MNBaseAdSize *> *)getUniqueAdSizes:(NSArray<MNBaseAdSize *> *)adSizes;
- (BOOL)doesResponseContainOnlyFpd;
- (NSArray<NSString *> *_Nullable)fetchResponseBidderIds;
- (MNBaseAdSize *_Nullable)fetchAdSizeForSelectedBid;
- (void)adViewLayoutChanged;

NS_ASSUME_NONNULL_END
@end
