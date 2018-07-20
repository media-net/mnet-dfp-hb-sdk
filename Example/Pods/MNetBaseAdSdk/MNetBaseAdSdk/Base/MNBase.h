//
//  MNBase.h
//  MNetBaseAdSdk
//
//  Created by kunal.ch on 04/07/18.
//

#import "MNBaseUser.h"
#import <Foundation/Foundation.h>

@interface MNBase : NSObject

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Properties
/// The customer Id of the MNBaseAdSdk
@property (atomic) NSString *customerId;

/// Setting this parameter will send the test requests to the servers.
/// It can be used for testing purposes.
@property (atomic) BOOL isTest;

@property (atomic, nullable) MNBaseUser *user;

@property UIColor *clickThroughVCNavColor;

@property BOOL clickThroughVCIconsThemeDark;

@property BOOL appContainsChildDirectedContent;

@property BOOL isLogsEnabled;

/// Setting a custom bundle-id. This will not be necessary other than testing purposes.
@property (atomic, nullable) NSString *customBundleId;

/// Wrapper SDK version name
@property (atomic) NSString *sdkVersionName;

/// Wrapper SDK version number
@property (atomic) NSUInteger sdkVersionNumber;

#pragma mark - Methods

/// Initialises the MNBaseAdSdk for a given customer Id along with
/// specifying if the app contains child directed content. It defaults to NO
/// sdkVersionName is the version name of the parent SDK.
/// sdkVersionNumber is the version number of the parent SDK.
+ (instancetype)initWithCustomerId:(NSString *)customerId
    appContainsChildDirectedContent:(BOOL)containsChildDirectedContent
                     sdkVersionName:(NSString *)sdkVersionName
                   sdkVersionNumber:(NSUInteger)sdkVersionNumber;

/// Logs all MNBase ad related logs.
/// It is NO by default.
/// *** Do NOT enable logs in production apps ***
+ (void)enableLogs:(BOOL)enabled;

/// The current instance of MNBase
+ (MNBase *)getInstance;

/// This color is set to the top bar, on the webview ViewController
/// that's displayed when clickThrough occurs.
/// This is purely optional, and is for customization purposes only.
+ (void)setAdClickThroughVCNavColor:(UIColor *_Nullable)bgColor;

/// Manually set the GDPR consent string, consent status and subject to GDPR.
/// Consent status 0 means consent UNKNOWN, 1 means consent GIVEN, 2 means consent REVOKED
/// Subject to GDPR -1 means UNKNOWN, 0 means NOT Subject to GDPR, 1 means Subject to GDPR
+ (void)updateGdprConsentString:(NSString *_Nonnull)consentString
                  consentStatus:(NSInteger)status
                  subjectToGdpr:(NSInteger)gdpr;

- (NSString *)getVisitId;

/// Get the current base sdk version name
+ (NSString *)getBaseSdkVersionName;

/// Get the current base sdk version code
+ (NSUInteger)getBaseSdkVersionCode;

/// Get status if the app is initialized
+ (BOOL)isInitialized;

- (instancetype)init __attribute__((unavailable("Please use +initWithCustomerId:")));

NS_ASSUME_NONNULL_END
@end
