//
//  MNBaseBidRequest.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseBidRequest.h"
#import "MNBase.h"
#import "MNBaseAdDetailsStore.h"
#import "MNBaseAdSize.h"
#import "MNBaseConstants.h"
#import "MNBaseDataPrivacy.h"
#import "MNBaseFingerprint.h"
#import "MNBaseLocationDataTracker.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUrl+Internal.h"

@implementation MNBaseBidRequest

@synthesize hostAppInfo   = _hostAppInfo;
@synthesize deviceInfo    = _deviceInfo;
@synthesize adImpressions = _adImpressions;

+ (MNBaseBidRequest *)create:(MNBaseAdRequest *)adRequest {
    return [[MNBaseBidRequest alloc] initWithAdRequest:adRequest];
}

#pragma mark - Init methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [self populateDefaultValues];
    }
    return self;
}

- (instancetype)initWithAdRequest:(MNBaseAdRequest *)adRequest {
    self = [self init];

    if (nil == self) {
        return self;
    }

    self.sdkVersionName = [[MNBase getInstance] sdkVersionName];
    self.sdkVersionCode = [NSNumber numberWithUnsignedInteger:[[MNBase getInstance] sdkVersionNumber]];

    BOOL isChildDirected = [[MNBase getInstance] appContainsChildDirectedContent];

    NSMutableArray<MNBaseImpFormat *> *impFormatArray = [[NSMutableArray alloc] init];
    for (MNBaseAdSize *adSize in [adRequest adSizes]) {
        MNBaseImpFormat *impFormat = [MNBaseImpFormat newInstance];
        impFormat.width            = adSize.w;
        impFormat.height           = adSize.h;
        [impFormatArray addObject:impFormat];
    }

    NSString *adUnitId = adRequest.adUnitId;

    self.viewControllerTitle = [adRequest viewControllerTitle];

    // adding impressions
    MNBaseAdImpression *adImpr = [MNBaseAdImpression newInstance];

    adImpr.adUnitId = adUnitId;
    adImpr.type     = (adRequest.isInterstitial) ? 1 : 0;
    adImpr.banner   = [[MNBaseBannerAdRequest alloc] init];

    BOOL isInappBrowsingEnabled  = [[MNBaseSdkConfig getInstance] isInappBrowsingEnabled];
    adImpr.clickThroughToBrowser = [NSNumber numberWithInt:(isInappBrowsingEnabled) ? 0 : 1];

    // NOTE: Set banner dimensions only if ad is not isInterstitial
    // Set to {} if isInterstitial, hence the initialization above
    if (NO == adRequest.isInterstitial) {
        [adImpr.banner setFormat:[impFormatArray copy]];
    }
    adImpr.isSecure = ([[MNBaseURL getSharedInstance] isHttpAllowed]) ? 0 : 1;

    // NOTE: These two types of objects have been added to impression as they do
    // contain some separate properties, so if in future we enable them then
    // we can independently handle that
    // currently it seems redundant but keeps future extensibility
    // checking for video capability
    if ([[self adCapability] video]) {
        // adding video impression
        adImpr.video = [[MNBaseVideoAdRequest alloc] init];
        if (NO == adRequest.isInterstitial) {
            [adImpr.video setFormat:[impFormatArray copy]];
        }
    }

    [self addImpressions:adImpr];

    NSString *extUrl;
    if (adRequest.contextLink != nil) {
        extUrl = adRequest.contextLink;
    }
    MNLogD(@"APP_CONTENT: Request with link - %@", extUrl);

    MNBaseHostAppInfo *hostAppInfo = [MNBaseHostAppInfo getAppHostInfoWithExtUrl:extUrl];
    if (adRequest.keywords && NO == [adRequest.keywords isEqualToString:@""]) {
        if (hostAppInfo.intentData != nil) {
            [hostAppInfo.intentData setKeywords:adRequest.keywords];
        }
    }
    [self setHostAppInfo:hostAppInfo];

    if (adRequest.customGeoLocation != nil) {
        self.deviceInfo.geoLocation = adRequest.customGeoLocation;
    }

    self.adCycleId = adRequest.adCycleId;

    // Setting ad details
    NSString *customerId               = [[MNBase getInstance] customerId];
    MNBaseAdDetailsStore *detailsStore = [MNBaseAdDetailsStore getSharedInstance];
    self.adDetails                     = [detailsStore getDetailsForAdunit:adUnitId andPubId:customerId];

    // Setting request regulations
    MNBaseRequestRegulation *requestRegulation = [[MNBaseRequestRegulation alloc] init];
    requestRegulation.isChildDirected          = [NSNumber numberWithInt:(isChildDirected) ? 1 : 0];
    self.requestRegulation                     = requestRegulation;

    if (isChildDirected == NO) {
        // Getting the user info from the request
        if (adRequest.userDetails != nil) {
            self.userDetails = adRequest.userDetails;
        }
    }

    // Setting the ext params
    self.ext = [MNBaseExtBidRequest createWithAdRequest:adRequest];
    return self;
}

#pragma mark - Init helpers

- (void)populateDefaultValues {
    BOOL isChildDirected = [[MNBase getInstance] appContainsChildDirectedContent];

    // Adding capabilities
    [self setAdCapability:[[MNBaseAdCapability alloc] init]];

    // Getting device info
    __block MNBaseDeviceInfo *deviceInfo;
    void (^deviceInfoBlock)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];

      // Update limited ad tracking flag
      [deviceInfo updateLimitedAdTracking];
      int gdpr = deviceInfo.doNotTrackForEurope ? 1 : 0;
      MNLogD(@"MNBase: gdpr value - %d", gdpr);
      self.gdpr = [NSNumber numberWithInt:gdpr];

      self.gdprstring = [[MNBaseDataPrivacy getSharedInstance] getConsentString];
      MNLogD(@"MNBase: gdpr string %@", self.gdprstring);

      int consent = [[MNBaseDataPrivacy getSharedInstance] checkIfConsentAvailable] ? 1 : 0;
      MNLogD(@"MNBase: gdpr consent %d", consent);
      self.gdprconsent = [NSNumber numberWithInt:consent];
    };

    // Need to always fetch from the main thread (Accesses UIKit)
    if (![NSThread isMainThread]) {
        // Block it
        dispatch_sync(dispatch_get_main_queue(), deviceInfoBlock);
    } else {
        deviceInfoBlock();
    }

    if (isChildDirected) {
        MNBaseGeoLocation *userGeo = [MNBaseLocationDataTracker getGeoLocation];
        if (userGeo) {
            deviceInfo.geoLocation = userGeo;
        }
    }
    [self setDeviceInfo:deviceInfo];

    // Fingerprint data
    NSString *uuid = [[MNBaseFingerprint getInstance] getUUID];
    if (uuid && ![uuid isEqualToString:@""]) {
        self.uuid = uuid;
    }

    // Setting test value
    if ([[MNBase getInstance] isTest]) {
        self.test = [NSNumber numberWithInt:1];
    }

    // VisitId
    self.visitId = [[MNBase getInstance] getVisitId];

    // Setting if bidder is prefetch-enabled to the default value
    self.prefetchEnabledBidder = [MNJMBoolean createWithBool:DEFAULT_IS_PREFETCH_ENABLED_BIDDER];
}

- (void)addImpressions:(MNBaseAdImpression *)impression {
    if (_adImpressions == nil) {
        _adImpressions = [[NSMutableArray alloc] init];
    }
    [_adImpressions addObject:impression];
}

#pragma mark - Property fetcher helpers

- (NSString *_Nullable)fetchAdUnitId {
    NSArray<MNBaseAdImpression *> *adImpList = self.adImpressions;
    if (adImpList && [adImpList count] > 0) {
        MNBaseAdImpression *adImp = [adImpList firstObject];
        if (adImp) {
            return adImp.adUnitId;
        }
    }

    return nil;
}

- (NSString *_Nullable)fetchPublisherId {
    MNBaseHostAppInfo *appInfo = self.hostAppInfo;
    if (appInfo) {
        MNBasePublisher *publisherInfo = appInfo.publisher;
        if (publisherInfo) {
            return publisherInfo.id;
        }
    }

    return nil;
}

- (NSString *_Nullable)fetchContextUrl {
    MNBaseHostAppInfo *appInfo = self.hostAppInfo;
    if (appInfo) {
        MNBaseIntentData *intentData = [appInfo intentData];
        if (intentData) {
            if ([intentData externalData]) {
                return [[intentData externalData] url];
            }
        }
    }

    return nil;
}

- (NSString *_Nullable)fetchKeywords {
    if (self.hostAppInfo != nil && self.hostAppInfo.intentData != nil) {
        return self.hostAppInfo.intentData.keywords;
    }
    return nil;
}

- (NSArray *)fetchAdSizes {
    if (self.adImpressions == nil || [self.adImpressions count] == 0) {
        return nil;
    }
    MNBaseAdImpression *impr = [self.adImpressions firstObject];
    NSArray<MNBaseImpFormat *> *formatList;
    if ([impr banner] != nil) {
        formatList = [[impr banner] format];
    } else if ([impr video] != nil) {
        formatList = [[impr video] format];
    }
    if (formatList == nil || [formatList count] == 0) {
        return nil;
    }
    NSMutableArray<MNBaseAdSize *> *adSizes = [NSMutableArray<MNBaseAdSize *> new];
    for (MNBaseImpFormat *format in formatList) {
        [adSizes addObject:MNBaseCreateAdSize([[format width] integerValue], [[format height] integerValue])];
    }
    if ([adSizes count] == 0) {
        return nil;
    }
    return adSizes;
}

#pragma mark - JSON mapper methods

- (NSDictionary *)propertyKeyMap {
    return @{
        @"hostAppInfo" : @"app",
        @"deviceInfo" : @"device",
        @"adImpressions" : @"imp",
        @"adCapability" : @"capabilities",
        @"adDetails" : @"adx_details",
        @"uuid" : @"uid",
        @"userDetails" : @"user",
        @"prefetchEnabledBidder" : @"prfo",
        @"viewControllerTitle" : @"activity_name",
        @"cachedBidInfoMap" : @"cbidinfo",
        @"requestRegulation" : @"regs",
        @"sdkVersionName" : @"external_ver_name",
        @"sdkVersionCode" : @"external_ver_code",
        @"gdpr" : @"gdpr",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"adImpressions" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseAdImpression class]],
        @"bidders" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseBidderInfo class]]
    };
}
@end
