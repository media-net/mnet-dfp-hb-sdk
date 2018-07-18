//
//  MNBaseBlockTimerManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 03/11/17.
//

#import "MNBaseBlockTimerManager.h"
#import "MNBaseLogger.h"

@interface MNBaseBlockTimerManager ()
@property (atomic) NSTimer *blockTimer;
@end

@implementation MNBaseBlockTimerManager

+ (instancetype)getInstanceWithTimeoutInMillis:(double)timeoutInMillis block:(void (^)(void))block {
    __block MNBaseBlockTimerManager *instance = [[self alloc] init];

    NSTimeInterval delay = (timeoutInMillis / 1000.0f);
    MNLogD(@"Adding time delay as %f", delay);

    NSBlockOperation *timeoutCalledBlock = [NSBlockOperation blockOperationWithBlock:^{
      MNLogD(@"Timeout handler called");
      @synchronized(instance) {
          if ([instance shouldCancelExecution]) {
              MNLogD(@"Cancelling execution");
              return;
          }
      }
      [instance setDidTimeoutHandlerCall:YES];

      MNLogD(@"Calling the timeout handler");
      block();
      [instance setBlockTimer:nil];
    }];

    void (^scheduleTimerOnMainThread)(void) = ^{
      NSTimer *timerObj = [NSTimer scheduledTimerWithTimeInterval:delay
                                                           target:timeoutCalledBlock
                                                         selector:@selector(main)
                                                         userInfo:nil
                                                          repeats:NO];
      [instance setBlockTimer:timerObj];
    };

    if ([NSThread isMainThread]) {
        scheduleTimerOnMainThread();
    } else {
        dispatch_sync(dispatch_get_main_queue(), scheduleTimerOnMainThread);
    }
    return instance;
}

- (void)cancel {
    if (self.blockTimer) {
        [[self blockTimer] invalidate];
        self.blockTimer = nil;
    }
}

@end
