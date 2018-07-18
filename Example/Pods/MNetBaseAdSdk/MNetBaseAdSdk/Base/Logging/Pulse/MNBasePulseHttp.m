//
//  MNBasePulseHttp.m
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBase.h"
#import "MNBaseConstants.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLog.h"
#import "MNBaseLogger.h"
#import "MNBasePulseEventName.h"
#import "MNBasePulseHttp+Internal.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseURL.h"
#import <MNetJSONModeller/MNJMManager.h>

@implementation MNBasePulseHttp
static MNBasePulseHttp *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBasePulseHttp alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self                  = [super init];
    _pulseStore           = [MNBasePulseStore getSharedInstanceWithDelegate:self];
    doNotMakeHttpRequests = NO;
    return self;
}

- (void)logEvent:(MNBasePulseEvent *)event {
    if (event == nil) {
        MNLogD(@"PULSE: Not loggin pulse event, got nil event");
        return;
    }
    NSArray *eventsList = [[NSArray alloc] initWithObjects:event, nil];
    if ([event.tag isEqualToString:MNBasePulseEventError]) {
        // Explicitly pushing pulse events to remote for pulseEventType - "error"
        [self makePulseRequestWithEvent:event];
    }
    [self logEventsWithArray:eventsList];
}

- (void)logEventsWithArray:(NSArray<MNBasePulseEvent *> *)eventsList {
    if (eventsList == nil || [eventsList count] == 0) {
        return;
    }
    NSArray<NSData *> *filteredEventsList = [self getFilteredDataEntriesFromPulseEventsList:eventsList];
    if (filteredEventsList == nil || [filteredEventsList count] == 0) {
        MNLogD(@"PULSE: Skipping events since filteredEventsList is empty!");
        return;
    }
    [self addEntriesIntoPulseStore:filteredEventsList];
}

- (void)addEntriesIntoPulseStore:(NSArray<NSData *> *)entries {
    if (entries == nil || [entries count] == 0) {
        MNLogD(@"No entries to add into the add store");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      @try {
          MNLogD(@"PULSE: Adding pulseEvents");
          [self.pulseStore addEntries:entries];
      } @catch (NSException *addEntryEx) {
          MNLogE(@"Exception when adding into the pulse-store - %@", addEntryEx);
      }
    });
}

- (void)checkForBatchHttp {
    [self.pulseStore runComparator];
}

- (void)makePulseRequestWithEvent:(MNBasePulseEvent *)event {
    if (event == nil) {
        MNLogD(@"PULSE: Not making api call, got nil pulse event");
        return;
    }
    NSArray *eventsList                = [[NSArray alloc] initWithObjects:event, nil];
    NSArray<NSData *> *filteredEntries = [self getFilteredDataEntriesFromPulseEventsList:eventsList];
    if (filteredEntries == nil || [filteredEntries count] == 0) {
        MNLogD(@"PULSE: Not making api call, got nil entries");
        return;
    }
    [self postPulseEventsForEntries:filteredEntries addBackToPulseStore:NO];
}

#pragma mark - PulseStoreDelegates
- (MNBasePulseStoreLimitType)comparatorWithFileSize:(NSUInteger)fileSize
                                         numEntries:(NSUInteger)numEntries
                             andTimeSinceFirstEntry:(NSTimeInterval)timestamp {
    NSUInteger maxNumOfEntries = [[[MNBaseSdkConfig getInstance] getPulseMaxArrLen] unsignedIntegerValue];
    NSUInteger maxFileSize     = [[[MNBaseSdkConfig getInstance] getPulseMaxSize] unsignedIntegerValue];
    NSTimeInterval maxNumSecs  = [[[MNBaseSdkConfig getInstance] getPulseMaxTimeInterval] longValue];

    BOOL numEntriesCheck          = (numEntries >= maxNumOfEntries);
    BOOL fileSizeCheck            = (fileSize >= maxFileSize);
    BOOL timeSinceFirstEntryCheck = (timestamp >= maxNumSecs);

    if (numEntriesCheck) {
        return kMNBasePulseNumEntriesLimit;
    } else if (fileSizeCheck) {
        return kMNBasePulseFileSizeLimit;
    } else if (timeSinceFirstEntryCheck) {
        return kMNBasePulseTimeLimit;
    }
    return kMNBasePulseNone;
}

- (void)limitExceeded:(MNBasePulseStoreLimitType)limitExceededType withEntries:(NSArray<NSData *> *)entries {
    if (entries == nil || [entries count] == 0) {
        MNLogD(@"PULSE: Limit exceeded but did not get any entries");
        return;
    }
    [self postPulseEventsForEntries:entries addBackToPulseStore:YES];
}

- (void)postPulseEventsForEntries:(NSArray<NSData *> *)entries addBackToPulseStore:(BOOL)addToPulseStore {
    if (entries == nil || [entries count] == 0) {
        MNLogD(@"PULSE: Not pushing pulse events to remote. No entries found");
        return;
    }

    NSMutableArray<MNBasePulseEvent *> *pulseEventsList = [[NSMutableArray<MNBasePulseEvent *> alloc] init];
    for (NSData *pulseData in entries) {
        @try {
            MNBasePulseEvent *pulseEvent = [NSKeyedUnarchiver unarchiveObjectWithData:pulseData];
            if (pulseEvent != nil) {
                [pulseEventsList addObject:pulseEvent];
            }
        } @catch (NSException *e) {
            MNLogD(@"PULSE: Exception when unarchiving data");
        }
    }

    NSString *requestBodyStr;
    @try {
        requestBodyStr = [MNJMManager toJSONStr:pulseEventsList];
    } @catch (NSException *e) {
        MNLogD(@"Exception when json parsing the data - %@", e);
    }

    if (requestBodyStr == nil || [requestBodyStr isEqualToString:@""]) {
        MNLogD(@"PULSE: Unable to send the json data since the request body is empty!");
        return;
    }
    NSString *url = [[MNBaseURL getSharedInstance] getPulseUrl];
    MNLogD(@"PULSE: request with body - %@", requestBodyStr);

    if (doNotMakeHttpRequests == YES) {
        MNLogD(@"### Stopping from making pulse request since doNotMakeHttpRequests is turned on!");
        return;
    }

    if (NO == [MNBaseHttpClient isInternetConnectivityPresent]) {
        MNLogD(@"### Stopping from making pulse request since internet-connectivity is absent!");
        return;
    }

    [MNBaseHttpClient doPostOn:url
        headers:nil
        params:nil
        body:requestBodyStr
        success:^(NSDictionary *response) {
          MNLogD(@"PULSE: Successfully called pulse request");
        }
        error:^(NSError *error) {
          MNLogD(@"PULSE: Failed calling the pulse request %@ ", error);
          if (addToPulseStore) {
              MNLogD(@"PULSE: Adding entries back into the pulse-store");
              [self addEntriesIntoPulseStore:entries];
          }
        }];
}

#pragma mark - Helpers

- (NSArray<NSData *> *)getFilteredDataEntriesFromPulseEventsList:(NSArray<MNBasePulseEvent *> *)eventsList {
    NSMutableArray<NSData *> *filteredEventsList = [NSMutableArray new];
    for (MNBasePulseEvent *event in eventsList) {
        if ([[self class] isRegulatedForPulseEvent:event]) {
            MNLogD(@"PULSE: Skipping regulated event - %@", [event tag]);
            continue;
        }
        @try {
            NSData *eventData = [NSKeyedArchiver archivedDataWithRootObject:event];
            if (eventData != nil) {
                [filteredEventsList addObject:eventData];
            }

        } @catch (NSException *e) {
            MNLogD(@"PULSE: Exception when converting the pulse-event to event-data");
        }
    }
    if ([filteredEventsList count] == 0) {
        MNLogD(@"PULSE: Skipping events since filteredEventsList is empty!");
        return nil;
    }
    return [filteredEventsList copy];
}

+ (BOOL)isRegulatedForPulseEvent:(MNBasePulseEvent *)pulseEvent {
    if ([[MNBase getInstance] appContainsChildDirectedContent] == NO || pulseEvent == nil) {
        return NO;
    }
    NSArray<NSString *> *regulatedEventTypes = [self getRegulatedPulseEvents];
    NSString *eventType                      = pulseEvent.tag;

    if (regulatedEventTypes == nil || [regulatedEventTypes count] == 0) {
        return NO;
    }

    if ([regulatedEventTypes containsObject:eventType]) {
        return YES;
    }
    return NO;
}

// These pulse-events need to be skipped if child-content-policy is on.
// This is basically a black-list.
static NSArray<NSString *> *regulatedPulseEvents;

+ (NSArray<NSString *> *)getRegulatedPulseEvents {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      regulatedPulseEvents = @[
          MNBasePulseEventNetwork,
          MNBasePulseEventDevice,
          MNBasePulseEventLocation,
          MNBasePulseEventDeviceLang,
          MNBasePulseEventTimezone,
          MNBasePulseEventAddress,
          MNBasePulseEventUserAgent,
      ];
    });
    return regulatedPulseEvents;
}

static BOOL doNotMakeHttpRequests = NO;
- (void)__stopFromMakingRequestsForTests {
    doNotMakeHttpRequests = YES;
}

@end
