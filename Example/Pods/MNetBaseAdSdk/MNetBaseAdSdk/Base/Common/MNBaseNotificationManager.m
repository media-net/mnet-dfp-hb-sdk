//
//  MNBaseNotificationNames.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 04/01/18.
//

#import "MNBaseNotificationManager.h"

NSString *const MNBaseNotificationSdkConfigUpdated = @"MNBaseNotificationSdkConfigUpdated";

@implementation MNBaseNotificationManager

+ (BOOL)postNotificationWithName:(NSString *_Nonnull)notificationName {
    if (notificationName == nil) {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    return YES;
}

+ (id _Nullable)addObserverToNotification:(NSString *_Nonnull)notificationName
                                withBlock:(void (^_Nonnull)(NSNotification *_Nonnull))notifyBlock {
    if (notificationName == nil || notifyBlock == nil) {
        return nil;
    }
    // Always send to the main-queue
    return [[NSNotificationCenter defaultCenter] addObserverForName:notificationName
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:notifyBlock];
}

+ (BOOL)removeObserver:(id _Nonnull)observer withName:(NSString *_Nonnull)notificationName {
    if (observer == nil || notificationName == nil) {
        return NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:notificationName object:nil];
    return YES;
}

@end
