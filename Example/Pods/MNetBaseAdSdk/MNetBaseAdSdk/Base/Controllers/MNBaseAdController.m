//
//  MNBaseAddController.m
//  Pods
//
//  Created by akshay.d on 20/02/17.
//
//

#import "MNBaseAdController.h"
#import "MNBaseAdClickEvent.h"
#import "MNBaseAuctionLoggerManager.h"
#import "MNBaseError.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLinkStore.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

@implementation MNBaseAdController
- (BOOL)processResponse {
    if (self.adResponse == nil) {
        return NO;
    }
    CGSize size = [MNBaseUtil getAdSizeFromStringFormat:self.adResponse.size];
    if (NO == [self validateAdSizeFromResponse]) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(adDidFail:)]) {
            NSError *err = [MNBaseError
                createErrorWithDescription:
                    [NSString stringWithFormat:@"Invalid adview size. Response ad size is (width - %f, height - %f)",
                                               size.width, size.height]];
            [self.delegate adDidFail:err];
        }
        return NO;
    }
    if (self.adSizeControllerDelegate != nil &&
        [self.adSizeControllerDelegate respondsToSelector:@selector(adViewDidChangeSize:)]) {
        [self.adSizeControllerDelegate adViewDidChangeSize:size];
    }
    return YES;
}

- (void)invalidate {
}

- (void)showAdFromRootViewController {
}

- (void)restart {
}

- (bool)isReady {
    return NO;
}

- (void)makeLoggingBeaconsReq {
    // Making a call to all the Logging Beacon events
    MNBaseBidResponse *bidResponse = self.adResponse;
    if (bidResponse == nil) {
        return;
    }

    NSString *adCycleId = [bidResponse getAdCycleId];
    NSNumber *bid       = bidResponse.ogBid;
    NSNumber *bidderId  = bidResponse.bidderId;

    /// Make the logging pixel calls
    NSArray<NSString *> *loggingBeacons = bidResponse.loggingBeacons;
    NSUInteger beaconsCount             = (loggingBeacons != nil) ? [loggingBeacons count] : 0;
    MNLogD(@"DEBUG_LOGS: Firing logging_pixels. Found %lu for bidder_id - %@, ad_cycle_id - %@",
           (unsigned long) beaconsCount, bidderId, adCycleId);
    for (NSString *loggingUrl in loggingBeacons) {
        MNLogD(@"DEBUG_LOGS: Firing logging_pixel for bidder_id - %@, ad_cycle_id - %@ url - %@", bidderId, adCycleId,
               loggingUrl);
        [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventAdVisible
                                       andCustomData:@{
                                           @"url" : loggingUrl,
                                           @"bid" : bid,
                                           @"ad_cycle_id" : adCycleId,
                                       }];

        [MNBaseHttpClient doGetWithStrResponseOn:loggingUrl
            headers:nil
            shouldRetry:YES
            success:^(NSString *_Nonnull responseDict) {
              [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventTrackingSuccess
                                             andCustomData:@{
                                                 @"url" : loggingUrl,
                                                 @"bid" : bid,
                                                 @"ad_cycle_id" : adCycleId,
                                             }];
            }
            error:^(NSError *_Nonnull error) {
              NSString *errorStr = @"";
              if (error) {
                  errorStr = [error localizedDescription];
              }
              [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventTrackingError
                                             andCustomData:@{
                                                 @"url" : loggingUrl,
                                                 @"bid" : bid,
                                                 @"ad_cycle_id" : adCycleId,
                                                 @"error" : errorStr
                                             }];
            }];
    }
}

- (void)makeInAdLoggingReq {
    // The child adControllers will need to implement this
}

- (void)logAdClickedEvent:(BOOL)isInterstitial {
    NSString *subType = (isInterstitial) ? MNBasePulseEventInterstitialAdClicked : MNBasePulseEventBannerAdClicked;

    MNBaseAdClickEvent *adClickEvent = [MNBaseAdClickEvent getInstanceFromBidResponse:self.adResponse];
    [MNBasePulseTracker logRemoteCustomEventType:subType andCustomData:adClickEvent];
}

- (BOOL)validateAdSizeFromResponse {
    if (self.isInterstitial) {
        return YES;
    }

    BOOL isValidAdSize    = NO;
    CGSize responseAdSize = [MNBaseUtil getAdSizeFromStringFormat:self.adResponse.size];
    __block MNBaseDeviceInfo *deviceInfo;

    void (^getDeviceInfo)(void) = ^{
      deviceInfo = [MNBaseDeviceInfo getInstance];
    };
    if ([NSThread isMainThread]) {
        getDeviceInfo();
    } else {
        dispatch_sync(dispatch_get_main_queue(), getDeviceInfo);
    }
    if (deviceInfo == nil) {
        return NO;
    }
    int adHeight = (int) responseAdSize.height;
    int adWidth  = (int) responseAdSize.width;

    int devicePixelRatio = [deviceInfo pixelRatio];
    int deviceWidth      = [deviceInfo displayWidth] / devicePixelRatio;
    int deviceHeight     = [deviceInfo displayHeight] / devicePixelRatio;

    MNLogD(@"checking for ad size %d %d against %d %d", adHeight, adWidth, deviceHeight, deviceWidth);
    if (adHeight <= deviceHeight && adWidth <= deviceWidth) {
        isValidAdSize = YES;
    }
    return isValidAdSize;
}
@end
