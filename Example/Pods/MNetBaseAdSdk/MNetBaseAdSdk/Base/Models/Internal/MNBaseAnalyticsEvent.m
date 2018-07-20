//
//  MNBaseAnalyticsEvent.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAnalyticsEvent.h"
#import "MNBaseLinkStore.h"

@implementation MNBaseAnalyticsEvent
+ (instancetype)newInstance {
    MNBaseAnalyticsEvent *instance = [[[self class] alloc] init];
    [instance buildDefaultProperties];

    return instance;
}

- (instancetype)init {
    self = [super init];

    return self;
}

- (void)buildDefaultProperties {
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

    self.deviceInfo = deviceInfo;
    self.appLink    = [[MNBaseLinkStore getSharedInstance] getLink];
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"deviceInfo" : @"device",
        @"timingsData" : @"timings",
    };
}

@end
