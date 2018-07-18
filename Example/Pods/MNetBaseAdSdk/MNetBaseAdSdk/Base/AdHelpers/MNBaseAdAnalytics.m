//
//  MNBaseAdAnalytics.m
//  Pods
//
//  Created by nithin.g on 03/07/17.
//
//

#import "MNBaseAdAnalytics+Internal.h"
#import "MNBaseAdAnalyticsData.h"
#import "MNBaseAnalyticsEvent.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import <MNetJSONModeller/MNJMManager.h>

#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@interface MNBaseAdAnalytics ()
@property (atomic) NSMutableDictionary<NSString *, MNBaseAdAnalyticsData *> *adAnalyticsDataDict;
@end

@implementation MNBaseAdAnalytics
static MNBaseAdAnalytics *instance;

#pragma mark - Loader methods
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[[self class] alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self                     = [super init];
    self.adAnalyticsDataDict = [[NSMutableDictionary alloc] init];

    return self;
}

#pragma mark - Logging time methods
- (BOOL)logStartTimeForEvent:(MNBaseAdAnalyticsEventType)eventType withAdCycleId:(NSString *)adCycleId {
    return [self logTimeForEvent:eventType withAdCycleId:adCycleId forState:MNBaseAdAnalyticsEventStart];
}

- (BOOL)logEndTimeForEvent:(MNBaseAdAnalyticsEventType)eventType withAdCycleId:(NSString *)adCycleId {
    return [self logTimeForEvent:eventType withAdCycleId:adCycleId forState:MNBaseAdAnalyticsEventEnd];
}

- (BOOL)logTimeForEvent:(MNBaseAdAnalyticsEventType)eventType
          withAdCycleId:(NSString *)adCycleId
               forState:(MNBaseAdAnalyticsEventState)state {
    if (adCycleId == nil) {
        MNLogD(@"Not logging time since adcycle-id if empty");
        return NO;
    }

    MNBaseAdAnalyticsData *dataObj = [self obtainAnalyticsDataObjForAdCycleId:adCycleId];
    NSString *eventStr             = [[self class] getStrForEventType:eventType];
    BOOL logStatus                 = [dataObj logTimeForEvent:eventStr forState:state];
    [self addToAnalyticsDict:dataObj forAdCycleId:adCycleId];

    /* NOTE:
     Stopping the Net here because -
     - In case of interstitial, (especially video), showing the ad can happen at
     the user's mercy after the ad has been loaded. Net should not include that time
     - This makes NET exclusive of the ad_rendering time. Need to be added to NET at the end
     */
    if (eventType == MnetAdAnalyticsTypeBidderResponse && state == MNBaseAdAnalyticsEventEnd) {
        [self logEndTimeForEvent:MnetAdAnalyticsTypeNet withAdCycleId:adCycleId];
    }

    return logStatus;
}

- (BOOL)logTimeDuration:(NSTimeInterval)timeVal
               forEvent:(MNBaseAdAnalyticsEventType)eventType
          withAdCycleId:(NSString *)adCycleId {
    MNBaseAdAnalyticsData *dataObj = [self obtainAnalyticsDataObjForAdCycleId:adCycleId];
    NSString *eventStr             = [[self class] getStrForEventType:eventType];
    BOOL logStatus                 = [dataObj logTimeDuration:timeVal forEvent:eventStr];
    [self addToAnalyticsDict:dataObj forAdCycleId:adCycleId];

    return logStatus;
}

#pragma mark - Logging metadata methods
- (BOOL)logAdUnitId:(NSString *)adUnitId forAdCycleId:(NSString *)adCycleId {
    MNBaseAdAnalyticsData *dataObj = [self obtainAnalyticsDataObjForAdCycleId:adCycleId];
    [dataObj logAdUnitId:adUnitId];
    [self addToAnalyticsDict:dataObj forAdCycleId:adCycleId];
    return YES;
}

- (BOOL)logBidderId:(NSNumber *)bidderId forAdCycleId:(NSString *)adCycleId {
    MNBaseAdAnalyticsData *dataObj = [self obtainAnalyticsDataObjForAdCycleId:adCycleId];
    [dataObj logBidderId:bidderId];
    [self addToAnalyticsDict:dataObj forAdCycleId:adCycleId];
    return YES;
}

- (BOOL)logBid:(NSNumber *)bid forAdCycleId:(NSString *)adCycleId {
    MNBaseAdAnalyticsData *dataObj = [self obtainAnalyticsDataObjForAdCycleId:adCycleId];
    [dataObj logBid:bid];
    [self addToAnalyticsDict:dataObj forAdCycleId:adCycleId];
    return YES;
}

#pragma mark - Pulse methods
- (void)writeToPulseForAdCycleId:(NSString *)adCycleId {
    // Get the entries for the ad cycle Id
    MNBaseAdAnalyticsData *analyticsDataObj = [self getAnalyticsDataObjForAdCycleId:adCycleId];

    // Get the data into the required format.
    NSDictionary *timingsData = [self fetchAndProcessAnalyticsData:analyticsDataObj];

    MNLogD(@"ANALYTICS: Timings Data - %@", [MNJMManager toJSONStr:timingsData]);

    // Add the rest of the data if required (MNBaseAnalytics can probably take care of that)
    MNBaseAnalyticsEvent *analyticsEvent = [MNBaseAnalyticsEvent newInstance];
    [analyticsEvent setTimingsData:timingsData];
    [analyticsEvent setAdCycleId:adCycleId];
    [analyticsEvent setAdUnitId:analyticsDataObj.adUnitId];

    if (analyticsDataObj.bid != nil) {
        [analyticsEvent setBid:[analyticsDataObj.bid doubleValue]];
    }
    if (analyticsDataObj.bidderId != nil) {
        [analyticsEvent setBidderId:[analyticsDataObj.bidderId longValue]];
    }

    // Log to pulse
    [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventAnalytics andCustomData:analyticsEvent];
}

- (NSDictionary *)fetchAndProcessAnalyticsData:(MNBaseAdAnalyticsData *)analyticsDataObj {
    // Add the ad_rendering time to the net object
    NSDictionary *timingsData               = [analyticsDataObj getFormattedData];
    NSMutableDictionary *updatedTimingsData = [NSMutableDictionary dictionaryWithDictionary:timingsData];

    NSString *netEventStr    = [[self class] getStrForEventType:MnetAdAnalyticsTypeNet];
    NSString *adRenderingStr = [[self class] getStrForEventType:MnetAdAnalyticsTypeAdRendering];

    NSNumber *adRenderingDuration = [timingsData objectForKey:adRenderingStr];
    if (adRenderingDuration != nil) {
        NSNumber *netDuration = [timingsData objectForKey:netEventStr];
        if (netDuration != nil) {
            double updatedNetDurationVal = [netDuration doubleValue] + [adRenderingDuration doubleValue];
            [updatedTimingsData setObject:[NSNumber numberWithDouble:updatedNetDurationVal] forKey:netEventStr];
        }
    }

    return updatedTimingsData;
}

#pragma mark - Helpers
- (void)addToAnalyticsDict:(MNBaseAdAnalyticsData *)adAnalyticsData forAdCycleId:(NSString *)adCycleId {
    if (adAnalyticsData == nil || adCycleId == nil) {
        MNLogRemote(@"Error adding empty data to into analytics dict");
        return;
    }
    [self.adAnalyticsDataDict setObject:adAnalyticsData forKey:adCycleId];

    // Deciding whether to write to pulse
    if ([self shouldWriteToPulseWithAnalyticsData:adAnalyticsData andAdCycleId:adCycleId]) {
        [self writeToPulseForAdCycleId:adCycleId];
        [self removeEntryForAdCycleId:adCycleId];
    }
}

- (BOOL)shouldWriteToPulseWithAnalyticsData:(MNBaseAdAnalyticsData *)adAnalyticsData
                               andAdCycleId:(NSString *)adCycleId {
    NSString *adxEventStr         = [[self class] getStrForEventType:MnetAdAnalyticsTypeMediaAdx];
    NSString *adRenderingEventStr = [[self class] getStrForEventType:MnetAdAnalyticsTypeAdRendering];

    // Check if the it has completed entries for the events
    BOOL shouldWriteToPulse = NO;
    if ([adAnalyticsData hasCompletedEntryForEvent:adRenderingEventStr]) {
        if ([adAnalyticsData hasEntryForEvent:adxEventStr]) {
            if ([adAnalyticsData hasCompletedEntryForEvent:adxEventStr]) {
                shouldWriteToPulse = YES;
            }
        } else {
            shouldWriteToPulse = YES;
        }
    }
    return shouldWriteToPulse;
}

- (MNBaseAdAnalyticsData *)getAnalyticsDataObjForAdCycleId:(NSString *)adCycleId {
    return [self.adAnalyticsDataDict valueForKey:adCycleId];
}

- (MNBaseAdAnalyticsData *)obtainAnalyticsDataObjForAdCycleId:(NSString *)adCycleId {
    MNBaseAdAnalyticsData *dataObj = [self getAnalyticsDataObjForAdCycleId:adCycleId];
    if (!dataObj) {
        dataObj = [[MNBaseAdAnalyticsData alloc] init];

        // Add the NET event for every start
        [dataObj logTimeForEvent:[[self class] getStrForEventType:MnetAdAnalyticsTypeNet]
                        forState:MNBaseAdAnalyticsEventStart];
    }
    return dataObj;
}

- (void)removeEntryForAdCycleId:(NSString *)adCycleId {
    [self.adAnalyticsDataDict removeObjectForKey:adCycleId];
}

+ (NSString *)getStrForEventType:(MNBaseAdAnalyticsEventType)eventType {
    NSString *eventTypeStr = @"";

    switch (eventType) {
    case MnetAdAnalyticsTypeNet:
        eventTypeStr = @"net";
        break;
    case MnetAdAnalyticsTypeDpResponse:
        eventTypeStr = @"dp_response";
        break;
    case MnetAdAnalyticsTypeDfpResponse:
        eventTypeStr = @"dfp_response";
        break;
    case MnetAdAnalyticsTypeMediaAdx:
        eventTypeStr = @"media_adx";
        break;
    case MnetAdAnalyticsTypeBidderResponse:
        eventTypeStr = @"bidder_response";
        break;
    case MnetAdAnalyticsTypeAdRendering:
        eventTypeStr = @"ad_rendering";
        break;
    case MnetAdAnalyticsTypeDpProcessing:
        eventTypeStr = @"dp_processing";
        break;
    case MnetAdAnalyticsTypeRtbExchange:
        eventTypeStr = @"rtb_exchange";
        break;
    case MnetAdAnalyticsTypeDpLatency:
        eventTypeStr = @"dp_latency";
        break;
    default:
        break;
    }

    return eventTypeStr;
}

@end
