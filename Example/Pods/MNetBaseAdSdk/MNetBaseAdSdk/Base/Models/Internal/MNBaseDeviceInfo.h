//
//  MNBaseDeviceInfo.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseGeoLocation.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseDeviceInfo : NSObject <MNJMMapperProtocol>

//-(id) init __attribute__((unavailable("Must call newInstance class method")));

// do not track flag. By default 0 for sdk
@property (atomic) int dnt;

@property (atomic) NSString *userAgent;

@property (atomic) NSString *mac;

@property (atomic) NSString *ipv4Address;

@property (atomic) NSString *ipv6Address;

@property (atomic) NSString *hardwareVersion;

@property (atomic) NSString *deviceRam;

@property (atomic) NSString *internalFreeSpace;

@property (atomic) int displayHeight;

@property (atomic) int displayWidth;

@property (atomic) float pixelDensity;

@property (atomic) float pixelRatio;

// mobile country code
@property (atomic) NSString *countryCode;

// always one for sdk
@property (atomic) int javaScriptSupport;

// 1 if we have location permission, 0 otherwise
@property (atomic) int locationAllowed;

@property (atomic) NSString *advertId;

@property (atomic) NSString *carrier;

@property (atomic) NSString *deviceLang;

@property (atomic) NSString *manufacturer;

@property (atomic) NSString *deviceModel;

@property (atomic) NSString *os;

@property (atomic) NSString *osVersion;

@property (atomic) NSNumber *limitedAdTracking;

@property (atomic) BOOL doNotTrackForEurope;

// Connection type mapping
// 0 Unknown
// 1 Ethernet
// 2 WIFI
// 3 Cellular Network – Unknown Generation
// 4 Cellular Network – 2G
// 5 Cellular Network – 3G
// 6 Cellular Network – 4G
@property (atomic) int connectionType;

// by default 1 for mobile decices which is always the case
@property (atomic) int deviceType;

@property (atomic) MNBaseGeoLocation *geoLocation;

// Get singelton instance
+ (id)getInstance;

- (void)updateLimitedAdTracking;

@end
