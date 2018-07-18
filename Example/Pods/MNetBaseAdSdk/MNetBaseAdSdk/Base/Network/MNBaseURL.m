//
//  MNBaseURL.m
//  Pods
//
//  Created by nithin.g on 26/07/17.
//
//

#import "MNBase.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL+Internal.h"

@implementation MNBaseURL

static NSString *HTTP  = @"http://";
static NSString *HTTPS = @"https://";

static NSString *BASE_URL       = @"rtb.msas.media.net";
static NSString *DEBUG_BASE_URL = @"staging.rtb.msas.media.net";

static NSString *BASE_PATH_DP     = @"/d";
static NSString *BASE_PATH_CONFIG = @"/c";
static NSString *BASE_PATH_PULSE  = @"/p";

static NSString *DP_PATH_PREFIX                       = @"/api/v4/rtb/";
static NSString *AD_LOADER_PREDICT_BIDS_PATH          = @"/bids";
static NSString *AD_LOADER_PREFETCH_PREDICT_BIDS_PATH = @"/bids/prefetch";
static NSString *AUCTION_LOGGER_PATH                  = @"/logs";

static NSString *LATENCY_TEST_PATH        = @"/api/v1/hello";
static NSString *FINGERPRINT_PATH         = @"/api/v1/fingerprint";
static NSString *CONFIG_PATH              = @"/api/v1/config";
static NSString *PULSE_PATH               = @"/api/v1/log";
static NSString *BASE_PATH_RESOURCE       = @"/r/ios";
static NSString *DEBUG_BASE_PATH_RESOURCE = @"/rs/ios";

static MNBaseURL *instance;

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseURL alloc] init];
    });
    return instance;
}

+ (BOOL)checkIfHttpAllowed {
    NSString *appTransportSecurityKey = @"NSAppTransportSecurity";
    NSString *allowArbitraryLoadsKey  = @"NSAllowsArbitraryLoads";

    NSObject *transportSecurityValues = [[NSBundle mainBundle].infoDictionary objectForKey:appTransportSecurityKey];
    if (transportSecurityValues != nil && [transportSecurityValues isKindOfClass:[NSDictionary class]]) {
        NSDictionary *transportSecurityDict = (NSDictionary *) transportSecurityValues;
        NSNumber *arbitraryLoadsObj         = [transportSecurityDict objectForKey:allowArbitraryLoadsKey];
        if (arbitraryLoadsObj != nil) {
            NSUInteger allowArbitraryLoadsValue = [arbitraryLoadsObj unsignedIntegerValue];
            return (allowArbitraryLoadsValue == 1);
        }
    }

    return NO;
}

- (instancetype)init {
    self = [super init];

#ifdef DEBUG
    _isDebug = YES;
#else
    _isDebug = NO;
#endif

    self.httpAllowed = NO;
    _urlProtocol     = (_httpAllowed) ? HTTP : HTTPS;

    // listen to update for notification
    self.sdkConfigNotificationObj =
        [MNBaseNotificationManager addObserverToNotification:MNBaseNotificationSdkConfigUpdated
                                                   withBlock:^(NSNotification *_Nonnull notificationObj) {
                                                     if ([[MNBaseSdkConfig getInstance] shouldMakeHttpRequests]) {
                                                         [self allowHttp];
                                                     }
                                                   }];
    return self;
}

- (BOOL)isHttpAllowed {
    return _httpAllowed;
}

/// Tries to allow http for all the urls. Will return no if http cannot be allowed.
- (BOOL)allowHttp {
    if (_httpAllowed) {
        return YES;
    }
    _httpAllowed = [MNBaseURL checkIfHttpAllowed];
    if (_httpAllowed) {
        _urlProtocol = HTTP;
    }
    return _httpAllowed;
}

static NSString *customerId;
- (NSString *_Nonnull)getCustomerId {
    if (customerId == nil) {
        customerId = [[MNBase getInstance] customerId];
    }
    return customerId;
}

- (NSString *)getBaseUrl {
    return (self.isDebug) ? DEBUG_BASE_URL : BASE_URL;
}

- (NSString *)getBaseUrlDp {
    return [self buildUrl:self.urlProtocol, [self getBaseUrl], BASE_PATH_DP, nil];
}

- (NSString *)getBaseConfigUrl {
    return [self buildUrl:self.urlProtocol, [self getBaseUrl], BASE_PATH_CONFIG, nil];
}

- (NSString *)getBasePulseUrl {
    return [self buildUrl:self.urlProtocol, [self getBaseUrl], BASE_PATH_PULSE, nil];
}

- (NSString *)getBaseResourceUrl {
    NSString *resourcePath = (self.isDebug) ? DEBUG_BASE_PATH_RESOURCE : BASE_PATH_RESOURCE;
    return [self buildUrl:self.urlProtocol, [self getBaseUrl], resourcePath, nil];
}

- (NSString *)getLatencyTestUrl {
    return [self buildUrl:[self getBaseUrlDp], LATENCY_TEST_PATH, nil];
}

- (NSString *)getAdLoaderPredictBidsUrl {
    return [self buildUrl:[self getBaseUrlDp], DP_PATH_PREFIX, [self getCustomerId], AD_LOADER_PREDICT_BIDS_PATH, nil];
}

- (NSString *)getAdLoaderPrefetchPredictBidsUrl {
    return [self
        buildUrl:[self getBaseUrlDp], DP_PATH_PREFIX, [self getCustomerId], AD_LOADER_PREFETCH_PREDICT_BIDS_PATH, nil];
}

- (NSString *)getAuctionLoggerUrl {
    return [self buildUrl:[self getBaseUrlDp], DP_PATH_PREFIX, [self getCustomerId], AUCTION_LOGGER_PATH, nil];
}

- (NSString *)getConfigUrl {
    return [self buildUrl:[self getBaseConfigUrl], CONFIG_PATH, nil];
}

- (NSString *)getPulseUrl {
    return [self buildUrl:[self getBasePulseUrl], PULSE_PATH, nil];
}

- (NSString *)getFingerPrintUrl {
    return [self buildUrl:[self getBaseUrlDp], FINGERPRINT_PATH, nil];
}

- (NSString *)buildUrl:(NSString *)baseUrl, ... NS_REQUIRES_NIL_TERMINATION {
    // NOTE: Why use mutable string?
    // Refer - http://www.b2cloud.com.au/general-thoughts/obj-c-performance-week-1-concatenating-strings/
    NSMutableString *mutableStr = [[NSMutableString alloc] init];
    va_list paramsList;
    va_start(paramsList, baseUrl);

    for (NSString *param = baseUrl; param != nil; param = va_arg(paramsList, NSString *)) {
        [mutableStr appendString:param];
    }
    va_end(paramsList);

    return [mutableStr copy];
}

- (void)dealloc {
    if (self.sdkConfigNotificationObj != nil) {
        [MNBaseNotificationManager removeObserver:self.sdkConfigNotificationObj
                                         withName:MNBaseNotificationSdkConfigUpdated];
    }
}

@end
