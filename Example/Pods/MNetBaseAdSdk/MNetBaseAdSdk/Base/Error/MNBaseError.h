//
//  MNBaseError.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    // HTTP error code
    MNBaseErrCodeGeneric              = -1000,
    MNBaseErrCodeNoInternetConnection = -1001,
    MNBaseErrCodeInvalidRequest       = -1002,
    MNBaseErrCodeInvalidURL           = -1003,
    MNBaseErrCodeInvalidResponse      = -1004,

    // Ad loading error code
    MNBaseErrCodeInvalidAdUnitId       = -2000,
    MNBaseErrCodeAdLoadFailed          = -2001,
    MNBaseErrCodeInvalidAdRequest      = -2002,
    MNBaseErrCodeAdViewBusy            = -2203,
    MNBaseErrCodeInvalidAdSize         = -2004,
    MNBaseErrCodePrefetchLoadFailed    = -2005,
    MNBaseErrCodeInvalidAdType         = -2006,
    MNBaseErrCodeInvalidAdController   = -2007,
    MNBaseErrCodeRootViewControllerNil = -2008,
    MNBaseErrCodeInvalidAdCode         = -2009,
    MNBaseErrCodeInvalidAdUrl          = -2010,
    MNBaseErrCodeAdUrlRequestFailed    = -2011,
    MNBaseErrCodeYBNCATimeout          = -2012,

    // HB error code
    MNBaseErrCodeHBLoadFailed = -3000,
    // MRAID error code
    MNBaseErrCodeMRAID = -4000,
    // Video error code
    MNBaseErrCodeVideo = -5000,
    // Ad view reuse code
    MNBaseErrCodeAdViewReuse = -6000,
    // Adx error code
    MNBaseErrCodeAdxFailed = -7000,

    // Permission not available code
    MNBaseErrCodeCameraPermissionRestricted = -8000,
    MNBaseErrCodeCameraPermissionDenied     = -8001,

} MNBaseErrorCode;

/// The class that's the error type for ads.
@interface MNBaseError : NSObject

NS_ASSUME_NONNULL_BEGIN
/// Initialise MNBaseError with the NSError object
- (id)initWithError:(NSError *_Nullable)errorObj;

/// Initialise MNBaseError with the NSError object with the callstack
- (id)initWithError:(NSError *)errorObj withCallStack:(NSArray *_Nullable)callstack;

/// Initialise MNBaseError with a NSString
- (id)initWithStr:(NSString *)errorStr;

/// Initialise the MNBaseError with a NSString and callstack
- (id)initWithStr:(NSString *)errorStr withCallStack:(NSArray *_Nullable)callstack;

/// Returns the error description
- (NSString *)getErrorString;

/// Returns the error reason
- (NSString *)getErrorReasonString;

/// Get the Error object from MNBaseError
- (NSError *)getError;

/// Creates and returns an NSError object with the given description
+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr;

/// Creates and returns an NSError object with the given description
/// and failure reason.
+ (NSError *)createErrorWithDescription:(NSString *_Nullable)descriptionStr
                       AndFailureReason:(NSString *_Nullable)failureReasonStr;

/// Creates and returns an NSError object with the given description,
/// failure reason and the recoverySuggestion string.
+ (NSError *)createErrorWithDescription:(NSString *_Nullable)descriptionStr
                       AndFailureReason:(NSString *_Nullable)failureReasonStr
                  AndRecoverySuggestion:(NSString *_Nullable)recoverySuggestionStr;

//// Create and return an NSError object with the given Error code.
+ (NSError *)createErrorWithCode:(MNBaseErrorCode)errCode withFailureReason:(NSString *_Nullable)reason;

// Create and return an NSError object with the given Error code,
// description and failure reason.
+ (NSError *)createErrorWithCode:(MNBaseErrorCode)errCode
                errorDescription:(NSString *_Nullable)description
                andFailureReason:(NSString *_Nullable)reason;

NS_ASSUME_NONNULL_END
@end
