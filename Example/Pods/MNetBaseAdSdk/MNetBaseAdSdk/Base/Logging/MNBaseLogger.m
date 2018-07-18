//
//  MNBaseLogger.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//
#import "MNBaseLogger.h"
#import "MNBase.h"
#import "MNBaseConstants.h"
#import "MNBaseError.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

#define LOG_LEN_LIMIT 1000

#define PUBLIC_MODE_PREFIX @"[MNBaseAdSdk]:"
#define ERROR_MODE_PREFIX @"Error:"
#define REMOTE_MODE_PREFIX @"Remote:"

void mnetPrintFormatLog(NSString *logArg);

void mnetLogger(MNBaseLogLevel level, NSString *logArg) {
    if (logArg == nil) {
        return;
    }
    NSString *log = [logArg copy];

    BOOL isLogsEnabled = [[MNBase getInstance] isLogsEnabled];
    if (isLogsEnabled) {
        mnetPrintFormatLog(log);
    }

    switch (level) {
    case MNBaseLogLevelError: {
        MNBaseError *errObj = [[MNBaseError alloc] initWithStr:log];
        if (isLogsEnabled) {
            NSString *log = [NSString stringWithFormat:@"%@ %@", ERROR_MODE_PREFIX, errObj];
            mnetPrintFormatLog(log);
        }
        [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventError withMessage:log andCustomData:errObj];
        break;
    }
    case MNBaseLogLevelRemote: {
        MNBaseError *errObj = [[MNBaseError alloc] initWithStr:log];
        if (isLogsEnabled) {
            NSString *log = [NSString stringWithFormat:@"%@ %@", REMOTE_MODE_PREFIX, errObj];
            mnetPrintFormatLog(log);
        }
        [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventRemoteLog withMessage:log andCustomData:errObj];
        break;
    }
    case MNBaseLogLevelPublic: {
        NSLog(@"%@ %@", PUBLIC_MODE_PREFIX, log);
        break;
    }
    default: {
        // Pass
    }
    }
}

void mnetPrintFormatLog(NSString *logArg) {
    if (logArg == nil || [logArg length] == 0) {
        return;
    }
    NSUInteger strLen = [logArg length];
    NSUInteger range  = LOG_LEN_LIMIT;
    for (NSUInteger i = 0; i < strLen; i = i + range) {
        NSUInteger finalLen = range;
        if ((i + range) > strLen) {
            finalLen = strLen - i;
        }
        NSString *strSubset = [logArg substringWithRange:NSMakeRange(i, finalLen)];
        NSLog(@"MNAD: %@", strSubset);
    }
}
