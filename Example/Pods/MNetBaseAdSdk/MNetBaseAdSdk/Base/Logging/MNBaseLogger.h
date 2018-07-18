//
//  MNBaseMNBaseLogger.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//  MNLog<CHAR> CHAR decides the type of log
//

#import <Foundation/Foundation.h>

typedef enum {
    MNBaseLogLevelDebug,
    MNBaseLogLevelError,
    MNBaseLogLevelPublic,
    MNBaseLogLevelRemote,
} MNBaseLogLevel;

void mnetLogger(MNBaseLogLevel level, NSString *log);

/// Prints log. Is unavailable in RELEASE mode
#define MNLogD(format_string, ...)                                                                                     \
    ((mnetLogger(MNBaseLogLevelDebug, [NSString stringWithFormat:format_string, ##__VA_ARGS__])))

/// Sends the log as an error-type event to pulse. The error is visible in console when logs are enabled.
#define MNLogE(format_string, ...)                                                                                     \
    ((mnetLogger(MNBaseLogLevelError, [NSString stringWithFormat:format_string, ##__VA_ARGS__])))

/// Sends the log as a remote_log event to pulse. These will be visible in console when logs are enabled.
#define MNLogRemote(format_string, ...)                                                                                \
    ((mnetLogger(MNBaseLogLevelRemote, [NSString stringWithFormat:format_string, ##__VA_ARGS__])))

/// Prints the log on the console. This is visible in all configurations, including RELEASE
#define MNLogPublic(format_string, ...)                                                                                \
    ((mnetLogger(MNBaseLogLevelPublic, [NSString stringWithFormat:format_string, ##__VA_ARGS__])))
