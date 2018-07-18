//
//  MNBaseUtil.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseGeoLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define isEmpty(element) ((element == nil || element == [NSNull null]))

@interface MNBaseUtil : NSObject

+ (NSData *)getFromStoreForKey:(NSString *)key;
+ (void)addToStoreForKey:(NSString *)key AndValue:(id)valueObj;
+ (uint64_t)getFreeDiskspace;
+ (NSString *)createId;
+ (NSNumber *)getTimestamp;
+ (NSString *)getTimestampStr;
+ (NSNumber *)getTimestampInMillis;
+ (NSString *)getTimestampInMillisStr;
+ (NSString *)getClassNameFromStacktraceEntry:(NSString *)stEntry;
+ (NSDictionary *)parseStacktraceEntry:(NSString *)stEntry;
+ (BOOL)isConnectedToInternet;
+ (BOOL)isNil:(id)object;

+ (BOOL)writeToFileName:(NSString *)fileName withFolder:(NSString *)folderPath withContents:(NSString *)fileContents;
+ (NSString *)readFromFileName:(NSString *)fileName withFolder:(NSString *)folderPath;
+ (BOOL)doesPathExist:(NSString *)path;
+ (NSString *)getSupportDirectoryPath;

+ (MNBaseGeoLocation *)mapPlacemarkToGeoLocation:(NSArray *)placemarksArr
                             withCurrentLocation:(CLLocation *)currentLocation;

+ (NSString *)getDefaultBundleUrl;

+ (NSString *)getValueFromParamStr:(NSString *)paramStr forKey:(NSString *)needleKey;
+ (NSDictionary *)getDictFromParamStr:(NSString *)paramStr;

+ (CGSize)getAdSizeFromStringFormat:(NSString *)adSizeStr;
+ (NSString *)getAdSizeString:(CGSize)adSize;

+ (NSString *)generateUniqueKeyForAdUnit:(NSString *)adUnitId;
+ (NSString *)generateKeyWithAdUnit:(NSString *)adUnitId andKeyGenStr:(NSString *)keyGenStr;
+ (BOOL)isHttpUrl:(NSString *)str;

+ (void)writeToKeyChain:(NSString *)valStr withKey:(NSString *)key;
+ (NSString *)readFromKeyChainForKey:(NSString *)key;

+ (void)getImageResourceNamed:(NSString *)name
                      success:(void (^)(UIImage *))successHandler
                        error:(void (^)(NSError *))errorHandler;

+ (NSArray *)replaceItemsInUrlsList:(NSArray<NSString *> *)urlsList withReplacementList:(NSArray *)replacementList;

+ (NSString *)getFormattedTimeDurationStr:(NSTimeInterval)currentTime;

+ (UIViewController *)getTopViewController;
+ (int)getRandBetween:(int)lowerbound andUpperBound:(int)upperBound;

+ (NSString *)getVCNameForView:(UIView *)view;

+ (NSString *)urlDecode:(NSString *)encodedStr;
+ (NSString *)urlEncode:(NSString *)rawStr;

+ (NSString *)jsonEscape:(NSString *)ipStr;

+ (BOOL)isOperatingSystemAtLeastVersion:(NSInteger)version;

/// Get the percentage of overlap between the view and the window.
/// Make sure that the viewBounds is with respect to the window and not to it's superview.
/// (Run - [view convertRect:view.bounds toView:nil], to obtain this)
+ (CGFloat)getOverlappingPercentageOfViewFrame:(CGRect)viewBounds comparedToParentBounds:(CGRect)parentBounds;

+ (NSString *)getViewControllerTitle:(UIViewController *)viewController;

/// Swizzle a selector for a class
+ (void)swizzleMethod:(SEL)originalSel withSwizzlingSel:(SEL)swizzledSel fromClass:(Class)className;

+ (NSString *)replaceStr:(NSString *)originalStr fromMap:(NSDictionary<NSString *, NSString *> *)replacementMap;

+ (NSString *)generateAdCycleId;

/// Host-app version-id is the app-version and build number concatenated, of host app, with the
/// dots replaced by hyphens.
/// It looks like "1-0-1b27".
+ (NSString *)getHostAppVersionId;

/// Gets a link for a given VC
+ (NSString *)getLinkForVC:(UIViewController *)rootViewController;

/// Get the package-name
+ (NSString *)getMainPackageName;

/// Return boolean if the regex-str matches the ip-str completely
+ (BOOL)doesStrMatch:(NSString *)ipStr regexStr:(NSString *)regexStr;

/// Parses the given url, extracts all parameters and returns a dictionary with parameter key and parameter value pairs
+ (NSDictionary *)parseURL:(NSURL *)url;

/// Returns resource url for resource name
+ (NSString *)getResourceURLForResourceName:(NSString *)resourceName;

/// Loads cookies from NSUserDefaults
+ (void)loadCookiesFromUserDefaults;

/// Stored current available cookies from NSHTTPCookieStorage to NSUserDefaults
+ (void)saveCookiesInUserDefaults;

+ (NSString *)getLinkFromApplink:(UIViewController *)vc;

+ (BOOL)canMakeGetRequestFromBody:(NSString *)body;

+ (NSDictionary *)getApiHeaders;

/// Performs selector for target
+ (id _Nullable)customPerformSelector:(SEL)selector forTarget:(id _Nonnull)target;

/// Performs selector for target with arguments
+ (id _Nullable)customPerformSelector:(SEL)selector forTarget:(id _Nonnull)target withArg:(id _Nullable)arg;

/// Checks if the selector in the target has a void-return type.
/// In case the target is nil, the return value will be NO
/// In case the target does not respond to selector, the return value will be NO
/// It is the responsibilty of the caller to perform these checks
+ (BOOL)hasVoidReturnValForTarget:(id)target withSel:(SEL)selector;

@end
