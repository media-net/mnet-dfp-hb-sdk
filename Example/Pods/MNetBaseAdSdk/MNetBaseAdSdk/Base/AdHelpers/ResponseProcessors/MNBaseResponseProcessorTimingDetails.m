//
//  MNBaseResponseProcessorTimingDetails.m
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseProcessorTimingDetails.h"
#import "MNBaseAdAnalytics.h"
#import "MNBaseLogger.h"
#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@implementation MNBaseResponseProcessorTimingDetails

- (void)processResponse:(NSDictionary *)response withResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    // Fetching the keys and updating the timing data for analytics
    NSString *timingDataKey  = @"td";
    NSDictionary *timingData = [response objectForKey:timingDataKey];
    if (timingData && ![timingData isEqual:[NSNull null]]) {
        [self logTimingDataFromResponse:timingData withAdCycleId:responseExtras.adCycleId];
    }
}

- (void)logTimingDataFromResponse:(NSDictionary *)timingData withAdCycleId:(NSString *)adCycleId {
    if (adCycleId == nil || timingData == nil) {
        MNLogD(@"AdcycleId and timingData are both mandatory(non-nil) to ResponseProcessorTimingDetails");
        return;
    }

    MNBaseAdAnalytics *adAnalytics      = [MNBaseAdAnalytics getSharedInstance];
    NSArray<NSString *> *timingDataKeys = @[ @"rtb_exchange", @"dp_processing" ];
    NSDictionary<NSString *, NSNumber *> *timingDataToAnalyticsEventMap;
    timingDataToAnalyticsEventMap = @{
        @"rtb_exchange" : ENUM_VAL(MnetAdAnalyticsTypeRtbExchange),
        @"dp_processing" : ENUM_VAL(MnetAdAnalyticsTypeDpProcessing)
    };

    for (NSString *key in timingDataKeys) {
        NSNumber *value = [timingData valueForKey:key];
        if (value != nil) {
            NSTimeInterval timeDuration = [value doubleValue];
            NSNumber *eventObj          = [timingDataToAnalyticsEventMap objectForKey:key];

            [adAnalytics logTimeDuration:timeDuration forEvent:[eventObj intValue] withAdCycleId:adCycleId];
        }
    }
}

@end
