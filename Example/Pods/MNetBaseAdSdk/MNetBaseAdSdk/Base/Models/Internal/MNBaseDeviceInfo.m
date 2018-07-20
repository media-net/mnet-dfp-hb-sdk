//
//  MNBaseDeviceInfo.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseDeviceInfo.h"
#import "MNBase.h"
#import "MNBaseAdIdManager.h"
#import "MNBaseConstants.h"
#import "MNBaseDeviceUserAgent.h"
#import "MNBaseIPadManager.h"
#import "MNBaseLogger.h"
#import "MNBaseReachability.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"

#import "MNBaseDataPrivacy.h"
#import "MNBaseLocationDataTracker.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <sys/utsname.h>

@interface MNBaseDeviceInfo ()
@property (atomic) NSString *__ipv4Starred;
@end

@implementation MNBaseDeviceInfo

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [self getInstance];
    });
}

+ (id)getInstance {
    static MNBaseDeviceInfo *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });

    if (sharedInstance != nil) {
        MNLogD(@"PRIVACY: Printing privacy details from device-info");
        MNLogD(@"PRIVACY: child directed : %@", [sharedInstance isChildDirected] ? @"YES" : @"NO");
        MNLogD(@"PRIVACY: GDPR-enabled : %@", [[MNBaseDataPrivacy getSharedInstance] isGdprEnabled] ? @"YES" : @"NO");
        MNLogD(@"PRIVACY: Is ad tracking enabled : %@",
               [[MNBaseDataPrivacy getSharedInstance] isAdTrackingEnabled] ? @"YES" : @"NO");
        MNLogD(@"PRIVACY: Do not track : %@", [sharedInstance disableAdTracking]);
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _javaScriptSupport = 1;
        // 4 for phone, 5 for tablet
        _deviceType = [MNBaseIPadManager isIPad] ? 5 : 4;
        [self processDeviceInfo];
    }
    return self;
}

- (void)processDeviceInfo {
    // getting connection type
    MNBaseReachability *reachability = [MNBaseReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    MNBaseNetworkStatus status = [reachability currentReachabilityStatus];
    if (status == MNBaseNetworkNotReachable) {
        [self setConnectionType:-1];
    } else if (status == MNBaseNetworkReachableViaWiFi) {
        [self setConnectionType:1];
    } else if (status == MNBaseNetworkReachableViaWWAN) {
        [self setConnectionType:2];
    }

    // getting ip address
    NSString *ipv4Str = MNBaseGetIPAddress();
    [self setIpv4Address:ipv4Str];

    self.__ipv4Starred = [self getStarredIPV4:ipv4Str];

    // getting hardware version
    [self setHardwareVersion:MNBaseGetDeviceName()];
    [self setManufacturer:@"apple"];
    [self setDeviceLang:[[NSLocale preferredLanguages] objectAtIndex:0]];

    NSString *idForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self setMac:idForVendor];

    // getting the carrier info
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier              = [netinfo subscriberCellularProvider];
    NSString *carrierName           = [carrier carrierName];
    if (carrierName == nil) {
        carrierName = @"";
    }
    [self setCarrier:carrierName];

    // Memory size
    unsigned long long ramSize = [NSProcessInfo processInfo].physicalMemory;
    NSString *freeRamSize      = [NSString stringWithFormat:@"%llu", ramSize];
    [self setDeviceRam:freeRamSize];

    uint64_t freeSpaceInt  = [MNBaseUtil getFreeDiskspace];
    NSString *freeSpaceStr = [NSString stringWithFormat:@"%lld", (long long) freeSpaceInt];
    [self setInternalFreeSpace:freeSpaceStr];

    // Courtesy - http://stackoverflow.com/a/7922666/1518924
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }

    [self setPixelRatio:scale];

    float dpi;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dpi = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        dpi = 163 * scale;
    } else {
        dpi = 160 * scale;
    }
    [self setPixelDensity:dpi];

    // Get the user agent
    [self setUserAgent:[MNBaseDeviceUserAgent getDeviceUserAgent]];

    // display height and width
    CGRect screen = [[UIScreen mainScreen] bounds];
    [self setDisplayWidth:CGRectGetWidth(screen) * scale];
    [self setDisplayHeight:CGRectGetHeight(screen) * scale];

    // os version
    [self setDeviceModel:[[UIDevice currentDevice] model]];
    [self setOsVersion:[[UIDevice currentDevice] systemVersion]];
    // Not using [[UIDevice currentDevice] systemName] on purpose
    [self setOs:PLATFORM_NAME];
}

- (NSString *)getStarredIPV4:(NSString *)ipv4Address {
    if (ipv4Address == nil || [ipv4Address isEqualToString:@""]) {
        return @"";
    }
    NSArray *ipOctets = [ipv4Address componentsSeparatedByString:@"."];
    if (ipOctets == nil || [ipOctets count] == 0) {
        return @"";
    }

    NSString *ipv4 = @"";
    for (int i = 0; i < [ipOctets count] - 1; i++) {
        ipv4 = [ipv4 stringByAppendingString:[NSString stringWithFormat:@"%@.", ipOctets[i]]];
    }
    ipv4 = [ipv4 stringByAppendingString:@"*"];
    MNLogD(@"MNBase: IPV4 starred %@", ipv4);
    return ipv4;
}

- (BOOL)isAdTrackingDisabled {
    // Nil disableAdTracking is treated as if tracking is disabled
    return self.disableAdTracking == nil || (self.disableAdTracking != nil && [self.disableAdTracking intValue] == 1);
}

// All the helpers
NSString *MNBaseGetDeviceName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

NSString *MNBaseGetIPAddress() {
    NSString *address          = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr  = NULL;
    int success                = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString
                        stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

// All the getters for the property
- (BOOL)isChildDirected {
    return [[MNBase getInstance] appContainsChildDirectedContent];
}

@synthesize geoLocation = _geoLocation;
- (MNBaseGeoLocation *)geoLocation {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _geoLocation;
}

- (void)setGeoLocation:(MNBaseGeoLocation *)geoLocation {
    _geoLocation = geoLocation;
}

@synthesize userAgent = _userAgent;
- (NSString *)userAgent {
    return _userAgent;
}

- (void)setUserAgent:(NSString *)userAgent {
    _userAgent = userAgent;
}

@synthesize mac = _mac;
- (NSString *)mac {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _mac;
}

- (void)setMac:(NSString *)mac {
    _mac = mac;
}

@synthesize ipv4Address = _ipv4Address;
- (NSString *)ipv4Address {
    if ([self isAdTrackingDisabled]) {
        return self.__ipv4Starred;
    }
    return _ipv4Address;
}

- (void)setIpv4Address:(NSString *)ipv4Address {
    _ipv4Address = ipv4Address;
}

@synthesize ipv6Address = _ipv6Address;
- (NSString *)ipv6Address {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _ipv6Address;
}

- (void)setIpv6Address:(NSString *)ipv6Address {
    _ipv6Address = ipv6Address;
}

@synthesize countryCode = _countryCode;
- (NSString *)countryCode {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _countryCode;
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
}

@synthesize locationAllowed = _locationAllowed;
- (int)locationAllowed {
    if ([self isAdTrackingDisabled]) {
        return 0;
    }
    return _locationAllowed;
}

- (void)setLocationAllowed:(int)locationAllowed {
    _locationAllowed = locationAllowed;
}

@synthesize carrier = _carrier;
- (NSString *)carrier {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _carrier;
}

- (void)setCarrier:(NSString *)carrier {
    _carrier = carrier;
}

@synthesize deviceLang = _deviceLang;
- (NSString *)deviceLang {
    if ([self isAdTrackingDisabled]) {
        return nil;
    }
    return _deviceLang;
}

- (void)setDeviceLang:(NSString *)deviceLang {
    _deviceLang = deviceLang;
}

@synthesize connectionType = _connectionType;
- (int)connectionType {
    if ([self isAdTrackingDisabled]) {
        return -1;
    }
    return _connectionType;
}

- (void)setConnectionType:(int)connectionType {
    _connectionType = connectionType;
}

@synthesize advertId = _advertId;
- (NSString *)advertId {
    if ([self isAdTrackingDisabled]) {
        return @"";
    }
    return [[MNBaseAdIdManager getSharedInstance] getAdvertId];
}

- (void)setAdvertId:(NSString *)advertId {
    _advertId = advertId;
}

@synthesize disableAdTracking = _disableAdTracking;
- (NSNumber *)disableAdTracking {
    /*
     NOTE: The disableAdTracking is being set again in the getter
     because deviceInfo is cached. Doing this since there could be
     a possiblility of the child-directed flag to change.
     */
    int disableAdTracking = [[MNBaseDataPrivacy getSharedInstance] doNoTrack] ? 1 : 0;
    _disableAdTracking    = [NSNumber numberWithInt:disableAdTracking];
    return _disableAdTracking;
}

- (void)setDisableAdTracking:(NSNumber *)disableAdTracking {
    _disableAdTracking = disableAdTracking;
}

#pragma mark - Property map

- (NSDictionary *)propertyKeyMap {

    return @{
        @"dnt" : @"dnt",

        @"userAgent" : @"ua",

        @"ipv4Address" : @"ip",

        @"ipv6Address" : @"ipv6",

        @"hardwareVersion" : @"hwv",

        @"displayHeight" : @"h",

        @"displayWidth" : @"w",

        @"pixelDensity" : @"ppi",

        @"pixelRatio" : @"pxratio",

        @"countryCode" : @"mccmnc",

        @"javaScriptSupport" : @"js",

        @"locationAllowed" : @"geofetch",

        @"advertId" : @"ifa",

        @"carrier" : @"carrier",

        @"deviceLang" : @"language",

        @"manufacturer" : @"make",

        @"deviceModel" : @"model",

        @"deviceRam" : @"device_ram",

        @"internalFreeSpace" : @"internal_free_space",

        @"os" : @"os",

        @"osVersion" : @"osv",

        @"connectionType" : @"connectiontype",

        @"deviceType" : @"devicetype",

        @"geoLocation" : @"geo",

        @"disableAdTracking" : @"lmt"
    };
}
@end
