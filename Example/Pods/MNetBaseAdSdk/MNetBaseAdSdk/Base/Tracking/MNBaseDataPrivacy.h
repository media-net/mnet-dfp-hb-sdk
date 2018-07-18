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
// Methods
+ (void)initDataPrivacy;
+ (instancetype)getSharedInstance;
// Returns consent string
- (NSString *)getConsentString;
// Returns YES or NO based on avialable consent
- (BOOL)checkIfConsentAvailable;
// Returns YES or NO based on data tracking enabled
- (BOOL)doNoTrack;
- (void)manuallyUpdateGdprConsentString:(NSString *)consentString
                          consentStatus:(MNBaseGdprConsentStatus)status
                          subjectToGdpr:(MNBaseSubjectToGdpr)gdpr;
@end
