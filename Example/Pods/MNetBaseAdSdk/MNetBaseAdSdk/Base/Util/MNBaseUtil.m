//
//  Util.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <CoreLocation/CoreLocation.h>
#import <MNALAppLink/MNALAppLink.h>
#import <mach/machine.h>
#import <sys/sysctl.h>
#import <sys/types.h>

#import "MNBase.h"
#import "MNBaseConstants.h"
#import "MNBaseDeviceInfo.h"
#import "MNBaseGeoLocation.h"
#import "MNBaseHTTPClient.h"
#import "MNBaseKeychainWrapper.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"
#import "NSString+MNBaseStringCrypto.h"

NSString *const kMNBaseAdCodeCookieStoreKey = @"mnet_adcode_cookies";

@implementation MNBaseUtil
// Right now, the store is NSUserDefaults, it can be changed to anything else
// later on.

+ (NSData *)getFromStoreForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)addToStoreForKey:(NSString *)key AndValue:(id)valueObj {
    // Serialize the data
    NSData *dataVal = [NSKeyedArchiver archivedDataWithRootObject:valueObj];
    [[NSUserDefaults standardUserDefaults] setObject:dataVal forKey:key];
}

+ (uint64_t)getFreeDiskspace {
    uint64_t totalFreeSpace = 0;
    NSError *error          = nil;
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary =
        [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];

    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace                      = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        MNLogD(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long) [error code]);
    }

    return totalFreeSpace;
}

+ (NSString *)createId {
    return [[[NSUUID UUID] UUIDString] lowercaseString];
}

+ (NSNumber *)getTimestampInMillis {
    return [NSNumber numberWithDouble:round([[NSDate date] timeIntervalSince1970] * 1000)];
}

+ (NSNumber *)getTimestamp {
    return [NSNumber numberWithDouble:round([[NSDate date] timeIntervalSince1970])];
}

+ (NSString *)getTimestampStr {
    return [NSString stringWithFormat:@"%ld", [[MNBaseUtil getTimestamp] longValue]];
}

+ (NSString *)getTimestampInMillisStr {
    return [NSString stringWithFormat:@"%ld", [[MNBaseUtil getTimestampInMillis] longValue]];
}

+ (NSDictionary *)parseStacktraceEntry:(NSString *)stEntry {
    NSMutableDictionary *respDict = [@{} mutableCopy];

    // NOTE: Usually, the stacktrace Entry looks like this -
    // 7   MNAdSdk 0x0000000101f6150c +[MNBaseAdRequest newRequest] + 140
    // Parsing this should suffice our needs for now

    // Parsing regex - ^\s*[0-9]+\s+([^\s]+)\s+[^\s]+\s+(\w+|(?:[-+]\[[^\]]+\]))\s+(.+),?\s*$
    NSString *regexStr = @"^\\s*[0-9]+\\s+([^\\s]+)\\s+[^\\s]+\\s+(\\w+|(?:[-+]\\[[^\\]]+\\]))\\s+(.+),?\\s*$";

    NSError *regexStrErr;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexStrErr];

    if (regexStrErr) {
        MNLogD(@"Error creating the regular expression - %@", regexStrErr);
        return respDict;
    }

    NSArray *matches = [regex matchesInString:stEntry options:0 range:NSMakeRange(0, stEntry.length)];
    // Technically, there should only be one match
    if ([matches count] > 0) {
        for (NSTextCheckingResult *match in matches) {
            if ([match numberOfRanges] > 3) {
                NSRange binaryNameRange = [match rangeAtIndex:1];
                NSString *binaryName    = [stEntry substringWithRange:binaryNameRange];

                NSRange methodNameRange = [match rangeAtIndex:2];
                NSString *methodName    = [stEntry substringWithRange:methodNameRange];

                NSRange filePathRange = [match rangeAtIndex:3];
                NSString *filePath    = [stEntry substringWithRange:filePathRange];

                respDict =
                    [@{@"binaryName" : binaryName, @"methodName" : methodName, @"filePath" : filePath} mutableCopy];
            } else {
                // MNLogD(@"REGEX: Number of matches is less than the number of groups. Regex error");
            }

            // Not iterating this more than once
            break;
        }
    } else {
        // MNLogD(@"REGEX: No matches for the regex!");
    }
    return respDict;
}

+ (NSString *)getClassNameFromStacktraceEntry:(NSString *)stEntry {
    NSString *respStr = @"";

    NSDictionary *parsedDict = [MNBaseUtil parseStacktraceEntry:stEntry];
    if (parsedDict && [parsedDict count] > 0) {
        respStr = [NSString stringWithFormat:@"(%@ : %@)", parsedDict[@"binaryName"], parsedDict[@"methodName"]];
    }

    return respStr;
}

+ (BOOL)writeToFileName:(NSString *)fileName withFolder:(NSString *)folderPath withContents:(NSString *)fileContents {
    NSString *appFile = [folderPath stringByAppendingPathComponent:fileName];

    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    return [data writeToFile:appFile atomically:YES];
}

+ (NSString *)readFromFileName:(NSString *)fileName withFolder:(NSString *)folderPath {
    NSString *appFile = [folderPath stringByAppendingPathComponent:fileName];

    NSString *dataStr = @"";
    if (![MNBaseUtil doesPathExist:appFile]) {
        return dataStr;
    }

    NSData *data = [NSData dataWithContentsOfFile:appFile];
    if (data) {
        dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return dataStr;
}

+ (BOOL)doesPathExist:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *)getSupportDirectoryPath {
    NSString *appSupportDirPath =
        [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];

    if (![self doesPathExist:appSupportDirPath]) {
        NSString *emptySupportDirPath = @"";
        NSError *dirCreationErr       = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&dirCreationErr];

        if (dirCreationErr) {
            MNLogD(@"%@", dirCreationErr.localizedDescription);
            return emptySupportDirPath;
        }

        // Mark the directory as excluded from iCloud backups
        NSError *backupExcludeErr = nil;
        NSURL *url                = [NSURL fileURLWithPath:appSupportDirPath];
        if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&backupExcludeErr]) {
            MNLogD(@"Error excluding %@ from backup %@", url.lastPathComponent, backupExcludeErr.localizedDescription);
        }
    }

    return appSupportDirPath;
}

+ (MNBaseGeoLocation *)mapPlacemarkToGeoLocation:(NSArray *)placemarksArr
                             withCurrentLocation:(CLLocation *)currentLocation {
    CLPlacemark *placemark = [placemarksArr objectAtIndex:0];

    MNBaseGeoLocation *currentGeoLocation = [[MNBaseGeoLocation alloc] init];
    currentGeoLocation.country            = placemark.ISOcountryCode;
    currentGeoLocation.city               = placemark.locality;
    currentGeoLocation.zipCode            = placemark.postalCode;

    NSString *reqVersion     = @"9.0";
    NSString *currentVersion = [[UIDevice currentDevice] systemVersion];

    NSTimeZone *timezoneObj;

    if ([currentVersion compare:reqVersion options:NSNumericSearch] != NSOrderedAscending) {
        @try {
            SEL timeZoneSel = NSSelectorFromString(@"timeZone");
            if ([placemark respondsToSelector:timeZoneSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                timezoneObj = [placemark performSelector:timeZoneSel];
#pragma clang diagnostic pop
            }
        } @catch (NSException *exp) {
            MNLogE(@"Exception when fetching the time-zone");
        }

    } else {
        NSString *timezoneRegex = @"identifier = \"([a-z]*\\/[a-z]_*[a-z]*)\"";
        NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:timezoneRegex
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:NULL];

        NSTextCheckingResult *newSearchString =
            [regex firstMatchInString:[placemark description]
                              options:0
                                range:NSMakeRange(0, [placemark.description length])];
        if ([newSearchString numberOfRanges] > 1) {
            NSString *substr         = [placemark.description substringWithRange:[newSearchString rangeAtIndex:1]];
            NSTimeZone *timezoneInfo = [NSTimeZone timeZoneWithName:substr];
            if (timezoneInfo) {
                timezoneObj = timezoneInfo;
            }
        }
    }

    // TODO: Should this be in hours? Seconds looks more accurate
    if (timezoneObj) {
        NSInteger offsetInMinutes   = (NSInteger)([timezoneObj secondsFromGMT] / 60);
        currentGeoLocation.offset   = offsetInMinutes;
        currentGeoLocation.timezone = [timezoneObj name];
    }

    currentGeoLocation.region = placemark.administrativeArea;

    currentGeoLocation.latitude  = currentLocation.coordinate.latitude;
    currentGeoLocation.longitude = currentLocation.coordinate.longitude;
    currentGeoLocation.accuracy  = (int) fabs(currentLocation.horizontalAccuracy);

    // Refer here -
    // http://stackoverflow.com/questions/38734167
    // This is a vague heuristic, Not definitive at all
    if (currentLocation.horizontalAccuracy > LOCATION_ACCURACY_THRESHOLD) {
        currentGeoLocation.locationSource = SOURCE_IP;
    } else {
        currentGeoLocation.locationSource = SOURCE_GPS;
    }

    return currentGeoLocation;
}

+ (NSString *)getMainPackageName {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];

    // Checking if custom-bundle-id is required
    NSString *customBundleId = [[MNBase getInstance] customBundleId];
    if (customBundleId != nil && NO == [customBundleId isEqualToString:@""]) {
        bundleId = customBundleId;
    }
    return [bundleId lowercaseString];
}

+ (NSString *)getDefaultBundleUrl {
    // Reverse the bundle identifier
    NSString *bundleId  = [self getMainPackageName];
    NSString *separator = @".";

    NSArray *bundleParts     = [bundleId componentsSeparatedByString:separator];
    NSMutableArray *revArray = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [bundleParts reverseObjectEnumerator];
    for (id element in enumerator) {
        [revArray addObject:element];
    }
    NSString *revBundleId = [revArray componentsJoinedByString:separator];

    NSString *url = [NSString stringWithFormat:@"http://%@.imnapp", revBundleId];
    return url;
}

+ (NSString *)getValueFromParamStr:(NSString *)paramStr forKey:(NSString *)needleKey {
    // The paramStr looks like this - bidder_id:10,customer:90
    NSString *defaultStr = @"";
    if (!paramStr) {
        return defaultStr;
    }

    paramStr = [paramStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([paramStr isEqualToString:@""]) {
        return defaultStr;
    }

    NSString *commaStr = @",";
    NSString *colonStr = @":";

    NSArray *commaSepArr = [paramStr componentsSeparatedByString:commaStr];
    for (NSString *keyValueStr in commaSepArr) {
        if ([keyValueStr containsString:colonStr]) {
            NSMutableArray *keyValueArr = [[keyValueStr componentsSeparatedByString:colonStr] mutableCopy];

            if ([keyValueArr count] > 1) {
                NSString *key = [keyValueArr objectAtIndex:0];

                if ([key isEqualToString:needleKey]) {
                    NSString *value;
                    if ([keyValueArr count] > 2) {
                        // Merge all of them to one value, starting from the first element
                        [keyValueArr removeObjectAtIndex:0];
                        value = [keyValueArr componentsJoinedByString:colonStr];
                    } else {
                        value = [keyValueArr objectAtIndex:1];
                    }
                    return value;
                }
            }
        }
    }

    return defaultStr;
}

+ (NSDictionary *)getDictFromParamStr:(NSString *)paramStr {
    NSDictionary<NSString *, NSString *> *paramStrRespDict;
    NSMutableDictionary<NSString *, NSString *> *paramsStrDict = [[NSMutableDictionary alloc] init];

    // The paramStr looks like this - bidder_id:10,customer:90
    if (!paramStr) {
        return paramStrRespDict;
    }

    paramStr = [paramStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([paramStr isEqualToString:@""]) {
        return paramStrRespDict;
    }

    NSString *commaStr = @",";
    NSString *colonStr = @":";

    NSArray *commaSepArr = [paramStr componentsSeparatedByString:commaStr];
    for (NSString *keyValueStr in commaSepArr) {
        if ([keyValueStr containsString:colonStr]) {
            NSMutableArray *keyValueArr = [[keyValueStr componentsSeparatedByString:colonStr] mutableCopy];

            if ([keyValueArr count] > 1) {
                NSString *key = [keyValueArr objectAtIndex:0];
                NSString *value;
                if ([keyValueArr count] > 2) {
                    // Merge all of them to one value, starting from the first element
                    [keyValueArr removeObjectAtIndex:0];
                    value = [keyValueArr componentsJoinedByString:colonStr];
                } else {
                    value = [keyValueArr objectAtIndex:1];
                }

                [paramsStrDict setObject:value forKey:key];
            }
        }
    }

    if ([paramsStrDict count] > 0) {
        paramStrRespDict = [NSDictionary dictionaryWithDictionary:paramsStrDict];
    }
    return paramStrRespDict;
}

+ (CGSize)getAdSizeFromStringFormat:(NSString *)adSizeStr {
    // TODO: Finalize the format
    // It could be of the format - 300x250
    if (adSizeStr != nil && [MNBaseUtil isNil:adSizeStr] == NO) {
        adSizeStr        = [adSizeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *sepStr = @"x";

        if ([adSizeStr containsString:sepStr]) {
            NSArray<NSString *> *components = [adSizeStr componentsSeparatedByString:sepStr];
            if ([components count] == 2) {
                CGFloat width  = [[components objectAtIndex:0] floatValue];
                CGFloat height = [[components objectAtIndex:1] floatValue];

                return CGSizeMake(width, height);
            }
        }
    }
    return CGSizeZero;
}

+ (NSString *)getAdSizeString:(CGSize)adSize {
    NSNumber *height = [NSNumber numberWithFloat:adSize.height];
    NSNumber *width  = [NSNumber numberWithFloat:adSize.width];

    return [NSString stringWithFormat:@"%dx%d", (int) [width integerValue], (int) [height integerValue]];
}

+ (NSString *)generateUniqueKeyForAdUnit:(NSString *)adUnitId {
    if (adUnitId == nil) {
        return @"";
    }

    return [self generateKeyWithAdUnit:adUnitId andKeyGenStr:[[NSUUID UUID] UUIDString]];
}

+ (NSString *)generateKeyWithAdUnit:(NSString *)adUnitId andKeyGenStr:(NSString *)keyGenStr {
    if (adUnitId == nil || keyGenStr == nil) {
        return @"";
    }

    return [NSString stringWithFormat:@"%@/%@", adUnitId, keyGenStr];
}

+ (BOOL)isHttpUrl:(NSString *)str {
    if (str == nil) {
        return NO;
    }
    NSURL *url = [NSURL URLWithString:str];
    if (url == nil) {
        return NO;
    }
    NSArray<NSString *> *validSchemes = @[ @"https", @"http" ];
    if ([validSchemes containsObject:url.scheme]) {
        return YES;
    }
    return NO;
}

+ (void)writeToKeyChain:(NSString *)valStr withKey:(NSString *)key {
    MNBaseKeychainWrapper *keychain = [MNBaseKeychainWrapper getInstance];
    [keychain upsert:key withData:[NSKeyedArchiver archivedDataWithRootObject:valStr]];
}

+ (NSString *)readFromKeyChainForKey:(NSString *)key {
    MNBaseKeychainWrapper *keychain = [MNBaseKeychainWrapper getInstance];
    NSData *data                    = [keychain find:key];
    return (!data) ? nil : [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (BOOL)isOperatingSystemAtLeastVersion:(NSInteger)version {
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){version, 0, 0}];
}

+ (BOOL)isConnectedToInternet {
    return [MNBaseHttpClient isInternetConnectivityPresent];
}

#pragma mark - Image Resource util methods

+ (void)getImageResourceNamed:(NSString *)name
                      success:(void (^)(UIImage *))successHandler
                        error:(void (^)(NSError *))errorHandler {
    NSMutableArray *components = [[name componentsSeparatedByString:@"."] mutableCopy];
    if ([components count] == 1) {
        MNLogD(@"No format found so adding png as default");
        [components addObject:@"png"];
    }
    int scale             = [[UIScreen mainScreen] scale];
    NSString *resourceUrl = [[MNBaseURL getSharedInstance] getBaseResourceUrl];
    NSString *path = [NSString stringWithFormat:@"%@/%@@%dx.%@", resourceUrl, components[0], scale, components[1]];
    MNLogD(@"Fetching from the path %@", path);
    [MNBaseHttpClient doGetImageOn:path success:successHandler error:errorHandler];
}

/*
 Replacement list format -> It's a list of dicts
 [
 {"target": "replacement},
 {"yin"   : "yang"},
 {"old"   : "new},
 ]
 Note that before replacement, it performs a urlencode of both the target and the replacement (since it needs to be a
 valid url even after replacement)
 */
+ (NSArray *)replaceItemsInUrlsList:(NSArray<NSString *> *)urlsList withReplacementList:(NSArray *)replacementList {
    NSMutableArray *modifiedUrlList = [[NSMutableArray alloc] initWithCapacity:[urlsList count]];

    for (NSString *logUrl in urlsList) {
        NSString *updatedUrl = logUrl;

        for (NSDictionary *item in replacementList) {
            NSString *target      = [[item allKeys] objectAtIndex:0];
            NSString *replacement = [item objectForKey:target];

            updatedUrl = [updatedUrl stringByReplacingOccurrencesOfStringInUrl:target withString:replacement];
        }
        [modifiedUrlList addObject:updatedUrl];
    }

    return modifiedUrlList;
}

+ (NSString *)getFormattedTimeDurationStr:(NSTimeInterval)currentTime {
    NSInteger currentTimeInt = (NSInteger) currentTime;
    NSInteger seconds        = currentTimeInt % 60;
    NSInteger minutes        = (currentTimeInt / 60) % 60;
    NSInteger hours          = (currentTimeInt / 3600);
    NSInteger milliseconds   = (NSInteger)(currentTime * 1000) % 1000;

    // NOTE: I hate this too
    return [NSString
        stringWithFormat:@"%02ld:%02ld:%02ld.%03ld", (long) hours, (long) minutes, (long) seconds, (long) milliseconds];
}

+ (UIViewController *)getTopViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topController      = [self topViewControllerWithRootViewController:rootViewController];

    return topController;
}

// Taken from here - https://stackoverflow.com/a/17578272/1518924
// This tackles all types of viewControllers
+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *) rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if ([rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitVC                   = (UISplitViewController *) rootViewController;
        NSArray<UIViewController *> *viewControllersList = [splitVC viewControllers];
        if ([viewControllersList count] > 0) {
            return [self topViewControllerWithRootViewController:[viewControllersList objectAtIndex:0]];
        }
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }

    return rootViewController;
}

+ (int)getRandBetween:(int)lowerBound andUpperBound:(int)upperBound {
    return lowerBound + arc4random() % (upperBound - lowerBound);
}

+ (NSString *)getVCNameForView:(UIView *)view {
    UIResponder *responder = view;
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }

    int height_limit = 10;
    while (![responder isKindOfClass:[UIViewController class]] || height_limit > 0) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
        height_limit -= 1;
    }

    if (!responder) {
        return nil;
    }

    UIViewController *vcName = (UIViewController *) responder;
    return NSStringFromClass([vcName class]);
}

+ (NSString *)urlDecode:(NSString *)encodedStr {
    if (!encodedStr) {
        return nil;
    }

    NSString *result = [encodedStr stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result           = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

// Stolen - https://stackoverflow.com/a/8088484/1518924
+ (NSString *)urlEncode:(NSString *)rawStr {
    const unsigned char *source = (const unsigned char *) [rawStr UTF8String];
    NSMutableString *output     = [NSMutableString string];
    int sourceLen               = (int) strlen((const char *) source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') || (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (CGFloat)getOverlappingPercentageOfViewFrame:(CGRect)viewBounds comparedToParentBounds:(CGRect)parentBounds {
    CGRect visibleRect = CGRectIntersection(parentBounds, viewBounds);

    CGFloat visiblePercentage = 0.0f;

    if (CGRectIsNull(visibleRect) == NO) {
        CGSize visibleSize  = visibleRect.size;
        CGSize originalSize = viewBounds.size;

        CGFloat visibleArea  = visibleSize.width * visibleSize.height;
        CGFloat originalArea = originalSize.width * originalSize.height;

        if (visibleArea > 0.0f && originalArea > 0.0f) {
            visiblePercentage = (visibleArea / originalArea) * 100.f;
        }
    }
    return fabs(visiblePercentage);
}

+ (NSString *)getViewControllerTitle:(UIViewController *)viewController {
    if (viewController == nil) {
        return nil;
    }
    return NSStringFromClass([viewController class]);
}

+ (void)swizzleMethod:(SEL)originalSel withSwizzlingSel:(SEL)swizzledSel fromClass:(Class)className {
    Method originalMethod = class_getInstanceMethod(className, originalSel);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSel);

    BOOL didAddMethod = class_addMethod(className, originalSel, method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(className, swizzledSel, method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (BOOL)isNil:(id)object {
    return (object == nil || [object isEqual:[NSNull null]]);
}

+ (NSString *)replaceStr:(NSString *)originalStr fromMap:(NSDictionary<NSString *, NSString *> *)replacementMap {
    NSMutableString *mutStr = [[NSMutableString alloc] initWithString:originalStr];

    for (NSString *replacementKey in replacementMap) {
        NSString *replacementVal = [replacementMap objectForKey:replacementKey];
        NSRange defaultRange     = NSMakeRange(0, [mutStr length]);
        [mutStr replaceOccurrencesOfString:replacementKey
                                withString:replacementVal
                                   options:NSLiteralSearch
                                     range:defaultRange];
    }

    return [NSString stringWithString:mutStr];
}

+ (NSString *)generateAdCycleId {
    return [self createId];
}

+ (NSString *)getHostAppVersionId {
    NSString *appBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionStr     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *sep            = @"b";

    NSString *appVersionStr = [NSString stringWithFormat:@"%@%@%@", versionStr, sep, appBuildNumber];

    // Replace all the dots to hyphens
    appVersionStr = [appVersionStr stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    return appVersionStr;
}

+ (NSString *)getLinkForVC:(UIViewController *)rootViewController {
    if (rootViewController == nil) {
        return nil;
    }

    NSString *VCLink;
    // Checking if the VC is present as an entry in the sdk-config.
    NSString *VCName = NSStringFromClass([rootViewController class]);
    NSString *sdkUrl = [[MNBaseSdkConfig getInstance] getLinkFromSdkConfigForVCName:VCName];
    if (sdkUrl != nil && [sdkUrl isEqualToString:@""] == NO) {
        VCLink = sdkUrl;
    }

    if (VCLink == nil || [VCLink isEqualToString:@""]) {
        // Getting the link from the currentViewTree;
        /*
         NOTE: The reason why link is generated first and not the sdk config,
         is because MNBaseLinkStore needs to be updated. Analytics and others data need this.
         It's more convienient this way.
         */
        VCLink = [MNBaseUtil getLinkFromApplink:rootViewController];
    }
    return VCLink;
}

+ (NSString *)getLinkFromApplink:(UIViewController *)vc {
    return [MNBaseUtil getDefaultBundleUrl];
    // NOTE: This is temporarily commented out
    /*
    MNALAppLink *appLink = [MNALAppLink getInstanceWithVC:rootViewController withContentEnabled:NO];
     */
}

+ (BOOL)doesStrMatch:(NSString *)ipStr regexStr:(NSString *)regexStr {
    if (regexStr == nil || [regexStr isEqualToString:@""]) {
        return NO;
    }

    NSError *regexError = nil;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&regexError];
    if (regexError != nil) {
        MNLogD(@"Incorrect regex - %@", regexError);
        return NO;
    }
    NSRange fullRange                 = NSMakeRange(0, [ipStr length]);
    NSTextCheckingResult *matchResult = [regex firstMatchInString:ipStr options:0 range:fullRange];
    return (matchResult != nil && NSEqualRanges([matchResult range], fullRange));
}

+ (NSDictionary *)parseURL:(NSURL *)url {
    if (url == nil) {
        return nil;
    }

    NSString *query = url.query;

    if (query == nil || [query isEqualToString:@""]) {
        return nil;
    }

    NSMutableDictionary *params;
    // Check for parameters, parse them if found
    NSArray *paramArray = [query componentsSeparatedByString:@"&"];
    params              = [[NSMutableDictionary alloc] initWithCapacity:[paramArray count]];
    for (NSString *param in paramArray) {
        if ([param isEqualToString:@""]) {
            continue;
        }
        NSArray *components = [param componentsSeparatedByString:@"="];
        if (components == nil || [components count] == 1) {
            continue;
        }
        NSString *key = components[0];
        NSString *val = components[1];
        [params setValue:val forKey:key];
    }

    return params;
}

+ (NSString *)getResourceURLForResourceName:(NSString *)resourceName {
    if ([self isHttpUrl:resourceName]) {
        return resourceName;
    }
    NSString *baseResourceURL = [[MNBaseURL getSharedInstance] getBaseResourceUrl];
    NSString *resourceURL = [baseResourceURL stringByAppendingString:[NSString stringWithFormat:@"/%@", resourceName]];
    return resourceURL;
}

+ (NSString *)jsonEscape:(NSString *)ipStr {
    if (ipStr == nil) {
        return nil;
    }
    // Picked up from here - https://stackoverflow.com/a/15843642/1518924
    NSMutableString *s = [NSMutableString stringWithString:ipStr];
    [s replaceOccurrencesOfString:@"\""
                       withString:@"\\\""
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/"
                       withString:@"\\/"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n"
                       withString:@"\\n"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b"
                       withString:@"\\b"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f"
                       withString:@"\\f"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r"
                       withString:@"\\r"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t"
                       withString:@"\\t"
                          options:NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

+ (void)loadCookiesFromUserDefaults {
    MNLogD(@"Loading cookies from user defaults");
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kMNBaseAdCodeCookieStoreKey] == nil) {
        return;
    }

    NSMutableArray *cookies = [[NSUserDefaults standardUserDefaults] valueForKey:kMNBaseAdCodeCookieStoreKey];
    for (NSString *cookieKey in cookies) {
        NSMutableDictionary *cookieDict = [[NSUserDefaults standardUserDefaults] valueForKey:cookieKey];
        NSHTTPCookie *cookie            = [NSHTTPCookie cookieWithProperties:cookieDict];
        if (cookie != nil) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

+ (void)saveCookiesInUserDefaults {
    MNLogD(@"saving cookies from user defaults");
    NSMutableArray *cookies = [[NSMutableArray alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if (cookie == nil || cookie.name == nil) {
            continue;
        }

        [cookies addObject:cookie.name];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];

        if (cookie.name != nil && NO == [cookie.name isEqualToString:@""]) {
            [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
        }

        if (cookie.value != nil && NO == [cookie.value isEqualToString:@""]) {
            [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
        }

        if (cookie.domain != nil && NO == [cookie.domain isEqualToString:@""]) {
            [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
        }

        if (cookie.path != nil && NO == [cookie.path isEqualToString:@""]) {
            [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
        }

        [cookieProperties setObject:[NSNumber numberWithUnsignedInteger:cookie.version] forKey:NSHTTPCookieVersion];

        if (cookie.expiresDate != nil) {
            [cookieProperties setObject:cookie.expiresDate forKey:NSHTTPCookieExpires];
        }

        if (cookie.name != nil) {
            [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:cookies forKey:kMNBaseAdCodeCookieStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)canMakeGetRequestFromBody:(NSString *)body {
    NSUInteger bodyNumBytes = 0;
    if (body != nil) {
        bodyNumBytes = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    }
    NSUInteger maxUrlLen = [[[MNBaseSdkConfig getInstance] getMaxUrlLength] unsignedIntegerValue];
    return bodyNumBytes <= maxUrlLen;
}

+ (NSDictionary *)getApiHeaders {
    __block MNBaseDeviceInfo *deviceInfo;
    void (^getDeviceDetails)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];
    };

    if ([NSThread isMainThread]) {
        getDeviceDetails();
    } else {
        dispatch_sync(dispatch_get_main_queue(), getDeviceDetails);
    }

    if (deviceInfo == nil) {
        return nil;
    }

    NSString *deviceName = [deviceInfo deviceModel];
    if (deviceName == nil) {
        deviceName = @"";
    }

    NSString *osVersion = [deviceInfo osVersion];
    if (osVersion == nil) {
        osVersion = @"";
    }

    NSString *appBundleName = [self getMainPackageName];
    if (appBundleName == nil) {
        appBundleName = @"";
    }

    NSString *sdkVersionName = [[MNBase getInstance] sdkVersionName];
    if (sdkVersionName == nil) {
        sdkVersionName = @"";
    }

    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setObject:osVersion forKey:@"X-MNET-OS-VER"];
    [headers setObject:deviceName forKey:@"X-MNET-DEVICE"];
    [headers setObject:appBundleName forKey:@"X-MNET-BUNDLE"];
    [headers setObject:sdkVersionName forKey:@"X-MNET-EXTERNAL-VER"];

    return [headers copy];
}

+ (id)customPerformSelector:(SEL)selector forTarget:(id)target {
    if (target != nil && YES == [target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self hasVoidReturnValForTarget:target withSel:selector]) {
            [target performSelector:selector];
            return nil;
        } else {
            return [target performSelector:selector];
        }
#pragma clang diagnostic pop
    }
    MNLogD(@"Skipping performSelector since target - %@ is nil or target does not respond to selector", target);
    return nil;
}

+ (id)customPerformSelector:(SEL)selector forTarget:(id)target withArg:(id)arg {
    if (target != nil && YES == [target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self hasVoidReturnValForTarget:target withSel:selector]) {
            [target performSelector:selector withObject:arg];
            return nil;
        } else {
            return [target performSelector:selector withObject:arg];
        }
#pragma clang diagnostic pop
    }
    MNLogD(@"Skipping performSelector since target - %@ is nil or target does not respond to selector", target);
    return nil;
}

+ (BOOL)hasVoidReturnValForTarget:(id)target withSel:(SEL)selector {
    if (target == nil) {
        return NO;
    }
    Method m = class_getInstanceMethod([target class], selector);
    char type[128];
    method_getReturnType(m, type, sizeof(type));
    return (strncmp(type, "v", 1) == 0);
}

@end
