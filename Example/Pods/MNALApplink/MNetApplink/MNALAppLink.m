//
//  MNALAppLink.m
//  Pods
//
//  Created by nithin.g on 01/09/17.
//
//

#import "MNALAppLink+Internal.h"

static BOOL shouldPrintLogs        = NO;
static BOOL forcedViewContentFetch = NO;
static NSString *customBundleId    = nil;

@implementation MNALAppLink

+ (instancetype)getInstanceWithVC:(UIViewController *)viewController
               withContentEnabled:(BOOL)isContentEnabled
               withIntentSkipList:(NSArray *)skipList
                     contentLimit:(NSInteger)contentLimit
                     titleEnabled:(BOOL)titleEnabled {

    return [[MNALAppLink alloc] initWithVC:viewController
                        withContentEnabled:isContentEnabled
                        withIntentSkipList:skipList
                              contentLimit:contentLimit
                              titleEnabled:titleEnabled];
}

- (instancetype)initWithVC:(UIViewController *)viewController
        withContentEnabled:(BOOL)isContentEnabled
        withIntentSkipList:(NSArray *)skipList
              contentLimit:(NSInteger)contentLimit
              titleEnabled:(BOOL)titleEnabled {
    self = [super init];
    _vc  = viewController;

    void (^updateViewTree)(void) = ^{
      self.viewTree           = [[MNALViewTree alloc] initWithViewController:viewController
                                                withContentEnabled:isContentEnabled
                                                withIntentSkipList:skipList
                                                      contentLimit:contentLimit
                                                      titleEnabled:titleEnabled];
      self.shouldFetchContent = isContentEnabled;

      if (self.viewTree != nil) {
          self.link = [self.viewTree getViewTreeLink];
      } else {
          self.link = @"";
      }
    };

    if ([NSThread isMainThread]) {
        updateViewTree();
    } else {
        dispatch_sync(dispatch_get_main_queue(), updateViewTree);
    }
    return self;
}

- (NSString *)getLink {
    return _link;
}

- (MNALViewTree *)getViewTree {
    return _viewTree;
}

- (UIViewController *)getViewController {
    return _vc;
}

- (NSString *)getContent {
    if (_viewTree != nil && _viewTree.content != nil && [_viewTree.content isEqualToString:@""] == NO) {
        return _viewTree.content;
    }
    return nil;
}

#pragma mark - Log states
+ (void)printLogs:(BOOL)printState {
    shouldPrintLogs = printState;
}

+ (BOOL)shouldPrintLogs {
    return shouldPrintLogs;
}

#pragma mark - Prefixes for bundle ids
static NSString *bundleIdSuffix;
+ (void)setSuffixForBundleId:(NSString *)suffix {
    if (suffix == nil) {
        bundleIdSuffix = nil;
        return;
    }

    suffix = [suffix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([suffix isEqualToString:@""]) {
        suffix = nil;
    }

    bundleIdSuffix = suffix;
}

+ (NSString *)getSuffixForBundleId {
    return bundleIdSuffix;
}

#pragma mark - Aggressive view content fetch

+ (void)enableAggressiveViewContentFetch {
    forcedViewContentFetch = YES;
}

/// Disable forced-view-content-fetch. It's disabled by default.
+ (void)disableAggressiveViewContentFetch {
    forcedViewContentFetch = NO;
}

/// Returns if forced-view-content-fetch is enabled.
+ (BOOL)isAggressiveViewContentFetch {
    return forcedViewContentFetch;
}

/// Setting a custom bundle id.
/// The value will be reset on nil or empty string.
+ (void)setCustomBundleId:(NSString *)bundleId {
    if (bundleId == nil) {
        customBundleId = nil;
        return;
    }
    bundleId = [bundleId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([bundleId isEqualToString:@""]) {
        customBundleId = nil;
        return;
    }
    customBundleId = bundleId;
    return;
}

/// Will return the custom bundle id if set. Returns nil if not set
+ (NSString *_Nullable)getCustomBundleId {
    return customBundleId;
}

@end
