//
//  MNALAppLink.h
//  Pods
//
//  Created by nithin.g on 01/09/17.
//
//

#import "MNALViewTree.h"
#import <Foundation/Foundation.h>

@interface MNALAppLink : NSObject

- (instancetype)init __attribute__((unavailable("Use [MNALAppLink getInstanceWithVC:] instead")));

/// Create instance from VC. This creates the view-tree and the link immediately
+ (instancetype)getInstanceWithVC:(UIViewController *)viewController withContentEnabled:(BOOL)isContentEnabled;

/// Returns the link for the view controller
- (NSString *)getLink;

/// Returns the content for the current view-controller.
/// It'll only work if the isContentEnabled is YES in the initializer. Otherwise, it'll return nil
- (NSString *)getContent;

/// Returns the view-tree generated for the view controller
- (MNALViewTree *)getViewTree;

/// Returns the given view controller
- (UIViewController *)getViewController;

/// This controls whether this module should print the logs or not. It's default is NO
+ (void)printLogs:(BOOL)printState;

/// Sets the suffix to the bundle-id. All bundle-ids used in the app will have this.
/// It can be useful for debugging purposes.
/// It allows for running a unique entry every time (useful for crawlers).
/// You can set it to nil or an empty string remove existing suffixes.
+ (void)setSuffixForBundleId:(NSString *)suffix;

/// Get the bundle-id prefix. It's nil by default
+ (NSString *)getSuffixForBundleId;

/// Enabling this will help in fetching contents more forcefully,
/// For eg - by scrolling up-down. Bascially allows modification of host app.
/// aggressive-view-content-fetch disabled by default.
/// WARNING: Use with caution.Can cause a lot of problems, if used.
+ (void)enableAggressiveViewContentFetch;

/// Disable forced-view-content-fetch. It's disabled by default.
+ (void)disableAggressiveViewContentFetch;

/// Returns if forced-view-content-fetch is enabled.
+ (BOOL)isAggressiveViewContentFetch;

@end
