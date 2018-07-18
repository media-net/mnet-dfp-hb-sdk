//
//  MNBaseAppCrashCatcher.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 07/02/18.
//

#import "MNBaseAppCrashCatcher.h"
#import "MNBaseError.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"

@implementation MNBaseAppCrashCatcher

void MNBaseHandleCrashException(NSException *exception) {
    MNLogD(@"MNBase Crash Exception : %@", [exception reason]);
    MNLogD(@"MNBase Crash Symbols : %@", [exception callStackSymbols]);
    NSString *logStr      = [NSString stringWithFormat:@"APP CRASHED WITH ERROR : %@", [exception reason]];
    MNBaseError *crashErr = [[MNBaseError alloc] initWithStr:logStr withCallStack:[exception callStackSymbols]];
    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventError withMessage:logStr andCustomData:crashErr];
}

void MNBaseHandleCrashSignal(int signal) {
    MNLogD(@"MNBase Crash Signal : %d", signal);
    NSString *logStr      = [NSString stringWithFormat:@"APP CRASHED WITH SIGNAL : %d", signal];
    MNBaseError *crashErr = [[MNBaseError alloc] initWithStr:logStr withCallStack:nil];
    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventError andCustomData:crashErr];
}

+ (void)startAppCrashCatcher {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [self startListeningToCrash];
    });
}

+ (void)startListeningToCrash {
    NSSetUncaughtExceptionHandler(&MNBaseHandleCrashException);
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &MNBaseHandleCrashSignal;
    /* abort() */
    sigaction(SIGABRT, &signalAction, NULL);
    /* illegal instruction (not reset when caught) */
    sigaction(SIGILL, &signalAction, NULL);
    /* bus error */
    sigaction(SIGBUS, &signalAction, NULL);
    /* segmentation violation */
    sigaction(SIGSEGV, &signalAction, NULL);
    /* floating point exception */
    sigaction(SIGFPE, &signalAction, NULL);
}
@end
