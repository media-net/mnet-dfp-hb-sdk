//
//  MNBaseAdLoaderPrefetchPredictBids+Internal.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 07/11/17.
//

#ifndef MNBaseAdLoaderPrefetchPredictBids_Internal_h
#define MNBaseAdLoaderPrefetchPredictBids_Internal_h

#import "MNBaseAdLoaderPrefetchPredictBids.h"

@interface MNBaseAdLoaderPrefetchPredictBids ()
@property (atomic) NSString *adUnitId;
@property (atomic) NSString *adCycleId;
@property (atomic) NSString *visitId;
@property (atomic) NSString *contextUrl;
@property (atomic) UIViewController *viewController;
@property (atomic) NSString *keywords;

- (void)updateBidRequestWithBidCounts:(MNBaseBidRequest *)bidRequest;
@end

#endif /* MNBaseAdLoaderPrefetchPredictBids_Internal_h */
