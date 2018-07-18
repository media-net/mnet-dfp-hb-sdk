//
//  MNBaseSdkConfigRefresher.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 05/03/18.
//

#import "MNBaseSdkConfigRefresher.h"
#import "MNBaseNotificationManager.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseWeakTimerTarget.h"

@interface MNBaseSdkConfigRefresher ()
@property (atomic) id sdkConfigNotificationObj;
@property (atomic) NSTimer *timerObj;
@end

@implementation MNBaseSdkConfigRefresher

+ (void)load {
    [MNBaseSdkConfigRefresher getSharedInstance];
}

static MNBaseSdkConfigRefresher *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [MNBaseSdkConfigRefresher new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak MNBaseSdkConfigRefresher *weakSelf = self;
        _sdkConfigNotificationObj =
            [MNBaseNotificationManager addObserverToNotification:MNBaseNotificationSdkConfigUpdated
                                                       withBlock:^(NSNotification *_Nonnull notificationObj) {
                                                         MNBaseSdkConfigRefresher *strongSelf = weakSelf;
                                                         if (strongSelf != nil) {
                                                             [strongSelf startRefreshingConfig];
                                                         }
                                                       }];
    }
    return self;
}

- (void)startRefreshingConfig {
    // Killing an old timer to ensure that frequent requests are not made
    if (self.timerObj != nil) {
        [self.timerObj invalidate];
        self.timerObj = nil;
    }

    // Start a timer to start the refresh process
    MNBaseWeakTimerTarget *timerTarget = [[MNBaseWeakTimerTarget alloc] init];
    [timerTarget setTarget:self];

    [timerTarget setSelector:NSSelectorFromString(@"timerCallback:")];
    NSNumber *configRefreshInterval = [[MNBaseSdkConfig getInstance] getConfigRefreshIntervalInSeconds];
    NSInteger refreshIntervalInSecs = [configRefreshInterval integerValue];

    self.timerObj = [NSTimer scheduledTimerWithTimeInterval:refreshIntervalInSecs
                                                     target:timerTarget
                                                   selector:timerTarget.timerFireTargetSelector
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)timerCallback:(NSTimer *)timer {
    if (self.timerObj != nil) {
        [self.timerObj invalidate];
        self.timerObj = nil;
    }
    // Update the sdk-config
    [[MNBaseSdkConfig getInstance] updateConfig];
}

- (void)dealloc {
    if (self.sdkConfigNotificationObj != nil) {
        [MNBaseNotificationManager removeObserver:self.sdkConfigNotificationObj
                                         withName:MNBaseNotificationSdkConfigUpdated];
    }
}

@end
