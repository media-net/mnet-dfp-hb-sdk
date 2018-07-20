//
//  MNBase.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 04/07/18.
//

#import "MNBase.h"
#import "MNBaseAdDetailsStore.h"
#import "MNBaseAdRequest.h"
#import "MNBaseAdViewStore.h"
#import "MNBaseAppCrashCatcher.h"
#import "MNBaseDataPrivacy.h"
#import "MNBaseDiskLRUCache.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLocationDataTracker.h"
#import "MNBaseLogger.h"
#import "MNBasePrefetchBids.h"
#import "MNBasePulseHttp.h"
#import "MNBasePulseTracker.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

#define DEFAULT_COLOR [UIColor colorWithRed:47 / 255.0 green:58 / 255.0 blue:74 / 255.0 alpha:1]
#define MNET_BASE_AD_SDK_VERSION_CODE 1
// TODO MNBase right now keeping the base sdk version same as current ad sdk. Need to discuss the versioning of sdk's
// according to revamp structure
#define MNET_BASE_AD_SDK_VERSION_NAME @"0.6.0"

@interface MNBase ()
@property NSString *visitId;
@end

@implementation MNBase

@synthesize customerId       = _customerId;
@synthesize sdkVersionName   = _sdkVersionName;
@synthesize sdkVersionNumber = _sdkVersionNumber;

static MNBase *sInstance = nil;

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationHasEnteredForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationHasEnteredBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

        // Generate a random id
        _visitId = [MNBaseUtil createId];

        // Initialise the user object
        _user = [[MNBaseUser alloc] init];

        // Initialize with default color
        _clickThroughVCNavColor = DEFAULT_COLOR;

        // Enabling logs only if debug mode is used
#ifdef DEBUG
        _isLogsEnabled = YES;
#else
        _isLogsEnabled = NO;
#endif
    }
    return self;
}

+ (MNBase *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sInstance = [[self alloc] init];
    });
    return sInstance;
}

+ (BOOL)isInitialized {
    return sInstance != nil;
}

+ (instancetype)initWithCustomerId:(NSString *)customerId
    appContainsChildDirectedContent:(BOOL)containsChildDirectedContent
                     sdkVersionName:(NSString *)sdkVersionName
                   sdkVersionNumber:(NSUInteger)sdkVersionNumber {
    if (!customerId) {
        customerId = @"";
    }
    [[self getInstance] setCustomerId:customerId];
    [[self getInstance] setAppContainsChildDirectedContent:containsChildDirectedContent];
    [[self getInstance] setSdkVersionName:sdkVersionName];
    [[self getInstance] setSdkVersionNumber:sdkVersionNumber];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            [self initializeMNBase];
        } @catch (NSException *e) {
            MNLogE(@"EXCEPTION - Initializing the customer-id - %@", e);
        }
      });
    });
    return sInstance;
}

+ (void)enableLogs:(BOOL)enabled {
    MNBase *instance       = [self getInstance];
    instance.isLogsEnabled = enabled;
}

- (NSString *)getVisitId {
    NSString *visitId;
    if (sInstance) {
        visitId = sInstance.visitId;
    }
    if (visitId == nil) {
        visitId = @"";
    }
    return visitId;
}

+ (NSString *)getBaseSdkVersionName {
    return MNET_BASE_AD_SDK_VERSION_NAME;
}

+ (NSUInteger)getBaseSdkVersionCode {
    return MNET_BASE_AD_SDK_VERSION_CODE;
}

+ (void)updateGdprConsentString:(NSString *)consentString
                  consentStatus:(NSInteger)status
                  subjectToGdpr:(NSInteger)gdpr {
    [[MNBaseDataPrivacy getSharedInstance] manuallyUpdateGdprConsentString:consentString
                                                             consentStatus:status
                                                             subjectToGdpr:gdpr];
}

+ (void)initializeMNBase {
    MNLogD(@"Initializing SDK");
    MNLogD(@"MNBaseAdSdk version - %@", [MNBase getBaseSdkVersionName]);

    [MNBaseAppCrashCatcher startAppCrashCatcher];

    [MNBaseDataPrivacy getSharedInstance];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [MNBaseHttpClient makeLatencyTestRequest];

    // TODO MNBase discuss
    [MNBaseAdDetailsStore initializeStore];

    [MNBaseSdkConfig initSdkConfig];

    [MNBase prefetchBids];

    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventSessionTime
                                   andCustomData:@{@"time" : [MNBaseUtil getTimestampInMillisStr]}];

    [MNBaseDiskLRUCache sharedLRUCache];

    [MNBaseAdViewStore getsharedInstance];

    if ([[self getInstance] appContainsChildDirectedContent] == NO) {
        [MNBaseLocationDataTracker startLocationUpdates];
        [MNBasePulseTracker logDeviceInfoAsync];
    }
}

+ (void)prefetchBids {
    MNBaseAdRequest *adRequest = [MNBaseAdRequest newRequest];

    MNBasePrefetchBids *prefetcher = [MNBasePrefetchBids getInstance];
    [prefetcher prefetchBidsForAdRequest:adRequest
                                  withCb:^(NSError *_Nullable prefetchErr) {
                                    if (prefetchErr != nil) {
                                        MNLogRemote(@"Initial Prefetch err - %@", prefetchErr);
                                    } else {
                                        MNLogD(@"Performed initial prefetch!");
                                    }
                                  }];
}

+ (void)setAdClickThroughVCNavColor:(UIColor *)bgColor {
    if (sInstance) {
        sInstance.clickThroughVCNavColor = bgColor;
    }
}

+ (void)isAdClickThroughVCIconsThemeLight:(BOOL)isIconsThemeLight {
    if (sInstance) {
        sInstance.clickThroughVCIconsThemeDark = isIconsThemeLight;
    }
}

#pragma mark - Foreground/Background methods

- (void)applicationHasEnteredForeground {
    MNLogD(@"Inside applicationHasEnteredForeground");

    // Make a request to the configuration
    MNBaseSdkConfig *configObj = [MNBaseSdkConfig getInstance];
    if (!configObj) {
        [MNBaseSdkConfig initSdkConfig];
    } else {
        [configObj updateConfig];
    }

    [MNBaseLocationDataTracker startLocationUpdates];

    // Check if the pulse requests are ready to send
    [[MNBasePulseHttp getSharedInstance] checkForBatchHttp];

    [MNBaseUtil loadCookiesFromUserDefaults];
}

- (void)applicationHasEnteredBackground {
    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventEnteredBackground andCustomData:@{}];
    [MNBaseLocationDataTracker stopLocationUpdates];

    [MNBaseUtil saveCookiesInUserDefaults];
}

#pragma marks - Getters and Setters

- (NSString *)customerId {
    NSString *defaultCustomerId = @"";
    return (_customerId) ? _customerId : defaultCustomerId;
}

- (void)setCustomerId:(NSString *)customerId {
    _customerId = customerId;
}

- (NSString *)sdkVersionName {
    return (_sdkVersionName == nil) ? @"" : _sdkVersionName;
}

- (void)setSdkVersionName:(NSString *)sdkVersionName {
    _sdkVersionName = sdkVersionName;
}

- (NSUInteger)sdkVersionNumber {
    return _sdkVersionNumber;
}

- (void)setSdkVersionNumber:(NSUInteger)sdkVersionNumber {
    _sdkVersionNumber = sdkVersionNumber;
}

- (void)dealloc {
    // Remove the foreground & background listener
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MNLogD(@"DEALLOC: MNBase");
}

@end
