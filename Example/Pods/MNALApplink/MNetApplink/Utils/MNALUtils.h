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

/// Return the main bundle's identifier. It will return the custom-bundle if set in MNALApplink
+ (NSString *)getMainBundleId;

/// Return the bundle id. Will return with prefix if set
+ (NSString *)getBundleId;

+ (NSString *)encodeUrlComponent:(NSString *)str;
+ (NSString *)getTitleForController:(UIViewController *)controller;
+ (NSString *)getRandomString;
+ (NSString *)getAppVersionStr;
+ (NSString *)getNSStringFromChar:(const char *)charVal;
+ (NSString *)getJsonStringOfPropertiesForViewController:(UIViewController *)controller
                                                skipList:(NSArray *)skipList
                                                 content:(NSString *)content
                                            contentLimit:(NSInteger)contentLimit;
/// Gets the normalized dim wrt window in percentages
+ (NSNumber *)getNormalizedDimension:(CGFloat)dim isWidth:(BOOL)isWidth;
+ (NSMutableDictionary *)removeObjectFromDict:(NSMutableDictionary *)propsDict skipList:(NSArray *)skipList;
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
