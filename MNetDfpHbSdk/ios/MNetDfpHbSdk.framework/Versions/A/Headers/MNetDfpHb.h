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
    MNetDfpHbGdprConsentStatusUnknown = 0, // Consent is UNKNOWN
    MNetDfpHbGdprConsentStatusGiven   = 1, // Consented
    MNetDfpHbGdprConsentStatusRevoked = 2, // Not consented
};

typedef NS_ENUM(NSInteger, MNetDfpHbSubjectToGdpr) {
    MNetDfpHbSubjectoToGdprUnknown = -1, // GDPR applicability is UNKNOWN
    MNetDfpHbSubjectToGdprDisabled = 0,  // GDPR not applicable
    MNetDfpHbSubjectToGdprEnabled  = 1,  // GDPR applicable
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
/// Provide the consentString.
/// Choose one of the available values for consentStatus and subjectToGdpr.
+ (void)updateGdprConsentString:(NSString *)consentString
                  consentStatus:(MNetDfpHbGdprConsentStatus)status
                  subjectToGdpr:(MNetDfpHbSubjectToGdpr)subjectToGdpr;
NS_ASSUME_NONNULL_END
@end
