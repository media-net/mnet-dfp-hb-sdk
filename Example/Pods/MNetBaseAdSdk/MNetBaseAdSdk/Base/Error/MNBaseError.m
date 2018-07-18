//
//  MNBaseError.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBase.h"
#import "MNBaseDeviceInfo.h"
#import "MNBaseError+Internal.h"
#import "MNBaseErrorStackTraceEvent.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"
#import <MNetJSONModeller/MNJMManager.h>

#define MNLocalizeString(key) [NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]
#define MNETErrorDomain @"MNBaseErrorDomain"
#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@interface MNBaseError () <MNJMMapperProtocol>

@property (atomic) NSError *__errorObj;
@property (atomic) NSArray *__callstack;

@property (atomic) NSString *localizedDescription;
@property (atomic) NSString *failureReason;
@property (atomic) NSString *recoverySuggestion;
@property (atomic) MNBaseDeviceInfo *deviceInfoVal;

@property (atomic) NSArray<NSString *> *rawCallstack;
@property (atomic) NSArray<MNBaseErrorStackTraceEvent *> *formattedCallstack;

@property (atomic) NSString *versionCode;
@property (atomic) NSString *versionName;
@property (atomic) NSString *internalVersionCode;
@property (atomic) NSString *internalVersionName;
@property (atomic) NSString *packageName;
@property (atomic) NSString *releaseStage;
@property (atomic) NSString *errMsg;

@end

@implementation MNBaseError

static MNBaseDeviceInfo *deviceInfo;

+ (void)initialize {
    void (^deviceInfoBlock)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];
    };

    // Need to always fetch from the main thread (Accesses UIKit)
    if (![NSThread isMainThread]) {
        // Block it
        dispatch_sync(dispatch_get_main_queue(), deviceInfoBlock);
    } else {
        deviceInfoBlock();
    }
}

- (id)initWithError:(NSError *)errorObj withCallStack:(NSArray *)callstack {
    self = [super init];

    self.__errorObj           = errorObj;
    self.localizedDescription = [self.__errorObj localizedDescription];
    self.failureReason        = [self.__errorObj localizedFailureReason];
    self.recoverySuggestion   = [self.__errorObj localizedRecoverySuggestion];
    self.deviceInfoVal        = deviceInfo;

    if (!callstack) {
        // Figure out the
        callstack = [NSThread callStackSymbols];
    }
    self.__callstack  = callstack;
    self.rawCallstack = self.__callstack;

    // Formatting the callstack
    NSMutableArray *formattedCallstack = [@[] mutableCopy];
    for (NSString *csEvent in self.__callstack) {
        [formattedCallstack addObject:[MNBaseErrorStackTraceEvent createInstanceWithEvent:csEvent]];
    }
    self.formattedCallstack = formattedCallstack;

    // Setting the default values
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSString *versionName = [[MNBase getInstance] sdkVersionName];
    NSNumber *versionCode = [NSNumber numberWithUnsignedInteger:[[MNBase getInstance] sdkVersionNumber]];

    self.versionCode         = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionName         = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.internalVersionCode = [versionCode stringValue];
    self.internalVersionName = versionName;
    self.packageName         = [MNBaseUtil getMainPackageName];
#ifdef DEBUG
    self.releaseStage = @"development";
#else
#ifdef TEST_RELEASE
    self.releaseStage = @"test_release";
#else
    self.releaseStage = @"production";
#endif
#endif
    NSString *message = self.localizedDescription;
    if (message == nil || [message isEqualToString:@""]) {
        message = self.failureReason;
    }
    if (message == nil) {
        message = @"";
    }
    self.errMsg = message;
    return self;
}

- (id)initWithStr:(NSString *)errorStr withCallStack:(NSArray *)callstack {
    return [self initWithError:[[self class] createErrorWithDescription:errorStr] withCallStack:callstack];
}

- (id)initWithError:(NSError *)errorObj {
    return [self initWithError:errorObj withCallStack:nil];
}

- (id)initWithStr:(NSString *)errorStr {
    return [self initWithError:[[self class] createErrorWithDescription:errorStr]];
}

- (NSString *)getErrorString {
    NSString *errStr;
    if ([self.__errorObj userInfo] && [[self.__errorObj userInfo] objectForKey:NSLocalizedDescriptionKey]) {
        errStr = [[self.__errorObj userInfo] objectForKey:NSLocalizedDescriptionKey];
    } else if (_localizedDescription && ![_localizedDescription isEqualToString:@""]) {
        errStr = _localizedDescription;
    } else {
        errStr = @"Generic error. No more information available.";
    }

    return errStr;
}

- (NSString *)getErrorReasonString {
    NSString *errReasonStr;
    if ([self.__errorObj userInfo] && [[self.__errorObj userInfo] objectForKey:NSLocalizedFailureReasonErrorKey]) {
        errReasonStr = [[self.__errorObj userInfo] objectForKey:NSLocalizedFailureReasonErrorKey];
    } else if (_failureReason && ![_failureReason isEqualToString:@""]) {
        errReasonStr = _failureReason;
    } else {
        errReasonStr = @"Generic error. No more information available.";
    }
    return errReasonStr;
}

- (NSError *)getError {
    return self.__errorObj;
}

+ (NSError *)createErrorWithCode:(MNBaseErrorCode)errCode withFailureReason:(NSString *)reason {
    return [self createErrorWithCode:errCode errorDescription:nil andFailureReason:reason];
}

+ (NSError *)createErrorWithCode:(MNBaseErrorCode)errCode
                errorDescription:(NSString *)description
                andFailureReason:(NSString *)reason {
    if (description == nil) {
        description = [self getErrDescriptionForCode:errCode];
    }
    NSString *errDescription = description;
    if (errDescription == nil) {
        errDescription = @"";
    }

    NSString *errReason = reason;
    if (errReason == nil) {
        errReason = errDescription;
    }
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : errDescription,
        NSLocalizedFailureReasonErrorKey : errReason,
    };
    return [NSError errorWithDomain:MNETErrorDomain code:errCode userInfo:userInfo];
}

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr {
    return [[self class] createErrorWithDescription:descriptionStr AndFailureReason:nil];
}

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr AndFailureReason:(NSString *)failureReasonStr {
    return [[self class] createErrorWithDescription:descriptionStr
                                   AndFailureReason:failureReasonStr
                              AndRecoverySuggestion:nil];
}

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr
                       AndFailureReason:(NSString *)failureReasonStr
                  AndRecoverySuggestion:(NSString *)recoverySuggestionStr {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : MNLocalizeString(descriptionStr),
        NSLocalizedFailureReasonErrorKey : MNLocalizeString((failureReasonStr) ? failureReasonStr : descriptionStr),
        NSLocalizedRecoverySuggestionErrorKey : MNLocalizeString((recoverySuggestionStr) ? recoverySuggestionStr : @""),
    };

    return [NSError errorWithDomain:MNETErrorDomain code:MNBaseErrCodeGeneric userInfo:userInfo];
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"localizedDescription" : @"message",
        @"rawCallstack" : @"raw_stacktrace",
        @"formattedCallstack" : @"stacktrace",
        @"deviceInfoVal" : @"device_info",
        @"errMsg" : @"error",
    };
}

+ (NSString *)getErrDescriptionForCode:(MNBaseErrorCode)errCode {
    NSDictionary *errDescriptionDict = [self getErrDescriptionsDict];
    return [errDescriptionDict objectForKey:ENUM_VAL(errCode)];
}

+ (NSDictionary *)getErrDescriptionsDict {
    NSDictionary *descriptionDict = @{
        ENUM_VAL(MNBaseErrCodeGeneric) : @"Generic Error code",
        ENUM_VAL(MNBaseErrCodeNoInternetConnection) : @"Please check your internet connection",
        ENUM_VAL(MNBaseErrCodeAdLoadFailed) : @"Ad failed to load",
        ENUM_VAL(MNBaseErrCodeInvalidURL) : @"Invalid url",
        ENUM_VAL(MNBaseErrCodeInvalidRequest) : @"Invalid Request",
        ENUM_VAL(MNBaseErrCodeInvalidResponse) : @"Invalid Response",
        ENUM_VAL(MNBaseErrCodeInvalidAdUnitId) : @"Invalid Ad unit id",
        ENUM_VAL(MNBaseErrCodeInvalidAdRequest) : @"Invalid Ad request",
        ENUM_VAL(MNBaseErrCodeAdViewBusy) : @"View is already performing ad load",
        ENUM_VAL(MNBaseErrCodeInvalidAdSize) : @"Invalid ad size 0x0",
        ENUM_VAL(MNBaseErrCodePrefetchLoadFailed) : @"Prefetch failed",
        ENUM_VAL(MNBaseErrCodeInvalidAdType) : @"Invalid ad type",
        ENUM_VAL(MNBaseErrCodeInvalidAdController) : @"Invalid Ad controller",
        ENUM_VAL(MNBaseErrCodeRootViewControllerNil) : @"Root view controller is nil",
        ENUM_VAL(MNBaseErrCodeInvalidAdCode) : @"Invalid ad code",
        ENUM_VAL(MNBaseErrCodeHBLoadFailed) : @"HB failed",
        ENUM_VAL(MNBaseErrCodeMRAID) : @"MRAID failed",
        ENUM_VAL(MNBaseErrCodeVideo) : @"Video failed",
        ENUM_VAL(MNBaseErrCodeAdViewReuse) : @"Cannot fetch ad view for resue",
    };
    return descriptionDict;
}

- (NSString *)description {
    NSString *errStr = [self getErrorString];
    if (errStr == nil || [errStr isEqualToString:@""]) {
        errStr = @"No description available";
    }
    NSString *errReason = [self getErrorReasonString];
    if (errReason == nil || [errReason isEqualToString:@""]) {
        errReason = @"No reason available";
    }
    NSString *err = [NSString stringWithFormat:@"Error - %@, Reason - %@", errStr, errReason];
    return err;
}
@end
