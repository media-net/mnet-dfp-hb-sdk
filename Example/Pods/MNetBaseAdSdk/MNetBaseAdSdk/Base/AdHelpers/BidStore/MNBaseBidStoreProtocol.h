//
//  MNBaseBidStoreProtocol.h
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseAdSize.h"
#import "MNBaseBidResponse.h"
#import <Foundation/Foundation.h>

#define BID_STORE_COUNT_MAP_TYPE NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *

@protocol MNBaseBidStoreProtocol <NSObject>

/// Insert into store
- (BOOL)insert:(MNBaseBidResponse *_Nonnull)response;

/// Fetch for ad-unit-id and ad sizes from store. Returns nil if not available
- (NSArray<MNBaseBidResponse *> *_Nullable)fetchForAdUnitId:(NSString *_Nonnull)adUnitId
                                                withAdSizes:(NSArray<MNBaseAdSize *> *_Nullable)sizes
                                                  andReqUrl:(NSString *_Nullable)reqUrl;

/// Removes all the contents in the store, and reinitializes it
- (void)flushStore;

/// Get the number of bids count per bid for specified ad-unit-id
- (BID_STORE_COUNT_MAP_TYPE _Nullable)getBidStoreCountForAdUnit:(NSString *_Nullable)adUnitId;

/// Get the number of bids count per bid for all the ad-unit-ids in the bid-store
- (BID_STORE_COUNT_MAP_TYPE _Nullable)getBidStoreCount;

@end
