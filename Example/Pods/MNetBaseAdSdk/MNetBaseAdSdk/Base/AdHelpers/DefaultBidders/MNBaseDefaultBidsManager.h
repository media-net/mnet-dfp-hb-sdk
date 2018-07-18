//
//  MNBaseDefaultBiddersManager.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseBidResponse.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

/*
 NOTE: The point of the default-bids-manager is to perform the CSA within itself
 */
@interface MNBaseDefaultBidsManager : NSObject

+ (instancetype _Nonnull)getSharedInstance;

/// Get the default bids for the current bid-request
- (MNBaseBidResponsesContainer *_Nullable)getDefaultBidsForBidRequest:(MNBaseBidRequest *_Nonnull)bidRequest;

- (instancetype _Nullable)init __attribute__((unavailable("Please use getSharedInstance to get shared-object")));

@end
