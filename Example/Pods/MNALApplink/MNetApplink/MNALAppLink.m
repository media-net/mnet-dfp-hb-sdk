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

@implementation MNALAppLink

+ (instancetype)getInstanceWithVC:(UIViewController *)viewController withContentEnabled:(BOOL)isContentEnabled {
    return [[MNALAppLink alloc] initWithVC:viewController withContentEnabled:isContentEnabled];
}

- (instancetype)initWithVC:(UIViewController *)viewController withContentEnabled:(BOOL)isContentEnabled {
    self = [super init];
    _vc  = viewController;

    void (^updateViewTree)(void) = ^{
      self.viewTree = [[MNALViewTree alloc] initWithViewController:viewController withContentEnabled:isContentEnabled];
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

@end
