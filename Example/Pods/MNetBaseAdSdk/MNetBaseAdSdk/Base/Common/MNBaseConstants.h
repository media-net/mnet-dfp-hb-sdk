//
//  MNBaseConstants.h
//  Pods
//
//  Created by kunal.ch on 23/02/17.
//
//

#import <UIKit/UIKit.h>

@interface MNBaseConstants : NSObject

#define CONFIG_ID @"mnet_id_ios"
#define CONFIG_APP_KEY @"has_app_urls"

// Ad type
#define VIDEO_STRING @"video"
#define BANNER_STRING @"banner"
#define RESPONSIVE_BANNER_STRING @"responsive_banner"
#define REWARDED_VIDEO_STRING @"rewarded_video"
#define MRAID_STRING @"mraid"
#define UNKNOWN_STRING @"unknown"

// Request related
#define PLATFORM_NAME @"ios"

// Response related
#define BID_TYPE_ADX @"adxd"
#define BID_TYPE_FIRST_PARTY @"fpd"
#define BID_TYPE_THIRD_PARTY @"tpd"

// Network related
#define DEFAULT_NETWORK_TIMEOUT 10
#define DEFAULT_NETWORK_PREFETCH_TIMEOUT 5

// Header bidder related
#define DEFAULT_HB_IS_ENABLED YES
#define ADAPTER_PARAMS_BIDDER_ID_KEY @"bidder_id"

// External Apis
#define GAD_APPLICATION_ID @"ca-app-pub-6365858186554077~2677656745"

// Ad refresh rate defaults (in seconds)
#define DEFAULT_REFRESH_RATE 30.0f
#define DEFAULT_IS_AUTO_REFRESH NO

// Delays
#define DEFAULT_GPT_DELAY 400
#define DEFAULT_PREFETCH_DELAY 0

// Ad view reuse
#define DEFAULT_ADVIEW_REUSE YES
#define DEFAULT_ADVIEW_REUSE_TIMEOUT 60
#define DEFAULT_ADVIEW_REUSE_MAX_SIZE 3

// Aggressive bidding enabled
#define DEFAULT_MNET_AG_ENABLED YES

// Should shimmer
#define DEFAULT_SHOULD_SHIMMER NO

// Should track idfa based on locale
#define DEFAULT_DO_NOT_TRACK_EU YES

// Real time crawling default value
#define DEFAULT_REALTIME_CRAWLING_ENABLED NO

// Inapp browsing enabled
#define DEFAULT_INAPP_BROWSING_ENABLED YES

// Pulse limit defaults
#define MAX_STORED_ARR_LEN 10
// This is in bytes
#define MAX_STORED_SIZE 4000
#define MAX_PULSE_TIME_INTERVAL 1800 // This is 60*30 seconds

// Location Update defaults
#define LOCATION_ACCURACY_THRESHOLD 500
// This is in seconds
#define LOCATION_UPDATE_INTERVAL 1000

// Store file names
#define APP_DISCOVER_FILE_STORE_NAME @"net_media_MNAdSdk_apps.json";
#define PULSE_FILE_STORE_NAME @"net_media_MNAdSdk_pulse.json"

// App tracker specific
#define APP_STORE_MIN_NUM_ENTRIES 200
#define APP_STORE_EXTRA_ENTRIES 100

#define APP_TRACKER_TIMER_INTERVAL 1000
#define APP_TRACKER_STORE_DURATION_INTERVAL 86400.0

// Rewarded Instance Age
#define REWARDED_INSTANCE_AGE 10

// Cache file max age
#define CACHE_MAX_AGE (15 * 60) // 15 minutes

// Cache file size
#define CACHE_FILE_SIZE (25 * 1024 * 1024) // 25 MB

// AdViewStore keys
#define CACHE_KEY @"__mnet_ad_view_cache_key"
#define ADX_CACHE_KEY @"__mnet_adx_cache_key"
#define HB_AD_UNIQUE_ID @"__mnet_ad_cycle_id"
#define DEFAULT_ADX_THIRD_PARTY_ENABLED NO

// DFP
#define DEFAULT_MAX_DFP_COMPATIBILITY_VER 7

// AdView store specific keys
#define AD_VIEW_CACHE_CLEAN_INTERVAL (5 * 60) // 5 minutes
#define AD_VIEW_CACHE_DURATION (1 * 60)       // 1 minute

// Video default auto play
#define DEFAULT_VIDEO_AUTO_PLAY YES
// Video logs keys
#define DEFAULT_VIDEO_FIRE_EVENTS YES
#define DEFAULT_AM_MT_MACRO @""
#define VIDEO_LOG_BIDDER_ID_KEY @"${BIDDER_ID}"
#define VIDEO_LOG_WIN_PRICE_KEY @"${WIN_PRICE}"
#define VIDEO_LOG_ADSIZE_KEY @"${ADSIZE}"
#define VIDEO_LOG_EVENT_ID_KEY @"${EVENT_ID}"
#define VIDEO_LOG_DURATION_KEY @"${DURATION}"

// Ad Controllers and their selectors
#define BANNER_AD_CONTROLLER @"MNBaseBannerAdController"
#define RESPONSIVE_BANNER_AD_CONTROLLER @"MNBaseResponsiveBannerAdController"
#define VIDEO_AD_CONTROLLER @"MNBaseVideoAdController"
#define REWARDED_AD_CONTROLLER @"MNBaseRewardedVideoController"
#define MNET_DFP_AD_CONTROLLER @"MNBaseDfpAdController"
#define MNET_MRAID_AD_CONTROLLER @"MNBaseMRAIDAdController"

#define SEL_BANNER_AD_CONTROLLER @"newBannerAdController"
#define SEL_RESPONSIVE_BANNER_AD_CONTROLLER @"newResponsiveBannerAdController"
#define SEL_VIDEO_AD_CONTROLLER @"newVideoAdController"
#define SEL_REWARDED_AD_CONTROLLER @"newRewardedAdController"
#define SEL_MNET_DFP_AD_CONTROLLER @"newMnetDfpAdController"
#define SEL_MRAID_AD_CONTROLLER @"newMRAIDAdController"

// Is prefetch enabled by default
#define DEFAULT_IS_PREFETCH_ENABLED_BIDDER NO

// YBNC bidder id
#define YBNC_BIDDER_ID [NSNumber numberWithInt:10000]

// YBNC delay (in secs)
#define YBNC_RENDER_DELAY 0.05

// Default timeout for Ads
// Default to 5 seconds for now
#define DEFAULT_YBNCA_AD_TIMEOUT 15

// Automatic-hb enabled
#define DEFAULT_AUTO_HB_ENABLED NO
#define DEFAULT_AUTO_HB_DFP_ENABLED NO
#define DEFAULT_AUTO_HB_MOPUB_ENABLED NO

// Is http enabled
#define DEFAULT_SHOULD_MAKE_HTTP_REQUESTS NO

// Default ad-slot sampling rate
#define DEFAULT_AD_SLOT_SAMPLE_RATE 1.00

// Default config update interval - 10 minutes
#define DEFAULT_CONFIG_UPDATE_INTERVAL_IN_MS 600000

// Exponential Backoff constants
#define DEFAULT_RETRY_COUNT 3
#define DEFAULT_RETRY_EXPONENTIAL_BASE 2

// Append req-url constants
#define DEFAULT_APPEND_KEYWORDS_REQURL NO

// Max url length in bytes
#define DEFAULT_MAX_URL_LENGTH 1024

// Default is_eu flag
#define DEFAULT_IS_EU NO

// Default vendor id
#define DEFAULT_VENDOR_ID 142

// Default for - is swizzling for view-controllers is enabled
#define DEFAULT_IS_SWIZZLING_VC_ENABLED NO

// Default pulse
#define DEFAULT_PULSE_ENABLED NO

@end
