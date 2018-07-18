//
//  MNBaseSdkConfigData.m
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseSdkConfigData.h"
#import "MNBaseConstants.h"

@implementation MNBaseSdkConfigData

- (instancetype)init {
    self = [super init];
    if (self) {
        _isRefreshAdEnabled          = [MNJMBoolean createWithBool:DEFAULT_IS_AUTO_REFRESH];
        _mnetAdexOnThirdpartyEnabled = [MNJMBoolean createWithBool:DEFAULT_ADX_THIRD_PARTY_ENABLED];
        _mnetFireVideoEvents         = [MNJMBoolean createWithBool:DEFAULT_VIDEO_FIRE_EVENTS];
        _mnetMaxDfpVersionSupport    = DEFAULT_MAX_DFP_COMPATIBILITY_VER;
        _pulseMaxArrLen              = MAX_STORED_ARR_LEN;
        _pulseMaxSize                = MAX_STORED_SIZE;
        _pulseMaxTimeInterval        = MAX_PULSE_TIME_INTERVAL;
        _locationUpdateInterval      = LOCATION_UPDATE_INTERVAL;
        _appTrackerTimerInterval     = APP_TRACKER_TIMER_INTERVAL;
        _appStoreUpdateInterval      = APP_TRACKER_STORE_DURATION_INTERVAL;
        _adViewCacheCleanInterval    = AD_VIEW_CACHE_CLEAN_INTERVAL;
        _adViewCacheDuration         = AD_VIEW_CACHE_DURATION;
        _appStoreMinNumerOfEntries   = APP_STORE_MIN_NUM_ENTRIES;
        _appStoreMaxNumerOfEntries   = APP_STORE_EXTRA_ENTRIES;
        _rewardedInstanceMaxAge      = REWARDED_INSTANCE_AGE;
        _cacheMaxAge                 = CACHE_MAX_AGE;
        _cacheFileMaxSize            = CACHE_FILE_SIZE;
        _isVideoAutoPlayEnabled      = [MNJMBoolean createWithBool:DEFAULT_VIDEO_AUTO_PLAY];
        float refreshRate            = DEFAULT_REFRESH_RATE;
        _refreshAdDurationSec        = [[NSNumber numberWithFloat:refreshRate] stringValue];
        _shouldMakeHttpRequests      = [MNJMBoolean createWithBool:DEFAULT_SHOULD_MAKE_HTTP_REQUESTS];
        _mnetSlotDebugRate           = DEFAULT_AD_SLOT_SAMPLE_RATE;
        _mnetConfigUpdateInterval    = [NSNumber numberWithInteger:DEFAULT_CONFIG_UPDATE_INTERVAL_IN_MS];
        _mnetAmMt                    = DEFAULT_AM_MT_MACRO;
        _mnetNetworkRetryCount       = [NSNumber numberWithInteger:DEFAULT_RETRY_COUNT];
        _urlLengthMax                = [NSNumber numberWithInteger:DEFAULT_MAX_URL_LENGTH];
        _isEu                        = [MNJMBoolean createWithBool:DEFAULT_IS_EU];
        _gdprVendorId                = [NSNumber numberWithInteger:DEFAULT_VENDOR_ID];
    }
    return self;
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"euList" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
        @"useWkwebviewForIosVersion" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]],
    };
}

@end
