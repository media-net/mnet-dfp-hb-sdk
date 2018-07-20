//
//  UIViewController+MNBaseVCSwizzler.m
//  Pods
//
//  Created by nithin.g on 19/09/17.
//
//

#import "MNBaseLogger.h"
#import "MNBaseNotificationManager.h"
#import "MNBasePrefetchBids.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import "UIViewController+MNBaseVCSwizzler.h"
#import <MNALAppLink/MNALAppLink.h>

static NSString *mnetSwizzlerPrefix = @"mnad_swizzled_";

@implementation UIViewController (MNBaseVCSwizzler)

/*
 NOTE: These are not instance-variables. They don't need to be, since this is just for an instance.
 Not using properties explicitly. It can be set/get associative-objects on this category, but that introduces
 runtime cleverness that is not required for now.
 Just using plain global vars.
 */
BOOL isAlreadySwizzled;
NSArray *selectorsToSwizzle;
MNBaseNotificationManager *sdkConfigNotificationObj;

+ (void)load {
    [[UIViewController getSharedInstance] initializeConfigListeners];
}

static UIViewController *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance           = [[self alloc] init];
      isAlreadySwizzled  = NO;
      selectorsToSwizzle = @[
          @"viewDidAppear:",
      ];
    });
    return instance;
}

- (void)initializeConfigListeners {
    sdkConfigNotificationObj = [MNBaseNotificationManager
        addObserverToNotification:MNBaseNotificationSdkConfigUpdated
                        withBlock:^(NSNotification *_Nonnull notificationObj) {
                          @try {
                              MNLogD(@"SWIZZLER: Notification update -> ");
                              if ([[MNBaseSdkConfig getInstance] isSwizzlingEnabled]) {
                                  MNLogD(@"SWIZZLER: swizzleVCMethods called");
                                  [self swizzleVCMethods];
                              } else {
                                  MNLogD(@"SWIZZLER: un-swizzleVCMethods called");
                                  [self unswizzleVCMethods];
                              }
                          } @catch (NSException *swizzlerException) {
                              MNLogE(@"EXCEPTION - MNBaseVCSwizzler when changing swizzler status - %@",
                                     swizzlerException);
                          }
                        }];
}

- (void)swizzleVCMethods {
    @synchronized(self) {
        if (isAlreadySwizzled) {
            MNLogD(@"SWIZZLER: swizzleVCMethods: Not swizzling methods again!");
            return;
        }
        if (selectorsToSwizzle == nil || [selectorsToSwizzle count] == 0) {
            MNLogD(@"SWIZZLER: swizzleVCMethods: Not swizzling. Couldn't find any entries in selectorsToSwizzle. It's "
                   @"either nil or an empty array");
            return;
        }

        for (NSString *selStr in selectorsToSwizzle) {
            NSString *swizzleSelStr = [NSString stringWithFormat:@"%@%@", mnetSwizzlerPrefix, selStr];
            SEL originalSel         = NSSelectorFromString(selStr);
            SEL swizzleSel          = NSSelectorFromString(swizzleSelStr);
            [MNBaseUtil swizzleMethod:originalSel withSwizzlingSel:swizzleSel fromClass:[self class]];
        }
        MNLogD(@"SWIZZLER: swizzleVCMethods: Swizzling successful!");
        isAlreadySwizzled = YES;
    }
}

- (void)unswizzleVCMethods {
    @synchronized(self) {
        if (NO == isAlreadySwizzled) {
            MNLogD(@"SWIZZLER: unswizzleVCMethods: Not un-swizzling methods that are not swizzled!");
            return;
        }
        if (selectorsToSwizzle == nil || [selectorsToSwizzle count] == 0) {
            MNLogD(@"SWIZZLER: unswizzleVCMethods: Not un-swizzling. Couldn't find any entries in selectorsToSwizzle. "
                   @"It's either nil or an empty array");
            return;
        }

        for (NSString *selStr in selectorsToSwizzle) {
            NSString *swizzleSelStr = [NSString stringWithFormat:@"%@%@", mnetSwizzlerPrefix, selStr];
            SEL originalSel         = NSSelectorFromString(selStr);
            SEL swizzleSel          = NSSelectorFromString(swizzleSelStr);
            [MNBaseUtil swizzleMethod:swizzleSel withSwizzlingSel:originalSel fromClass:[self class]];
        }
        MNLogD(@"SWIZZLER: unswizzleVCMethods: Un-swizzling successful!");
        isAlreadySwizzled = NO;
    }
}

/// Processes the VC before it's displayed
- (void)mnad_processVC {
    // NOTE: This should be an array of strings.
    // There might be some classes that might not exist in certain ios versions.
    // It'll be handled when NSClassFromString() is used.
    NSArray<NSString *> *skippableControllers = @[
        @"UINavigationController",
        @"UITabBarController",
        @"UIInputWindowController",
        @"UISplitViewController",
        @"UIAlertController",
        @"UIApplicationRotationFollowingController",
    ];

    // Skipping for some class (container-views)
    for (NSString *skipControllerStr in skippableControllers) {
        Class skippableClass = NSClassFromString(skipControllerStr);
        if (skippableClass != nil && [self isKindOfClass:skippableClass]) {
            return;
        }
    }

    __block MNBaseAdRequest *adRequest = [MNBaseAdRequest newRequest];
    void (^task)(void)                 = ^{
      @try {
          NSString *contextLink = [MNBaseUtil getLinkFromApplink:self];

          // Make a prefetch-predict-bids call here
          adRequest.contextLink         = contextLink;
          adRequest.viewControllerTitle = [MNBaseUtil getViewControllerTitle:self];
      } @catch (NSException *e) {
          MNLogE(@"Exception - when creating the applink - %@", e);
      }
    };
    if ([NSThread isMainThread]) {
        task();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
          task();
        });
    }

    NSUInteger delayInSecs = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecs * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     @try {
                         MNBasePrefetchBids *prefetcher = [MNBasePrefetchBids getInstance];
                         [prefetcher prefetchBidsForAdRequest:adRequest
                                                       withCb:^(NSError *_Nullable prefetchErr) {
                                                         if (prefetchErr) {
                                                             MNLogRemote(@"Error: %@", prefetchErr);
                                                         } else {
                                                             MNLogD(@"Performed prefetch!");
                                                         }
                                                       }];
                     } @catch (NSException *e) {
                         MNLogE(@"EXCEPTION - prefetchBidsForAdRequest - %@", e);
                     }
                   });
}

#pragma mark - All the swizzled methods

- (void)mnad_swizzled_viewDidAppear:(BOOL)animated {
    MNLogD(@"Swizzled : view did appear %@", self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      MNLogD(@"Swizzled : view did appear processing start");
      @try {
          [self mnad_processVC];
          MNLogD(@"Swizzled : view did appear try block ended");
      } @catch (NSException *e) {
          MNLogE(@"Exception in viewDidAppear - %@", e);
      }
      MNLogD(@"Swizzled : view did appear processing end");
    });
    [self mnad_swizzled_viewDidAppear:animated];
    MNLogD(@"Swizzled : view did appear done");
}

- (void)mnad_swizzled_viewDidLoad {
    MNLogD(@"Swizzled : view did load");
    [self mnad_swizzled_viewDidLoad];
}

- (void)mnad_swizzled_viewWillAppear:(BOOL)animated {
    MNLogD(@"Swizzled : view will appear");
    [self mnad_swizzled_viewWillAppear:animated];
}

- (void)mnad_swizzled_viewWillDisappear:(BOOL)animated {
    MNLogD(@"Swizzled : view will disappear");
    [self mnad_swizzled_viewWillDisappear:animated];
}

@end
