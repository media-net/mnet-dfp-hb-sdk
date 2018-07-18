//
//  MNBaseResponseProcessorCrawlingDetails.m
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseProcessorCrawlingDetails.h"
#import "MNBaseAppContentManager.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"

@implementation MNBaseResponseProcessorCrawlingDetails

- (void)processResponse:(NSDictionary *)response withResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    // Check if Real time crawling enabled
    // Silently return if real time crawling is disabled
    if ([[MNBaseSdkConfig getInstance] isRealTimeCrawlingEnabled] == NO) {
        return;
    }

    MNLogD(@"APP_CONTENT: *******************");
    NSString *adUnitId;
    NSString *adCycleId;
    UIViewController *viewController;

    if (responseExtras != nil) {
        adUnitId       = responseExtras.adUnitId;
        adCycleId      = responseExtras.adCycleId;
        viewController = responseExtras.viewController;
    }

    if (adUnitId == nil || viewController == nil) {
        MNLogD(@"adUnitId, adCycleId and viewController all have to be non-nil for "
               @"MNBaseResponseProcessorCrawlingDetails");
        return;
    }

    // Fetch the Crawling details
    NSString *crawledUrl;
    NSNumber *isCrawledObj;
    NSDictionary *ext = [response objectForKey:@"ext"];
    if (ext != nil && [ext count] > 0) {
        crawledUrl   = [response objectForKey:@"cl"];
        isCrawledObj = [response objectForKey:@"cc"];
    }
    if (isCrawledObj == nil || crawledUrl == nil) {
        MNLogD(@"APP_CONTENT: CRAWLED OBJECT(CC) OR CRAWLING URL(CL) IS NOT AVAILABLE");
        if (isCrawledObj == nil) {
            MNLogD(@"APP_CONTENT: CC from server is nil");
        } else {
            MNLogD(@"APP_CONTENT: CC: %@", isCrawledObj);
        }

        if (crawledUrl == nil) {
            MNLogD(@"APP_CONTENT: CL from server is nil");
        } else {
            MNLogD(@"APP_CONTENT: CL: %@", crawledUrl);
        }
        return;
    }

    BOOL isCrawled = [isCrawledObj boolValue];
    MNLogD(@"APP_CONTENT: IS ALREADY CRAWLED : %@", (isCrawled) ? @"YES" : @"NO");

    if (isCrawled == NO) {
        MNBaseAppContentManager *contentManager =
            [[MNBaseAppContentManager alloc] initWithAdUnitId:adUnitId andAdCycleId:adCycleId];
        [contentManager sendContentForLink:crawledUrl andViewController:viewController];
    }
}

@end
