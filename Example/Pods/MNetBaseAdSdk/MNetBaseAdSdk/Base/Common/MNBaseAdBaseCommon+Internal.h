//
//  MNBaseAdBaseCommon+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 04/05/18.
//

#ifndef MNBaseAdBaseCommon_Internal_h
#define MNBaseAdBaseCommon_Internal_h

#import "MNBaseAdBaseCommon.h"
#import "MNBaseBidResponsesContainer.h"

@interface MNBaseAdBaseCommon ()

@property (weak, atomic) id surrogateModule;

@property (atomic) NSURLSessionDataTask *onGoingTask;
// flags to monitor ad view status
@property (atomic) BOOL isInterstitial;
@property (atomic) BOOL isRefreshDisabled;
@property (atomic) BOOL isRefreshing;
@property (atomic) BOOL isAdxEnabled;
@property (atomic) MNBaseBidResponse *adxBidResponse;
@property (atomic) NSDictionary *serverExtrasDict;
@property (atomic) MNBaseBidResponsesContainer *responsesContainer;
@property (atomic) NSString *vcLink;
@property (atomic) BOOL isAdShown;
@property (atomic) BOOL isAdLoaded;
@property (atomic) BOOL isLoggingCallMade;
@property (atomic) NSLock *adViewLock;

@end

#endif /* MNBaseAdBaseCommon_Internal_h */
