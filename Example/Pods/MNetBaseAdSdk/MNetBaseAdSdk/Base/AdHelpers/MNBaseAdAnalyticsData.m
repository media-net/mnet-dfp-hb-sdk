//
//  MNBaseAdAnalyticsData.m
//  Pods
//
//  Created by nithin.g on 03/07/17.
//
//

#import "MNBaseAdAnalyticsData.h"
#import "MNBaseAdAnalytics.h"
#import "MNBaseUtil.h"

@class MNBaseTimeTrackerElement;

@interface MNBaseAdAnalyticsData ()
@property (atomic) NSMutableDictionary<NSString *, MNBaseTimeTrackerElement *> *eventTimeTrackersDict;
@end

@interface MNBaseTimeTrackerElement : NSObject
@property (atomic) NSTimeInterval startTime;
@property (atomic) NSTimeInterval endTime;
@property (atomic) NSTimeInterval timeDuration;

- (BOOL)setCurrentTimeForState:(MNBaseAdAnalyticsEventState)eventState;
- (NSNumber *)getTimeDiff;
- (NSNumber *)getTimeDiffInMillis;
@end

@implementation MNBaseAdAnalyticsData

- (instancetype)init {
    self                       = [super init];
    self.eventTimeTrackersDict = [[NSMutableDictionary alloc] init];

    return self;
}

#pragma mark - Add the logging methods
- (BOOL)logTimeDuration:(NSTimeInterval)timeDuration forEvent:(NSString *)eventType {
    MNBaseTimeTrackerElement *timeTrackerObj = [self obtainTimeTrackerForEventType:eventType];
    @synchronized(self) {
        [timeTrackerObj setTimeDuration:timeDuration];
    }
    [self addTimeTrackerObj:timeTrackerObj forEventType:eventType];

    return YES;
}

- (BOOL)logTimeForEvent:(NSString *)eventType forState:(MNBaseAdAnalyticsEventState)eventState {
    MNBaseTimeTrackerElement *timeTrackerObj = [self obtainTimeTrackerForEventType:eventType];

    BOOL setTimeStatus = NO;
    @synchronized(self) {
        setTimeStatus = [timeTrackerObj setCurrentTimeForState:eventState];
    }
    [self addTimeTrackerObj:timeTrackerObj forEventType:eventType];

    return setTimeStatus;
}

- (void)logAdUnitId:(NSString *)adUnitId {
    self.adUnitId = adUnitId;
}

- (void)logBidderId:(NSNumber *)bidderId {
    self.bidderId = bidderId;
}

- (void)logBid:(NSNumber *)bid {
    self.bid = bid;
}

#pragma mark - Setter and Getter methods

- (MNBaseTimeTrackerElement *)getTimeTrackerForEventType:(NSString *)eventType {
    @synchronized(self) {
        return [self.eventTimeTrackersDict objectForKey:eventType];
    }
}

- (MNBaseTimeTrackerElement *)obtainTimeTrackerForEventType:(NSString *)eventType {
    MNBaseTimeTrackerElement *timeTrackerObj = [self getTimeTrackerForEventType:eventType];
    if (!timeTrackerObj) {
        timeTrackerObj = [[MNBaseTimeTrackerElement alloc] init];
    }
    return timeTrackerObj;
}

- (BOOL)addTimeTrackerObj:(MNBaseTimeTrackerElement *)timeTrackerObj forEventType:(NSString *)eventType {
    if (!(timeTrackerObj && eventType)) {
        return NO;
    }
    @synchronized(self) {
        [self.eventTimeTrackersDict setObject:timeTrackerObj forKey:eventType];
    }
    return YES;
}

#pragma mark - Formatting methods

- (NSDictionary *)getFormattedData {
    NSMutableDictionary *formattedData = [[NSMutableDictionary alloc] init];

    for (NSString *eventType in self.eventTimeTrackersDict) {
        MNBaseTimeTrackerElement *timeTrackerObj = [self getTimeTrackerForEventType:eventType];
        if (timeTrackerObj) {
            NSNumber *timeDiffInMillisObj = [timeTrackerObj getTimeDiffInMillis];
            if (timeDiffInMillisObj != nil) {
                [formattedData setObject:timeDiffInMillisObj forKey:eventType];
            }
        }
    }
    return formattedData;
}

- (BOOL)hasEntryForEvent:(NSString *)eventType {
    MNBaseTimeTrackerElement *timeTrackerObj = [self getTimeTrackerForEventType:eventType];
    if (timeTrackerObj) {
        // This check is just being over-cautious;
        // It'll positively, most likely, probably, sometimes - never happen :p
        if (timeTrackerObj.startTime != 0 || timeTrackerObj.endTime != 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasCompletedEntryForEvent:(NSString *)eventType {
    MNBaseTimeTrackerElement *timeTrackerObj = [self.eventTimeTrackersDict objectForKey:eventType];
    if (timeTrackerObj) {
        if (timeTrackerObj.startTime != 0 && timeTrackerObj.endTime != 0) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation MNBaseTimeTrackerElement

- (BOOL)setCurrentTimeForState:(MNBaseAdAnalyticsEventState)eventState {
    NSTimeInterval currentTimeInMillis = [[MNBaseUtil getTimestampInMillis] doubleValue];

    BOOL didSetTime = NO;
    switch (eventState) {
    case MNBaseAdAnalyticsEventStart: {
        if (self.startTime == 0) {
            self.startTime = currentTimeInMillis;
            didSetTime     = YES;
        }

        break;
    }
    case MNBaseAdAnalyticsEventEnd: {
        if (self.endTime == 0) {
            self.endTime = currentTimeInMillis;
            didSetTime   = YES;
        }
        break;
    }
    }

    return didSetTime;
}

- (NSNumber *)getTimeDiff {
    NSNumber *timeDiffMillis = [self getTimeDiffInMillis];
    if (timeDiffMillis != nil) {
        NSTimeInterval timeDiffInSeconds = [timeDiffMillis doubleValue] / 1000.0f;
        return [NSNumber numberWithDouble:timeDiffInSeconds];
    }

    return nil;
}

- (NSNumber *)getTimeDiffInMillis {
    if (self.timeDuration == 0 && (self.startTime == 0 || self.endTime == 0)) {
        return nil;
    } else if (self.timeDuration != 0) {
        return [NSNumber numberWithDouble:self.timeDuration];
    }

    NSTimeInterval timeDiffMillies = self.endTime - self.startTime;
    return [NSNumber numberWithDouble:timeDiffMillies];
}

@end
