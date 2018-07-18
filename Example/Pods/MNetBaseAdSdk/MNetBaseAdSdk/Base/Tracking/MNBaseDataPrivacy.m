//
//  MNBaseDataPrivacy.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 30/05/18.
//

#import "MNBaseDataPrivacy.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"

NSString *const kMNBaseIABConsentCMPPresentKey     = @"IABConsent_CMPPresent";
NSString *const kMNBaseIABConsentStringKey         = @"IABConsent_ConsentString";
NSString *const kMNBaseIABConsentSubjectToGDPRKey  = @"IABConsent_SubjectToGDPR";
NSString *const kMNBaseIABParsedVendorConsentsKey  = @"IABConsent_ParsedVendorConsents";
NSString *const kMNBaseIABParsedPurposeConsentsKey = @"IABConsent_ParsedPurposeConsents";

static MNBaseDataPrivacy *sInstance = nil;

@interface MNBaseDataPrivacy ()

@property (atomic) NSString *consentStr;

@property (atomic) NSInteger consentStatus;

@property (atomic) NSUInteger subjectToGdpr;
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

    MNLogD(@"MNet consent string %@", consentString);
    MNLogD(@"MNet consent status %ld", (long) status);
    MNLogD(@"MNet subject to gdpr %ld", (long) gdpr);

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

- (BOOL)checkIfConsentAvailable {
    return self.consentStatus == MNBaseGdprConsentStatusGiven;
}

- (BOOL)isSubjectToGdpr {
    return self.subjectToGdpr == MNBaseSubjectToGdprEnabled;
}

- (BOOL)doNoTrack {
    return [self isSubjectToGdpr] && ![self checkIfConsentAvailable];
}

@end
