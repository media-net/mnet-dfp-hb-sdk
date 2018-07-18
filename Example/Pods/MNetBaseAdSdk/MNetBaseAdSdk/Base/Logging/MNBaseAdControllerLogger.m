//
//  MNBaseAdControllerLogger.m
//  Pods
//
//  Created by nithin.g on 09/06/17.
//
//

#import "MNBaseAdControllerLogger.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

@interface MNBaseAdControllerLogger ()
@property (atomic) NSArray<NSString *> *loggingUrls;
@property (atomic) NSString *pulseLoggerKey;

@end

@implementation MNBaseAdControllerLogger

- (instancetype)initWithLoggingUrls:(NSArray *)loggingUrls withPulseLoggerKey:(NSString *)pulseKey {
    self                = [super init];
    self.loggingUrls    = loggingUrls;
    self.pulseLoggerKey = pulseKey;
    return self;
}

- (void)updateUrlsWithReplacementList:(NSArray *)replacementList {
    self.loggingUrls = [MNBaseUtil replaceItemsInUrlsList:self.loggingUrls withReplacementList:replacementList];
}

- (void)makeRequestsAfterReplacement:(NSArray *)replacementList {
    NSArray *updatedLoggingUrls =
        [MNBaseUtil replaceItemsInUrlsList:self.loggingUrls withReplacementList:replacementList];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      @try {
          [self makeRequestForUrls:updatedLoggingUrls];
          [MNBasePulseTracker logRemoteCustomEventType:self.pulseLoggerKey
                                         andCustomData:@{@"data" : updatedLoggingUrls}];
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - makeRequestsAfterReplacement %@", e);
      }
    });
}

- (void)makeRequestForUrls:(NSArray *)loggerUrls {
    for (NSString *url in loggerUrls) {
        MNLogD(@"VIDEO_AD: Firing %@", url);
        MNLogD(@"VLOGGER_URL: Firing %@", url);

        [MNBaseHttpClient doGetWithStrResponseOn:url
            headers:nil
            shouldRetry:YES
            success:^(NSString *_Nonnull responseDict) {
              MNLogD(@"Logging url fired - %@", url);
            }
            error:^(NSError *_Nonnull error) {
              MNLogD(@"Logging url failed - %@", url);
              MNLogD(@"Logging url error  - %@", error);
            }];
    }
}

@end
