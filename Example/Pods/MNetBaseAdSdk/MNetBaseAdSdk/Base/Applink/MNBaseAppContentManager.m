//
//  MNBaseAppContentManager.m
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseAppContentManager.h"
#import "MNBase.h"
#import "MNBaseAppContentCache.h"
#import "MNBaseAppContentEvent.h"
#import "MNBaseDataPrivacy.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import <MNALAppLink/MNALAppLink.h>

@interface MNBaseAppContentManager ()
@property (atomic) NSString *adUnitId;
@property (atomic) NSString *adCycleId;
@end

@implementation MNBaseAppContentManager

- (instancetype)initWithAdUnitId:(NSString *)adUnitId andAdCycleId:(NSString *)adCycleId {
    self           = [super init];
    self.adUnitId  = adUnitId;
    self.adCycleId = adCycleId;

    return self;
}

- (BOOL)sendContentForLink:(NSString *)originalCrawlingLink andViewController:(UIViewController *)viewController {
    if ([[MNBaseDataPrivacy getSharedInstance] doNoTrack]) {
        MNLogD(@"Not sending real-time-crawling data since doNotTrack is enabled!");
        return NO;
    }

    BOOL isContentSentAlready = [[MNBaseAppContentCache getSharedInstance] hasKey:originalCrawlingLink];
    if (isContentSentAlready) {
        MNLogD(@"APP_CONTENT: Content is already sent via pulse. Not resending it!");
        return YES;
    }

    BOOL doCrawlingLinksMatch = NO;
    if (!viewController) {
        MNLogD(@"APP_CONTENT: The given view controller is empty. Fetching the top view controlller");
        viewController = [MNBaseUtil getTopViewController];
    }

    NSNumber *startTime = [MNBaseUtil getTimestampInMillis];

    NSArray<NSString *> *skipList =
        [[MNBaseSdkConfig getInstance] fetchIntentSkipListForViewController:NSStringFromClass([viewController class])];
    NSInteger contentLimit = [[MNBaseSdkConfig getInstance] getIntentContentLimit];

    BOOL isTitleEnabled = [[MNBaseSdkConfig getInstance] isCrawledLinkTitleEnabled];

    MNALAppLink *appLink = [MNALAppLink getInstanceWithVC:viewController
                                       withContentEnabled:YES
                                       withIntentSkipList:skipList
                                             contentLimit:contentLimit
                                             titleEnabled:isTitleEnabled];

    NSNumber *endTime = [MNBaseUtil getTimestampInMillis];

    double contentFetchDuration = [endTime doubleValue] - [startTime doubleValue];

    NSString *VCLink = [appLink getLink];
    MNLogD(@"LINK: %@", VCLink);
    MNLogD(@"CONTENT: %@", [appLink getContent]);

    VCLink               = [VCLink lowercaseString];
    originalCrawlingLink = [originalCrawlingLink lowercaseString];

    if ([VCLink isEqualToString:originalCrawlingLink]) {
        doCrawlingLinksMatch = YES;

        NSString *content = [appLink getContent];

        if (content && ![content isEqualToString:@""]) {
            MNBaseAppContentEvent *contentEvent = [[MNBaseAppContentEvent alloc] init];
            contentEvent.content                = content;
            contentEvent.crawlerLink            = originalCrawlingLink;
            contentEvent.adCycleId              = self.adCycleId;
            contentEvent.adUnitId               = self.adUnitId;
            contentEvent.contentFetchDuration   = [NSNumber numberWithDouble:contentFetchDuration];

            MNLogD(@"APP_CONTENT: CONTENT - %@", [MNJMManager toJSONStr:contentEvent]);

            // Make the pulse request with the content
            [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventActivityContext andCustomData:contentEvent];
            [[MNBaseAppContentCache getSharedInstance] addKey:originalCrawlingLink];
        } else {
            MNLogD(@"APP_CONTENT: CONTENT IS EMPTY");
        }

    } else {
        MNLogD(@"APP_CONTENT: FETCHED LINK AND LINK FROM RESPONSE DON'T MATCH!");
        MNLogD(@"APP_CONTENT: FETCH - %@", VCLink);
        MNLogD(@"APP_CONTENT: RESP  - %@", originalCrawlingLink);
    }

    return doCrawlingLinksMatch;
}
@end
