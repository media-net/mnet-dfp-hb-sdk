//
//  MNBaseAdAnalyticsData.h
//  Pods
//
//  Created by nithin.g on 03/07/17.
//
//

#import "MNBaseAdAnalytics+Internal.h"
#import <Foundation/Foundation.h>

@interface MNBaseAdAnalyticsData : NSObject
@property (atomic) NSString *adUnitId;
@property (atomic) NSNumber *bidderId;
@property (atomic) NSNumber *bid;

- (BOOL)logTimeForEvent:(NSString *)eventType forState:(MNBaseAdAnalyticsEventState)eventState;
- (BOOL)logTimeDuration:(NSTimeInterval)timeDuration forEvent:(NSString *)eventType;
- (void)logAdUnitId:(NSString *)adUnitId;
- (void)logBidderId:(NSNumber *)bidderId;
- (void)logBid:(NSNumber *)bid;

- (NSDictionary *)getFormattedData;
- (BOOL)hasCompletedEntryForEvent:(NSString *)eventType;
- (BOOL)hasEntryForEvent:(NSString *)eventType;

@end
