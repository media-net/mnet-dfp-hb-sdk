//
//  MNBaseWeakTimerTarget.m
//  Pods
//
//  Created by nithin.g on 04/04/17.
//
//

#import "MNBaseWeakTimerTarget.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

/*
 This weak timer logic is similar to how it's mentioned here - http://stackoverflow.com/a/16822471/1518924 (amazing
 answer :) NOTE: Using callbacks here instead of selectors is not same. It RETAINS the callback! If you need to
 implement callbacks(i.e blocks) for the timer, make sure you test it for leaks first. Else, Make the callback as a
 class property and then use it carefully.
 */
@interface MNBaseWeakTimerTarget ()
@property (atomic, readwrite) SEL timerFireTargetSelector;
@end

@implementation MNBaseWeakTimerTarget

- (id)init {
    self                         = [super init];
    self.timerFireTargetSelector = NSSelectorFromString(@"timerDidFire:");

    return self;
}

- (void)timerDidFire:(NSTimer *)timer {
    if (self.target) {
        [MNBaseUtil customPerformSelector:self.selector forTarget:self.target withArg:timer];
    } else {
        [timer invalidate];
        timer = nil;
    }
}

- (void)dealloc {
    MNLogD(@"DEALLOC: Called for MNWeakTimerTarget");
}
@end
