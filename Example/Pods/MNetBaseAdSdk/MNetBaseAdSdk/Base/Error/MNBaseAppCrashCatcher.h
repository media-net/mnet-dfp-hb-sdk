//
//  MNBaseAppCrashCatcher.h
//  MNBaseAdSdk
//
//  Created by kunal.ch on 07/02/18.
//

#import <Foundation/Foundation.h>

@interface MNBaseAppCrashCatcher : NSObject
- (instancetype)init __attribute__((unavailable("Please use +initAppCrashCatcher")));
+ (void)startAppCrashCatcher;
@end
