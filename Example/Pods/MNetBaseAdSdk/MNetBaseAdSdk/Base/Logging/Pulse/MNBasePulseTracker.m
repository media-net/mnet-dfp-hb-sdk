//
//  PulseTracker.m
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBasePulseTracker.h"
#import "MNBaseConstants.h"
#import "MNBaseDeviceInfo.h"
#import "MNBaseLogger.h"
#import "MNBasePulseEvent.h"
#import "MNBasePulseHttp.h"

@implementation MNBasePulseTracker
+ (void)logDeviceInfoAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      @try {
          [MNBasePulseTracker logDeviceInfo];
      } @catch (NSException *e) {
          MNLogD(@"EXCEPTION - %@", e);
      }
    });
}

+ (void)logDeviceInfo {
    NSMutableArray<MNBasePulseEvent *> *eventsList = [[NSMutableArray alloc] init];

    __block MNBaseDeviceInfo *deviceInfo;
    void (^deviceInfoBlock)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];
      [deviceInfo updateLimitedAdTracking];
    };

    // Need to always fetch from the main thread (Accesses UIKit)
    if (![NSThread isMainThread]) {
        // Block it
        dispatch_sync(dispatch_get_main_queue(), deviceInfoBlock);
    } else {
        deviceInfoBlock();
    }

    if (!deviceInfo) {
        MNLogRemote(@"Unable to fetch device info data");
        return;
    }

    NSArray *deviceKeys =
        @[ MNBasePulseEventDevice, MNBasePulseEventNetwork, MNBasePulseEventDeviceLang, MNBasePulseEventUserAgent ];

    for (NSString *key in deviceKeys) {
        MNBasePulseEvent *event =
            [[MNBasePulseEvent alloc] initWithType:key withSubType:key withMessage:nil andCustomData:deviceInfo];
        if (event != nil) {
            [eventsList addObject:event];
        }
    }

    NSArray *locationKeys = @[
        MNBasePulseEventLocation,
        MNBasePulseEventTimezone,
        MNBasePulseEventAddress,
    ];

    if (deviceInfo.geoLocation) {
        for (NSString *key in locationKeys) {
            MNBasePulseEvent *eventObj = [[MNBasePulseEvent alloc] initWithType:key
                                                                    withSubType:key
                                                                    withMessage:@""
                                                                  andCustomData:deviceInfo.geoLocation];
            if (eventObj != nil) {
                [eventsList addObject:eventObj];
            }
        }
    }
    [[MNBasePulseHttp getSharedInstance] logEventsWithArray:eventsList];
}

+ (void)logRemoteCustomEventType:(NSString *)type andCustomData:(id)customData {
    [self logRemoteCustomEventType:type withMessage:nil andCustomData:customData];
}

+ (void)logRemoteCustomEventType:(NSString *)type withMessage:(NSString *)message andCustomData:(id)customData {
    MNBasePulseEvent *event =
        [[MNBasePulseEvent alloc] initWithType:type withSubType:type withMessage:message andCustomData:customData];

    if (event != nil) {
        [[MNBasePulseHttp getSharedInstance] logEvent:event];
    }
}
@end
