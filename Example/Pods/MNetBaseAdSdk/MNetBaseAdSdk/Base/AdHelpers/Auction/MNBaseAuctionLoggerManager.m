//
//  MNBaseAuctionLoggerManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import "MNBaseAuctionLoggerManager.h"
#import "MNBaseAuctionLoggerRequest.h"
#import "MNBaseError.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUrl.h"
#import "MNBaseUtil.h"

@implementation MNBaseAuctionLoggerManager

static MNBaseAuctionLoggerManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseAuctionLoggerManager alloc] init];
    });
    return instance;
}

- (void)makeAuctionLoggerRequestFromResponsesContainer:(MNBaseBidResponsesContainer *)responsesContainer
                                 withAuctionLogsStatus:(MNBaseAuctionLogsStatus *)auctionLogsStatus
                                         withSuccessCb:(void (^_Nullable)(void))successCb
                                              andErrCb:(void (^_Nullable)(NSError *))errCb {
    if (responsesContainer == nil) {
        NSError *nilErr =
            [MNBaseError createErrorWithDescription:
                             @"Aborting auction-logger-request. Responses-container does not contain required data."];
        errCb(nilErr);
        return;
    }

    NSString *loggerRequestStr;

    MNBaseAuctionLoggerRequest *loggerRequest =
        [[MNBaseAuctionLoggerRequest alloc] initFromBidResponseContainer:responsesContainer];
    if (loggerRequest) {
        if (auctionLogsStatus == nil) {
            auctionLogsStatus = [MNBaseAuctionLogsStatus new];
        }
        [loggerRequest setLogsStatus:auctionLogsStatus];
        loggerRequestStr = [MNJMManager toJSONStr:loggerRequest];
    }

    NSString *adCycleId = loggerRequest.adCycleId;
    MNLogD(@"DEBUG_LOGS: Making auction-log for adCycleId - %@ - %@", adCycleId,
           [MNJMManager toJSONStr:auctionLogsStatus]);

    if (loggerRequest == nil || loggerRequestStr == nil) {
        NSError *nilErr = [MNBaseError createErrorWithDescription:@"Could not create auction-logger-request"];
        errCb(nilErr);
        return;
    }

    // Make the request
    NSString *auctionUrl  = [[MNBaseURL getSharedInstance] getAuctionLoggerUrl];
    NSDictionary *headers = nil;
    MNLogD(@"DEBUG_LOGS: Making auction-log with request params - %@", loggerRequestStr);

    if ([MNBaseUtil canMakeGetRequestFromBody:loggerRequestStr]) {
        NSDictionary *params;
        if (loggerRequestStr != nil) {
            params = @{@"request" : loggerRequestStr};
        }
        MNLogD(@"Auction log call: Making get request");
        [MNBaseHttpClient doGetOn:auctionUrl
            headers:headers
            params:params
            success:^(NSDictionary *_Nonnull responseDict) {
              MNLogD(@"DEBUG_LOGS: Success making auction-log-request");
              successCb();
            }
            error:^(NSError *_Nonnull reqErr) {
              MNLogD(@"DEBUG_LOGS: Error making auction-log-request - %@", reqErr);
              errCb(reqErr);
            }];
    } else {
        MNLogD(@"Auction log call: Making post request");
        [MNBaseHttpClient doPostOn:auctionUrl
            headers:headers
            params:nil
            body:loggerRequestStr
            success:^(NSDictionary *_Nonnull responseDict) {
              MNLogD(@"DEBUG_LOGS: Success making auction-log-request");
              successCb();
            }
            error:^(NSError *_Nonnull reqErr) {
              MNLogD(@"DEBUG_LOGS: Error making auction-log-request - %@", reqErr);
              errCb(reqErr);
            }];
    }
}

@end
