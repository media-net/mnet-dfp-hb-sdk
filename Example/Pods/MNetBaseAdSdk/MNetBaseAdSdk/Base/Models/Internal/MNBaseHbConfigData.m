//
//  MNBaseHbConfigData.m
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseHbConfigData.h"
#import "MNBaseConstants.h"
#import "MNBaseHttpClient.h"
#import "MNBaseUtil.h"

#define CONFIG_KEY_HB @"hbConfig"
#define HB_CONFIG_ENABLED_KEY @"enabled"
#define HB_CONFIG_AD_UNIT_DATA_KEY @"ad_units"
#define ADVIEW_REUSE_ENABLE_KEY @"adview_reuse_enabled"
#define ADVIEW_REUSE_TIMEOUT_KEY @"adview_cache_timeout"
#define ADVIEW_REUSE_CACHE_SIZE @"adview_cache_max"
#define HB_CONFIG_DEFAULT_BIDS @"default_bids"
#define MNET_INAPP_BROWSING_ENABLED @"mnet_inapp_browsing_enabled"

@implementation MNBaseHbConfigData

- (instancetype)init {
    self = [super init];
    if (self) {
        _adViewReuseCacheMaxSize = [NSNumber numberWithInt:DEFAULT_ADVIEW_REUSE_MAX_SIZE];
        _adViewReuseCacheTimeout = [NSNumber numberWithInt:DEFAULT_ADVIEW_REUSE_TIMEOUT];
        _adViewReuseEnabled      = [MNJMBoolean createWithBool:DEFAULT_ADVIEW_REUSE];
        _inAppBrowsingEnabled    = [MNJMBoolean createWithBool:DEFAULT_INAPP_BROWSING_ENABLED];
        _isRtcEnabled            = [MNJMBoolean createWithBool:DEFAULT_REALTIME_CRAWLING_ENABLED];
        _ybncaAdTimeout          = [NSNumber numberWithInt:DEFAULT_YBNCA_AD_TIMEOUT];
        _isAutoHbEnabled         = [MNJMBoolean createWithBool:DEFAULT_AUTO_HB_ENABLED];
        _isEnabled               = [MNJMBoolean createWithBool:DEFAULT_HB_IS_ENABLED];
        _appendKeywordsRequrl    = [MNJMBoolean createWithBool:DEFAULT_APPEND_KEYWORDS_REQURL];
        _mnetAgBidEnabled        = [MNJMBoolean createWithBool:DEFAULT_MNET_AG_ENABLED];
        _shouldShimmer           = [MNJMBoolean createWithBool:DEFAULT_SHOULD_SHIMMER];
        _isAutoHbDfpEnabled      = [MNJMBoolean createWithBool:DEFAULT_AUTO_HB_DFP_ENABLED];
        _isAutoHbMopubEnabled    = [MNJMBoolean createWithBool:DEFAULT_AUTO_HB_MOPUB_ENABLED];
        _euDoNotTrack            = [MNJMBoolean createWithBool:DEFAULT_DO_NOT_TRACK_EU];
        _isSwizzlingVcEnabled    = [MNJMBoolean createWithBool:DEFAULT_IS_SWIZZLING_VC_ENABLED];
        _isPulseEnabled          = [MNJMBoolean createWithBool:DEFAULT_PULSE_ENABLED];
        _isCrawledTitleEnabled   = [MNJMBoolean createWithBool:DEFAULT_CRAWLED_LINK_TITLE_ENABLED];
        _intentContentLimit      = [NSNumber numberWithInteger:DEFAULT_INTENT_CONTENT_LIMIT];
    }
    return self;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"isAutoHbEnabled" : @"automatic_hb_enabled",
        @"isAutoHbDfpEnabled" : @"automatic_hb_dfp_enabled",
        @"isAutoHbMopubEnabled" : @"automatic_hb_mopub_enabled",
        @"isEnabled" : @"enabled",
        @"loaders" : @"loaders",
        @"adViewReuseEnabled" : @"adview_reuse_enabled",
        @"adViewReuseCacheTimeout" : @"adview_cache_timeout",
        @"adViewReuseCacheMaxSize" : @"adview_cache_max",
        @"inAppBrowsingEnabled" : @"mnet_inapp_browsing_enabled",
        @"adUnitConfigDataList" : @"ad_units",
        @"isRtcEnabled" : @"is_rtc_enabled",
        @"ybncaAdTimeout" : @"ybnca_ad_timeout",
        @"shouldShimmer" : @"mnet_should_shimmer",
        @"euDoNotTrack" : @"eudnt",
        @"isPulseEnabled" : @"enable_pulse",
        @"pulseWhiteList" : @"wh_p_ev",
        @"isCrawledTitleEnabled" : @"crawled_link_title_enabled",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"adUnitConfigDataList" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseAdUnitConfigData class]],
        @"defaultBids" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseDefaultBid class]],
        @"pulseWhiteList" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
    };
}

- (NSArray<NSString *> *)directMapForKeys {
    return @[ @"intentSkipList" ];
}

@end
