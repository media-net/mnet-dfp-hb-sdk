//
//  MNBaseSdkConfig.h
//  Pods
//
//  Created by kunal.ch on 23/02/17.
//
//

#import "MNBaseConfig.h"
#import "MNBaseHbConfigData.h"
#import "MNBaseSdkConfigData.h"
#import <Foundation/Foundation.h>

@interface MNBaseSdkConfig : NSObject

+ (MNBaseSdkConfig *)getInstance;
+ (void)initSdkConfig;
- (void)updateConfig;
- (NSDictionary *)getConfig;
- (MNBaseHbConfigData *)getHbConfigData;
- (MNBaseSdkConfigData *)getSdkConfigData;

// Helpers
- (BOOL)getAutoRefreshStatusForAdUnitId:(NSString *)adUnitId;
- (NSNumber *)getAutoRefreshIntervalForAdUnitId:(NSString *)adUnitId;
- (NSArray<NSNumber *> *)getBidderIdsListForAdUnitId:(NSString *)adUnitId;
- (void)updateConfigExternally:(MNBaseConfig *)externalConfig;
- (BOOL)getVideoAutoPlayStatus;

- (BOOL)getIsAutorefresh;
- (BOOL)getIsAdxEnabledForThirdParty;
- (BOOL)getIsVideoFireEvents;
- (NSNumber *)getPrfDelay;
- (NSNumber *)getGptDelay;
- (NSNumber *)getRefreshRate;
- (NSNumber *)getPulseMaxArrLen;
- (NSNumber *)getPulseMaxSize;
- (NSNumber *)getPulseMaxTimeInterval;
- (NSNumber *)getLocationUpdateInterval;
- (NSNumber *)getAppTrackerTimerInterval;
- (NSNumber *)getAppStoreUpdateInterval;
- (NSNumber *)getAppStoreMinEntries;
- (NSNumber *)getAppStoreMaxNumerOfEntries;
- (NSNumber *)getMaxDfpVersionSupport;
- (NSNumber *)getAdViewCacheCleanInterval;
- (NSNumber *)getAdViewCacheDuration;
- (double)getRewardedInstanceMaxAge;
- (double)getCacheMaxAge;
- (double)getCacheFileMaxSize;
- (BOOL)getIsAdViewReuseEnabled;
- (NSNumber *)getAdViewReuseMaxSize;
- (NSNumber *)getAdViewReuseTimeout;
- (NSString *)getLinkFromSdkConfigForVCName:(NSString *)VCName;
- (BOOL)isAggressiveBiddingEnabled;
- (BOOL)isInappBrowsingEnabled;
- (BOOL)isRealTimeCrawlingEnabled;
- (NSNumber *)getYbncaAdTimeout;
- (BOOL)isAutoHbEnabled;
- (BOOL)isAutoHbMopubEnabled;
- (BOOL)isAutoHbDfpEnabled;
- (BOOL)isHbEnabled;
- (BOOL)shouldMakeHttpRequests;
- (NSNumber *)getAdSlotDebugSamplingRate;
- (NSNumber *)getConfigRefreshIntervalInSeconds;
- (NSString *)getMNBaseAmMt;
- (MNBaseDefaultLoaders *)getLoadersForAdUnitId:(NSString *)adUnitId;
- (NSNumber *)getNetworkRetryCount;
- (BOOL)isEnabledAppendKeywordsRequrl;
- (BOOL)getIsShimmerEnabled;
- (BOOL)doNotTrackForEurope;
- (NSNumber *)getMaxUrlLength;
- (BOOL)getIsEU;
- (NSArray<NSString *> *)getEUList;
- (NSString *)getCCAlpha2;
- (NSString *)getCCAlpha3;
- (NSInteger)getVendorId;
- (NSArray *_Nullable)getWkWebviewSupportedVersions;
- (BOOL)isSwizzlingEnabled;

@end
