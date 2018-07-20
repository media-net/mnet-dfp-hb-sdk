//
//  MNBaseDataPrivacy.h
//  MNBaseAdSdk
//
//  Created by kunal.ch on 30/05/18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNBaseGdprConsentStatus) {
    MNBaseGdprConsentStatusUnknown = 0,
    MNBaseGdprConsentStatusGiven   = 1,
    MNBaseGdprConsentStatusRevoked = 2,
};

typedef NS_ENUM(NSInteger, MNBaseSubjectToGdpr) {
    MNBaseSubjectoToGdprUnknown = -1,
    MNBaseSubjectToGdprDisabled = 0,
    MNBaseSubjectToGdprEnabled  = 1,
};

@interface MNBaseDataPrivacy : NSObject

+ (instancetype)getSharedInstance;

/// Returns consent string. Return empty string if none is available.
- (NSString *)getConsentString;

/// Returns if gdpr-consent is given
- (BOOL)isGdprConsentGiven;

/// Returns if subject to gdpr
- (BOOL)isSubjectToGdpr;

/// Returns if app contains child-directed content
- (BOOL)doesAppContainChildDirectedContent;

/// Returns if limited ad-tracking is enabled
- (BOOL)isAdTrackingEnabled;

- (BOOL)isGdprEnabled;

/// Returns YES if any of
/// - subject to gdpr is enabled & gdpr consent is not available
/// - App contains child-directed content
/// - Limited ad-tracking is enabled
- (BOOL)doNoTrack;

- (void)manuallyUpdateGdprConsentString:(NSString *)consentString
                          consentStatus:(MNBaseGdprConsentStatus)status
                          subjectToGdpr:(MNBaseSubjectToGdpr)gdpr;
@end
