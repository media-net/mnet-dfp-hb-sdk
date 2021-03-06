//
//  MNetDfpHb.h
//  MNetDfpHbSdk
//
//  Created by nithin.g on 09/07/18.
//

#import <Foundation/Foundation.h>

@interface MNetDfpHb : NSObject

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MNetDfpHbGdprConsentStatus) {
    MNetDfpHbGdprConsentStatusRevoked = 0, // Not consented
    MNetDfpHbGdprConsentStatusGiven   = 1, // Consented
    MNetDfpHbGdprConsentStatusUnknown = 2, // Consent is UNKNOWN
};

typedef NS_ENUM(NSInteger, MNetDfpHbSubjectToGdpr) {
    MNetDfpHbSubjectToGdprDisabled = 0, // GDPR not applicable
    MNetDfpHbSubjectToGdprEnabled  = 1, // GDPR applicable
    MNetDfpHbSubjectoToGdprUnknown = 2, // GDPR applicability is UNKNOWN
};

- (instancetype)init __attribute__((unavailable("Please use +initWithCustomerId:")));

/// Initialises the MNetAdSdk for a given customer Id.
/// This can be run only once in a session.
/// NOTE: Use the other intializer `initWithCustomerId:appContainsChildDirectedContent`
/// to specify if the app contains child directed content.
/// It defaults to NO in this call.
+ (instancetype)initWithCustomerId:(NSString *)customerId;

/// Initialises the MNetAdSdk for a given customer Id along with
/// specifying if the app contains child directed content.
+ (instancetype)initWithCustomerId:(NSString *)customerId
    appContainsChildDirectedContent:(BOOL)containsChildDirectedContent;

/// The current instance of MNet
+ (instancetype)getInstance;

/// The customer Id of the MNetAdSdk
+ (NSString *_Nullable)getCustomerId;

/// Logs all MNet ad related logs.
/// It is NO by default.
/// *** Do NOT enable logs in production apps ***
+ (void)enableLogs:(BOOL)enabled;

/// Call this method to set the consent for Media.Net.
/// Parameters -
/// ConsentString - NSString representing the consent string
/// ConsentStatus - An enum to specify the consent status.
///                 Enum options -
///                 MNetDfpHbGdprConsentStatusUnknown // Consent is UNKNOWN
///                 MNetDfpHbGdprConsentStatusGiven   // Consented
///                 MNetDfpHbGdprConsentStatusRevoked // Not consented
/// SubjectToGdpr - An enum to specify if subject to GDPR
///                 Enum options -
///                 MNetDfpHbSubjectoToGdprUnknown // GDPR applicability is UNKNOWN
///                 MNetDfpHbSubjectToGdprDisabled // GDPR not applicable
///                 MNetDfpHbSubjectToGdprEnabled  // GDPR applicable
+ (void)updateGdprConsentString:(NSString *)consentString
                  consentStatus:(MNetDfpHbGdprConsentStatus)status
                  subjectToGdpr:(MNetDfpHbSubjectToGdpr)subjectToGdpr;
NS_ASSUME_NONNULL_END
@end
