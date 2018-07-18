//
//  MNALUtils.h
//  Pods
//
//  Created by nithin.g on 25/05/17.
//
//

#import "MNALViewTree.h"
#import <Foundation/Foundation.h>

@interface MNALUtils : NSObject

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr
                       AndFailureReason:(NSString *)failureReasonStr
                  AndRecoverySuggestion:(NSString *)recoverySuggestionStr;

+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr;
+ (NSNumber *)getTimestamp;
+ (NSString *)truncateNodeIdStr:(NSString *)nodeIdStr;
+ (NSString *)getBundleId;
+ (NSString *)encodeUrlComponent:(NSString *)str;
+ (NSString *)getTitleForController:(UIViewController *)controller;
+ (NSString *)getRandomString;
+ (NSString *)getAppVersionStr;
+ (NSString *)getContentHash:(UIViewController *)controller viewTreeContent:(NSString *)content;
+ (NSString *)getNSStringFromChar:(const char *)charVal;

/// Gets the normalized dim wrt window in percentages
+ (NSNumber *)getNormalizedDimension:(CGFloat)dim isWidth:(BOOL)isWidth;

/// Generates unique link for controller name
+ (NSString *)getURIForControllerName:(NSString *)controllerName;

/// Encodes the given link
+ (NSString *)getEncodedLink:(NSString *)link;

+ (BOOL)isAdapterChild:(UIView *)view viewController:(UIViewController *)controller;

+ (NSString *)getResourceNameForView:(UIView *)view withId:(int)viewId;
+ (NSInteger)getTotalRowsForView:(UIView *)view forSection:(NSInteger)section andRow:(NSInteger)row;
+ (NSInteger)getTotalRowsForView:(UIView *)view;
+ (NSIndexPath *)getIndexPathForView:(UIView *)view forIndex:(NSNumber *)index;
+ (BOOL)isClassStrOfAdType:(NSString *)classStr;

@end
