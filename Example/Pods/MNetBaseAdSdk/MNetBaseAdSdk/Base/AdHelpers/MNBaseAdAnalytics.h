//
//  MNBaseAdAnalytics.h
//  Pods
//
//  Created by nithin.g on 03/07/17.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    MnetAdAnalyticsTypeNet,
    MnetAdAnalyticsTypeDpProcessing,
    MnetAdAnalyticsTypeRtbExchange,
    MnetAdAnalyticsTypeDpResponse,
    MnetAdAnalyticsTypeDfpResponse,
    MnetAdAnalyticsTypeMediaAdx,
    MnetAdAnalyticsTypeDpLatency,
    MnetAdAnalyticsTypeBidderResponse,
    MnetAdAnalyticsTypeAdRendering,
} MNBaseAdAnalyticsEventType;

@interface MNBaseAdAnalytics : NSObject

+ (instancetype)getSharedInstance;

- (BOOL)logStartTimeForEvent:(MNBaseAdAnalyticsEventType)eventType withAdCycleId:(NSString *)adCycleId;
- (BOOL)logEndTimeForEvent:(MNBaseAdAnalyticsEventType)eventType withAdCycleId:(NSString *)adCycleId;
- (BOOL)logTimeDuration:(NSTimeInterval)timeVal
               forEvent:(MNBaseAdAnalyticsEventType)eventType
          withAdCycleId:(NSString *)adCycleId;

- (BOOL)logAdUnitId:(NSString *)adUnitId forAdCycleId:(NSString *)adCycleId;
- (BOOL)logBidderId:(NSNumber *)bidderId forAdCycleId:(NSString *)adCycleId;
- (BOOL)logBid:(NSNumber *)bid forAdCycleId:(NSString *)adCycleId;

- (void)writeToPulseForAdCycleId:(NSString *)adCycleId;

@end
