//
//  MNBaseFingerprintData.m
//  Pods
//
//  Created by nithin.g on 22/05/17.
//
//

#import "MNBaseFingerprintData.h"
#import "MNBaseDeviceInfo.h"

#define DEVICE_TYPE @"IPH"

@implementation MNBaseFingerprintData

- (instancetype)init {
    self = [super init];
    [self getDeviceInfo];

    return self;
}

- (void)getDeviceInfo {
    __block MNBaseDeviceInfo *deviceInfo;
    void (^deviceInfoBlock)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];
    };

    // Need to always fetch from the main thread (Accesses UIKit)
    if (![NSThread isMainThread]) {
        // Block it
        dispatch_sync(dispatch_get_main_queue(), deviceInfoBlock);
    } else {
        deviceInfoBlock();
    }

    self.ifa             = deviceInfo.advertId;
    self.dpi             = deviceInfo.pixelDensity;
    self.deviceType      = DEVICE_TYPE;
    self.hardwareVersion = deviceInfo.hardwareVersion;
    self.imei            = nil;
    self.macId           = deviceInfo.mac;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"ifa" : @"a",
        @"dpi" : @"dp",
        @"deviceType" : @"d",
        @"hardwareVersion" : @"hw",
        @"imei" : @"i",
        @"macId" : @"m"
    };
}

@end
