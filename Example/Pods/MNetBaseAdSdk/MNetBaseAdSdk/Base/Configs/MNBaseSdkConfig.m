//
//  MNBaseSdkConfig.m
//  Pods
//
//  Created by kunal.ch on 23/02/17.
//
//

#import "MNBase.h"
#import "MNBaseConstants.h"
#import "MNBaseDefaultBidsManager+Internal.h"
#import "MNBaseHbConfigData.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseNotificationManager.h"
#import "MNBaseSdkConfig+Internal.h"
#import "MNBaseSdkConfigData.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"

// Config for local storage
#define MN_CONFIG_STORE_KEY @"mnet_config"

/*
 NOTE:
 Please do not use MNLogE() in this class
 Why?
 MNLogE calls Pulse -> Pulse uses SdkConfig
 -> if SdkConfig is not instantiated, then init
 -> Your method will be called
 -> Your method calls MNBaseLogE
 -> Again cycle begins
*/

@interface MNBaseSdkConfig ()
@property MNBaseConfig *config;
@property MNBaseHbConfigData *hbConfigData;
@property MNBaseSdkConfigData *sdkConfigData;

@end

@implementation MNBaseSdkConfig
static MNBaseSdkConfig *instance;

+ (void)initSdkConfig {
    [self getInstance];
}

+ (MNBaseSdkConfig *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      MNLogD(@"initializing sdk config");
      instance = [[MNBaseSdkConfig alloc] init];
    });

    return instance;
}

+ (MNBaseConfig *)getConfigFromStore {
    NSData *storedConfigData                            = [MNBaseUtil getFromStoreForKey:MN_CONFIG_STORE_KEY];
    NSDictionary<NSString *, NSObject *> *storedConfigs = [NSKeyedUnarchiver unarchiveObjectWithData:storedConfigData];
    MNBaseConfig *storedConfig                          = [[MNBaseConfig alloc] init];
    [MNJMManager fromDict:storedConfigs toObject:storedConfig];
    return storedConfig;
}

- (MNBaseSdkConfig *)init {
    self = [super init];
    if (self) {
        // Set default to be enabled update
        _isUpdateEnabled = YES;
        _config          = [[MNBaseConfig alloc] init];
        [self getLocalConfigs];
        [self fetchFromServer];
    }
    return self;
}

- (MNBaseConfig *)getConfig {
    if (self.config) {
        return self.config;
    }
    return nil;
}

- (MNBaseHbConfigData *)getHbConfigData {
    return self.hbConfigData;
}

- (MNBaseSdkConfigData *)getSdkConfigData {
    return self.sdkConfigData;
}

- (NSString *)buildConfigUrl {
    NSString *customerId = [[MNBase getInstance] customerId];
    return [@[ [[MNBaseURL getSharedInstance] getConfigUrl], CONFIG_ID, customerId ] componentsJoinedByString:@"/"];
}

- (void)updateConfig {
    [self fetchFromServer];
}

- (void)fetchFromServer {
    NSString *url           = [self buildConfigUrl];
    MNBaseConfig *oldConfig = [MNBaseSdkConfig getConfigFromStore];

    [MNBaseHttpClient doGetOn:url
        headers:nil
        params:nil
        success:^(NSDictionary *response) {
          MNLogD(@"got config response %@", response);
          if (response == nil) {
              MNLogD(@"config response is nil. Not updating anything");
              return;
          }
          if (response != nil) {
              MNLogD(@"config response body %@", [MNJMManager toJSONStr:response]);
          }
          // Update the instance with new config fetched
          MNBaseConfig *mnetConfig = [[MNBaseConfig alloc] init];
          [MNJMManager fromDict:response toObject:mnetConfig];
          [self updateWithNewConfig:mnetConfig oldConfig:oldConfig];

          // Update the local store with new config fetched from server
          [MNBaseUtil addToStoreForKey:MN_CONFIG_STORE_KEY AndValue:[[NSDictionary alloc] initWithDictionary:response]];
        }
        error:^(NSError *error) {
          MNLogD(@"error in fetching sdk config %@", error);
        }];
}

- (void)updateConfigExternally:(MNBaseConfig *)externalConfig {
    [self updateWithNewConfig:externalConfig oldConfig:nil];
}

- (void)updateWithNewConfig:(MNBaseConfig *)newConfig oldConfig:(MNBaseConfig *)oldConfig {
    [self updateConfigWithConfigData:newConfig];

    // Raise the update notification
    if (self.isUpdateEnabled) {
        [MNBaseNotificationManager postNotificationWithName:MNBaseNotificationSdkConfigUpdated];
    } else {
        MNLogD(@"Notification disabled for sdk-config update");
    }
}

- (void)updateConfigWithConfigData:(MNBaseConfig *)newConfig {
    self.config = newConfig;

    // Update the hbconfig
    self.hbConfigData = self.config.hbConfig;
    // Update the sdkConfig
    self.sdkConfigData = self.config.sdkConfig;

    // NOTE: Fetch loaders from hb_config if present else fetch from sdk_config
    if (self.hbConfigData.loaders != nil) {
        MNLogD(@"Fetching loaders from hb_config");
        [self fetchAdPlaceholderLoaders:self.hbConfigData.loaders];
        return;
    }

    if (self.sdkConfigData.loaders != nil) {
        MNLogD(@"Fetching loaders from sdk_config");
        [self fetchAdPlaceholderLoaders:self.sdkConfigData.loaders];
    }
}

- (void)getLocalConfigs {
    MNBaseConfig *storedConfigs = [MNBaseSdkConfig getConfigFromStore];
    if (storedConfigs == nil) {
        return;
    }
    // Each value object from other dictionary is copied, if both dictionaries contains
    // same key then value for the key is replaced with new value
    [self updateConfigWithConfigData:storedConfigs];
}

#pragma mark Helper methods
// From here on, it's a bunch of helper functions, to fetch the intricacies of the Config dict.
// This is just so that future changes in the config does not need multiple levels of changes
- (MNBaseAdUnitConfigData *)getAdUnitConfigDataFor:(NSString *)pubAdUnitId {
    MNBaseHbConfigData *hbConfig = self.hbConfigData;

    if (hbConfig != nil) {
        NSArray<MNBaseAdUnitConfigData *> *adUnitsDataList = hbConfig.adUnitConfigDataList;
        for (MNBaseAdUnitConfigData *adUnitElement in adUnitsDataList) {
            NSString *adUnitId = adUnitElement.adUnitId;

            if ([adUnitId isEqualToString:pubAdUnitId]) {
                return adUnitElement;
            }
        }
    }
    return nil;
}

- (MNBaseAdUnitConfigData *)getAdUnitConfigDataForCrid:(NSString *)crid {
    MNBaseHbConfigData *hbConfig = self.hbConfigData;

    if (hbConfig != nil) {
        NSArray<MNBaseAdUnitConfigData *> *adUnitsDataList = hbConfig.adUnitConfigDataList;
        for (MNBaseAdUnitConfigData *adUnitElement in adUnitsDataList) {
            NSString *adUnitId = adUnitElement.creativeId;

            if ([adUnitId isEqualToString:crid]) {
                return adUnitElement;
            }
        }
    }
    return nil;
}

- (NSNumber *)getGptDelay {
    MNBasePublisherTimeoutSettings *publisherTimeoutSettings = self.config.publisherTimeoutSettings;
    if (publisherTimeoutSettings) {
        return publisherTimeoutSettings.gptrd;
    }
    return [NSNumber numberWithInt:DEFAULT_GPT_DELAY];
}

- (NSNumber *)getPrfDelay {
    MNBasePublisherTimeoutSettings *publisherTimeoutSettings = self.config.publisherTimeoutSettings;
    if (publisherTimeoutSettings) {
        return publisherTimeoutSettings.prfd;
    }
    return [NSNumber numberWithInt:DEFAULT_PREFETCH_DELAY];
}

- (BOOL)getIsAutorefresh {
    if (self.sdkConfigData == nil || self.sdkConfigData.isRefreshAdEnabled == nil) {
        return DEFAULT_IS_AUTO_REFRESH;
    }
    return [self.sdkConfigData.isRefreshAdEnabled isYes];
}

- (BOOL)getIsAdViewReuseEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.adViewReuseEnabled == nil) {
        return DEFAULT_ADVIEW_REUSE;
    }
    return [self.hbConfigData.adViewReuseEnabled isYes];
}

- (NSNumber *)getAdViewReuseMaxSize {
    if (self.hbConfigData == nil) {
        return [NSNumber numberWithInt:DEFAULT_ADVIEW_REUSE_MAX_SIZE];
    }
    return [self.hbConfigData adViewReuseCacheMaxSize];
}

- (NSNumber *)getAdViewReuseTimeout {
    if (self.hbConfigData == nil) {
        return [NSNumber numberWithInt:DEFAULT_ADVIEW_REUSE_TIMEOUT];
    }
    return [self.getHbConfigData adViewReuseCacheTimeout];
}

- (BOOL)getIsAdxEnabledForThirdParty {
    if (self.sdkConfigData == nil || self.sdkConfigData.mnetAdexOnThirdpartyEnabled == nil) {
        return DEFAULT_ADX_THIRD_PARTY_ENABLED;
    }
    return [self.sdkConfigData.mnetAdexOnThirdpartyEnabled isYes];
}

- (BOOL)getIsVideoFireEvents {
    if (self.sdkConfigData == nil || self.sdkConfigData.mnetFireVideoEvents == nil) {
        return DEFAULT_VIDEO_FIRE_EVENTS;
    }
    return [self.sdkConfigData.mnetFireVideoEvents isYes];
}

- (NSNumber *)getRefreshRate {
    double refreshRate = DEFAULT_REFRESH_RATE;
    if (self.sdkConfigData != nil) {
        NSString *refreshRateStr = [self.sdkConfigData refreshAdDurationSec];
        if (refreshRateStr) {
            refreshRate = [refreshRateStr doubleValue];
        }
    }
    return [NSNumber numberWithDouble:refreshRate];
}

- (NSNumber *)getMaxDfpVersionSupport {
    float compatibleVer;
    if (self.sdkConfigData == nil) {
        compatibleVer = DEFAULT_MAX_DFP_COMPATIBILITY_VER;
    } else {
        compatibleVer = [self.sdkConfigData mnetMaxDfpVersionSupport];
    }
    return [NSNumber numberWithFloat:compatibleVer];
}

- (NSNumber *)getPulseMaxArrLen {
    NSUInteger maxArrLen;
    if (self.sdkConfigData == nil) {
        maxArrLen = MAX_STORED_ARR_LEN;
    } else {
        maxArrLen = [self.sdkConfigData pulseMaxArrLen];
    }

    return [NSNumber numberWithUnsignedInteger:maxArrLen];
}

- (NSNumber *)getPulseMaxSize {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = MAX_STORED_SIZE;
    } else {
        numberObj = [self.sdkConfigData pulseMaxSize];
    }

    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getPulseMaxTimeInterval {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = MAX_PULSE_TIME_INTERVAL;
    } else {
        numberObj = [self.sdkConfigData pulseMaxTimeInterval];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getLocationUpdateInterval {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = LOCATION_UPDATE_INTERVAL;
    } else {
        numberObj = [self.sdkConfigData locationUpdateInterval];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getAppTrackerTimerInterval {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = APP_TRACKER_TIMER_INTERVAL;
    } else {
        numberObj = [self.sdkConfigData appTrackerTimerInterval];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getAppStoreUpdateInterval {
    float numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = APP_TRACKER_STORE_DURATION_INTERVAL;
    } else {
        numberObj = [self.sdkConfigData appStoreUpdateInterval];
    }
    return [NSNumber numberWithFloat:numberObj];
}

- (NSNumber *)getAdViewCacheCleanInterval {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = AD_VIEW_CACHE_CLEAN_INTERVAL;
    } else {
        numberObj = [self.sdkConfigData adViewCacheCleanInterval];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getAdViewCacheDuration {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = AD_VIEW_CACHE_DURATION;
    } else {
        numberObj = [self.sdkConfigData adViewCacheDuration];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getAppStoreMinEntries {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = APP_STORE_MIN_NUM_ENTRIES;
    } else {
        numberObj = [self.sdkConfigData appStoreMinNumerOfEntries];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (NSNumber *)getAppStoreMaxNumerOfEntries {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = APP_STORE_EXTRA_ENTRIES;
    } else {
        numberObj = [self.sdkConfigData appStoreMaxNumerOfEntries];
    }
    return [NSNumber numberWithUnsignedInteger:numberObj];
}

- (double)getRewardedInstanceMaxAge {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = REWARDED_INSTANCE_AGE;
    } else {
        numberObj = [self.sdkConfigData rewardedInstanceMaxAge];
    }
    return (double) numberObj;
}

- (double)getCacheMaxAge {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = CACHE_MAX_AGE;
    } else {
        numberObj = [self.sdkConfigData cacheMaxAge];
    }
    return (double) numberObj;
}

- (double)getCacheFileMaxSize {
    NSUInteger numberObj;
    if (self.sdkConfigData == nil) {
        numberObj = CACHE_FILE_SIZE;
    } else {
        numberObj = [self.sdkConfigData cacheFileMaxSize];
    }
    return (double) numberObj;
}

- (BOOL)getAutoRefreshStatusForAdUnitId:(NSString *)adUnitId {
    MNBaseAdUnitConfigData *hbConfigForAdUnit = [self getAdUnitConfigDataFor:adUnitId];
    if (hbConfigForAdUnit) {
        return [hbConfigForAdUnit.autorefreshEnabled isYes];
    }

    return NO;
}

- (NSNumber *)getAutoRefreshIntervalForAdUnitId:(NSString *)adUnitId {
    MNBaseAdUnitConfigData *hbConfigForAdUnit = [self getAdUnitConfigDataFor:adUnitId];
    if (hbConfigForAdUnit) {
        return hbConfigForAdUnit.autorefreshInterval;
    }

    return nil;
}

- (NSArray<NSNumber *> *)getBidderIdsListForAdUnitId:(NSString *)adUnitId {
    MNBaseAdUnitConfigData *hbConfigForAdUnit = [self getAdUnitConfigDataForCrid:adUnitId];
    if (hbConfigForAdUnit) {
        return hbConfigForAdUnit.bidderIds;
    }
    return nil;
}

- (BOOL)getVideoAutoPlayStatus {
    if (self.sdkConfigData == nil || self.sdkConfigData.isVideoAutoPlayEnabled == nil) {
        return DEFAULT_VIDEO_AUTO_PLAY;
    }
    return [self.sdkConfigData.isVideoAutoPlayEnabled isYes];
}

/// Link for the given viewController from the sdk config
- (NSString *)getLinkFromSdkConfigForVCName:(NSString *)VCName {
    if (VCName == nil || [VCName isEqualToString:@""]) {
        return nil;
    }

    MNBaseSdkConfigVCLinks *sdkConfigLinks = [self.sdkConfigData viewControllerLinks];
    if (sdkConfigLinks == nil) {
        return nil;
    }
    BOOL isConfigLinksEnabled = NO;
    if (sdkConfigLinks.isEnabled != nil) {
        isConfigLinksEnabled = [sdkConfigLinks.isEnabled isYes];
    }
    if (isConfigLinksEnabled) {
        NSDictionary<NSString *, NSString *> *linkMap = [sdkConfigLinks linkMap];
        if (linkMap != nil) {
            return [linkMap objectForKey:VCName];
        }
    }
    return nil;
}

- (BOOL)isAggressiveBiddingEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.mnetAgBidEnabled == nil) {
        return DEFAULT_MNET_AG_ENABLED;
    }
    return [self.hbConfigData.mnetAgBidEnabled isYes];
}

- (BOOL)isInappBrowsingEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.inAppBrowsingEnabled == nil) {
        return DEFAULT_INAPP_BROWSING_ENABLED;
    }
    return [self.hbConfigData.inAppBrowsingEnabled isYes];
}

- (BOOL)isRealTimeCrawlingEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.isRtcEnabled == nil) {
        return DEFAULT_REALTIME_CRAWLING_ENABLED;
    }
    return [self.hbConfigData.isRtcEnabled isYes];
}

- (NSNumber *)getYbncaAdTimeout {
    if (self.hbConfigData == nil || self.hbConfigData.ybncaAdTimeout == nil) {
        return [NSNumber numberWithInt:DEFAULT_YBNCA_AD_TIMEOUT];
    }
    return self.hbConfigData.ybncaAdTimeout;
}

- (BOOL)isAutoHbEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.isAutoHbEnabled == nil) {
        return DEFAULT_AUTO_HB_ENABLED;
    }
    return [self.hbConfigData.isAutoHbEnabled isYes];
}

- (BOOL)isAutoHbDfpEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.isAutoHbDfpEnabled == nil) {
        return DEFAULT_AUTO_HB_DFP_ENABLED;
    }
    return [self.hbConfigData.isAutoHbDfpEnabled isYes];
}

- (BOOL)isAutoHbMopubEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.isAutoHbMopubEnabled == nil) {
        return DEFAULT_AUTO_HB_MOPUB_ENABLED;
    }
    return [self.hbConfigData.isAutoHbMopubEnabled isYes];
}

- (BOOL)isHbEnabled {
    if (self.hbConfigData == nil || self.hbConfigData.isEnabled == nil) {
        return DEFAULT_HB_IS_ENABLED;
    }
    return [self.hbConfigData.isEnabled isYes];
}

- (BOOL)shouldMakeHttpRequests {
    if (self.sdkConfigData == nil || self.sdkConfigData.shouldMakeHttpRequests == nil) {
        return DEFAULT_SHOULD_MAKE_HTTP_REQUESTS;
    }
    return [self.sdkConfigData.shouldMakeHttpRequests isYes];
}

- (NSNumber *)getAdSlotDebugSamplingRate {
    NSNumber *slotSamplingRate;
    if (self.sdkConfigData != nil) {
        slotSamplingRate = [NSNumber numberWithFloat:self.sdkConfigData.mnetSlotDebugRate];
    }

    // Validate the sampling rate
    if (slotSamplingRate == nil || [slotSamplingRate integerValue] > 1 || [slotSamplingRate integerValue] < 0) {
        slotSamplingRate = [NSNumber numberWithFloat:DEFAULT_AD_SLOT_SAMPLE_RATE];
    }
    return slotSamplingRate;
}

- (NSNumber *)getConfigRefreshIntervalInSeconds {
    NSNumber *refreshIntervalInMs;
    if (self.sdkConfigData == nil || self.sdkConfigData.mnetConfigUpdateInterval == nil) {
        refreshIntervalInMs = [NSNumber numberWithInteger:DEFAULT_CONFIG_UPDATE_INTERVAL_IN_MS];
    } else {
        refreshIntervalInMs = self.sdkConfigData.mnetConfigUpdateInterval;
    }
    // Converting to secs
    NSNumber *refreshInterval = [NSNumber numberWithInteger:([refreshIntervalInMs integerValue] / 1000)];
    return refreshInterval;
}

- (NSString *)getMNBaseAmMt {
    if (self.sdkConfigData == nil || [self.sdkConfigData mnetAmMt] == nil) {
        return DEFAULT_AM_MT_MACRO;
    }
    return [self.sdkConfigData mnetAmMt];
}

- (NSNumber *)getNetworkRetryCount {
    if (self.sdkConfigData == nil || self.sdkConfigData.mnetNetworkRetryCount == nil) {
        return [NSNumber numberWithInteger:DEFAULT_RETRY_COUNT];
    }
    return self.sdkConfigData.mnetNetworkRetryCount;
}

- (BOOL)isEnabledAppendKeywordsRequrl {
    if (self.hbConfigData == nil || self.hbConfigData.appendKeywordsRequrl == nil) {
        return DEFAULT_APPEND_KEYWORDS_REQURL;
    }
    return [self.hbConfigData.appendKeywordsRequrl isYes];
}

#pragma mark Placeholder loader helper methods

- (MNBaseDefaultLoaders *)getLoadersForAdUnitId:(NSString *)adUnitId {
    // hb_config loaders will have priority over sdk_config
    if (self.hbConfigData != nil && self.hbConfigData.loaders != nil) {
        MNLogD(@"LOADERS: found hb_config loaders");
        return [self getDefaultLoaders:self.hbConfigData.loaders forAdUnitId:adUnitId];
    }

    if (self.sdkConfigData != nil && self.sdkConfigData.loaders != nil) {
        MNLogD(@"LOADERS: found sdk_config loaders");
        return [self getDefaultLoaders:self.sdkConfigData.loaders forAdUnitId:adUnitId];
    }
    return nil;
}

- (MNBaseDefaultLoaders *)getDefaultLoaders:(MNBaseLoaders *)loaders forAdUnitId:(NSString *)adUnitId {
    MNBaseDefaultLoaders *defaultLoaders;
    if (loaders.defaultLoaders != nil) {
        defaultLoaders = loaders.defaultLoaders;
    }
    if (loaders.adUnitsLoaders != nil && [loaders.adUnitsLoaders objectForKey:adUnitId] != nil) {
        defaultLoaders = (MNBaseDefaultLoaders *) [loaders.adUnitsLoaders objectForKey:adUnitId];
    }
    return defaultLoaders;
}

- (void)fetchAdPlaceholderLoaders:(MNBaseLoaders *)loaders {
    if (loaders.adUnitsLoaders != nil) {
        NSDictionary *adUnitLoaders = loaders.adUnitsLoaders;
        NSArray *keys               = [NSArray arrayWithArray:[adUnitLoaders allKeys]];
        for (NSString *key in keys) {
            if ([adUnitLoaders objectForKey:key] != nil) {
                MNBaseDefaultLoaders *loader = (MNBaseDefaultLoaders *) [adUnitLoaders objectForKey:key];
                [self fetchLoadersFor:loader];
            }
        }
    }

    if (loaders.defaultLoaders != nil) {
        MNBaseDefaultLoaders *defaultLoaders = loaders.defaultLoaders;
        [self fetchLoadersFor:defaultLoaders];
    }
}

- (BOOL)getIsShimmerEnabled {
    if (self.hbConfigData != nil && self.hbConfigData.shouldShimmer != nil) {
        return [self.hbConfigData.shouldShimmer isYes];
    }
    return DEFAULT_SHOULD_SHIMMER;
}

- (BOOL)doNotTrackForEurope {
    if (self.hbConfigData != nil && self.hbConfigData.euDoNotTrack != nil) {
        return [self.hbConfigData.euDoNotTrack isYes];
    }
    return DEFAULT_DO_NOT_TRACK_EU;
}

- (void)fetchLoadersFor:(MNBaseDefaultLoaders *)loaders {
    NSString *bannerURL       = [MNBaseUtil getResourceURLForResourceName:loaders.banner];
    NSString *mediumURL       = [MNBaseUtil getResourceURLForResourceName:loaders.medium];
    NSString *interstitialURL = [MNBaseUtil getResourceURLForResourceName:loaders.interstitial];
    NSArray *loaderArray      = [NSArray arrayWithObjects:bannerURL, mediumURL, interstitialURL, nil];
    for (NSString *url in loaderArray) {
        [MNBaseHttpClient doGetImageOn:url
            success:^(UIImage *image) {
              MNLogD(@"LOADERS: Downloaded loader url : %@", url);
            }
            error:^(NSError *error) {
              MNLogD(@"LOADERS: Error in downloading loader url : %@", url);
            }];
    }
}

- (NSNumber *)getMaxUrlLength {
    if (self.sdkConfigData != nil && self.sdkConfigData.urlLengthMax != nil) {
        return [self.sdkConfigData urlLengthMax];
    }
    return [NSNumber numberWithInteger:DEFAULT_MAX_URL_LENGTH];
}

- (BOOL)getIsEU {
    if (self.sdkConfigData != nil && self.sdkConfigData.isEu) {
        return [self.sdkConfigData.isEu isYes];
    }
    return DEFAULT_IS_EU;
}

static NSArray<NSString *> *europeanUnionCountryCodes;
- (NSArray<NSString *> *)getDefaultEUList {
    // List of european union countries taken from
    // These country codes are used for default value
    // https://gist.github.com/henrik/1688572#gistcomment-2596891

    // List of european country codes for reference
    // http://www.countryareacode.net/en/list-of-countries-according-to-continent/europe

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      europeanUnionCountryCodes = @[
          @"AT", @"BE", @"BG", @"HR", @"CY", @"CZ", @"DK", @"EE", @"FI", @"FR", @"DE", @"GR", @"HU",
          @"IE", @"IT", @"LV", @"LT", @"LU", @"MT", @"NL", @"PL", @"PT", @"RO", @"SK", @"SI", @"ES",
          @"SE", @"GB", @"GF", @"GP", @"MQ", @"ME", @"YT", @"RE", @"MF", @"GI", @"AX", @"GL", @"BL",
          @"SX", @"AW", @"CW", @"WF", @"PF", @"NC", @"TF", @"AI", @"BM", @"IO", @"VG", @"KY", @"FK",
          @"MS", @"PN", @"SH", @"GS", @"TC", @"AD", @"LI", @"MC", @"SM", @"VA", @"JE", @"GG"
      ];
    });
    return europeanUnionCountryCodes;
}

- (NSArray<NSString *> *)getEUList {
    if (self.sdkConfigData != nil && self.sdkConfigData.mnetEuCc != nil) {
        return self.sdkConfigData.mnetEuCc;
    }
    return [self getDefaultEUList];
}

- (NSString *)getCCAlpha2 {
    if (self.sdkConfigData != nil && self.sdkConfigData.ccAlpha2 != nil) {
        return self.sdkConfigData.ccAlpha2;
    }
    return @"";
}

- (NSString *)getCCAlpha3 {
    if (self.sdkConfigData != nil && self.sdkConfigData.ccAlpha3 != nil) {
        return self.sdkConfigData.ccAlpha3;
    }
    return @"";
}

- (NSInteger)getVendorId {
    if (self.sdkConfigData != nil && self.sdkConfigData.gdprVendorId != nil) {
        return [self.sdkConfigData.gdprVendorId integerValue];
    }
    return DEFAULT_VENDOR_ID;
}

- (NSArray *_Nullable)getWkWebviewSupportedVersions {
    if (self.sdkConfigData != nil && [self.sdkConfigData useWkwebviewForIosVersion] != nil &&
        [[self.sdkConfigData useWkwebviewForIosVersion] count] > 0) {
        return [self.sdkConfigData useWkwebviewForIosVersion];
    }
    return nil;
}

- (BOOL)isSwizzlingEnabled {
    if (self.hbConfigData != nil && [self.hbConfigData isSwizzlingVcEnabled] != nil) {
        return [[self.hbConfigData isSwizzlingVcEnabled] isYes];
    }
    return DEFAULT_IS_SWIZZLING_VC_ENABLED;
}

- (BOOL)isPulseEnabled {
    if (self.hbConfigData != nil && [self.hbConfigData isPulseEnabled] != nil) {
        return [[self.hbConfigData isPulseEnabled] isYes];
    }
    return DEFAULT_PULSE_ENABLED;
}

- (NSArray<NSString *> *_Nullable)fetchPulseEventWhiteList {
    if (self.hbConfigData != nil && [self.hbConfigData pulseWhiteList] != nil &&
        [[self.hbConfigData pulseWhiteList] count] > 0) {
        return [self.hbConfigData pulseWhiteList];
    }
    return nil;
}

@end
