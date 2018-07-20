//
//  MNBaseDataPrivacy.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 30/05/18.
//

#import "MNBaseDataPrivacy.h"
#import "MNBase.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import <AdSupport/ASIdentifierManager.h>

static MNBaseDataPrivacy *sInstance = nil;

@interface MNBaseDataPrivacy ()

@property (atomic) NSString *consentStr;

@property (atomic) NSInteger consentStatus;

@property (atomic) NSInteger subjectToGdpr;
@end

@implementation MNBaseDataPrivacy

+ (void)initDataPrivacy {
    [self getSharedInstance];
}

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sInstance = [[self alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _consentStr    = @"";
        _consentStatus = MNBaseGdprConsentStatusUnknown;
        _subjectToGdpr = MNBaseSubjectoToGdprUnknown;
    }
    return self;
}

- (void)manuallyUpdateGdprConsentString:(NSString *)consentString
                          consentStatus:(MNBaseGdprConsentStatus)status
                          subjectToGdpr:(MNBaseSubjectToGdpr)gdpr {

    MNLogD(@"GDPR: MANUAL: MNet consent string %@", consentString);
    MNLogD(@"GDPR: MANUAL: MNet consent status %ld", (long) status);
    MNLogD(@"GDPR: MANUAL: MNet subject to gdpr %ld", (long) gdpr);

    self.consentStatus = status;
    self.subjectToGdpr = gdpr;

    if (consentString == nil) {
        MNLogPublic(@"Warning: Nil gdpr consent string");
        self.consentStr = @"";
    } else {
        self.consentStr = consentString;
    }
}

- (NSString *)getConsentString {
    if (self.consentStr == nil) {
        return @"";
    }
    return self.consentStr;
}

- (BOOL)isGdprConsentGiven {
    return self.consentStatus == MNBaseGdprConsentStatusGiven;
}

- (BOOL)isSubjectToGdpr {
    return self.subjectToGdpr != MNBaseSubjectToGdprDisabled;
}

- (BOOL)doesAppContainChildDirectedContent {
    // If the base is not initialized, then child-directed-content is set to NO
    return [MNBase isInitialized] && [[MNBase getInstance] appContainsChildDirectedContent];
}

- (BOOL)isAdTrackingEnabled {
    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

- (BOOL)isGdprEnabled {
    return ([self isSubjectToGdpr] && NO == [self isGdprConsentGiven]);
}

/// Returns YES if any of
/// - subject to gdpr is enabled & gdpr consent is not available
/// - App contains child-directed content
/// - Limited ad-tracking is enabled
- (BOOL)doNoTrack {
    return ([self isGdprEnabled] || [self doesAppContainChildDirectedContent] || NO == [self isAdTrackingEnabled]);
}

@end
