//
//  MNBaseDefaultBidsDataStore.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseDefaultBidsDataStore+Internal.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

static const char *QUEUE_NAME = "net.media.defaultBidsDataStore";

@implementation MNBaseDefaultBidsDataStore

static MNBaseDefaultBidsDataStore *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [MNBaseDefaultBidsDataStore new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultBidsStore        = [BIDDER_MAP_TYPE new];
        _dataStoreReadWriteQueue = dispatch_queue_create(QUEUE_NAME, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (BOOL)addDefaultBids:(NSArray<MNBaseDefaultBid *> *)defaultBidsList {
    __block BOOL additionSuccess = YES;
    dispatch_barrier_sync(self.dataStoreReadWriteQueue, ^{
      [self flushStore];
      for (MNBaseDefaultBid *bid in defaultBidsList) {
          BOOL failureStatus = [self addDefaultBid:bid];
          additionSuccess    = additionSuccess && failureStatus;
      }
    });
    return additionSuccess;
}

- (BOOL)addDefaultBid:(MNBaseDefaultBid *)defaultBid {
    if (defaultBid == nil) {
        return NO;
    }
    __block NSNumber *bidderId = defaultBid.bidderId;
    __block NSString *adUnitId = defaultBid.adUnitId;

    if (bidderId == nil || adUnitId == nil || [adUnitId isEqualToString:@""]) {
        return NO;
    }
    AD_UNIT_MAP_TYPE *adUnitMap = [self.defaultBidsStore objectForKey:bidderId];
    if (adUnitMap == nil) {
        adUnitMap = [AD_UNIT_MAP_TYPE new];
        [adUnitMap setObject:[DEFAULT_BIDS_ARR_TYPE new] forKey:adUnitId];
        [self.defaultBidsStore setObject:adUnitMap forKey:bidderId];
    }

    DEFAULT_BIDS_ARR_TYPE *defaultBidsList = [adUnitMap objectForKey:adUnitId];
    if (defaultBidsList == nil) {
        defaultBidsList = [DEFAULT_BIDS_ARR_TYPE new];
        [adUnitMap setObject:defaultBidsList forKey:adUnitId];
    }
    [defaultBidsList addObject:defaultBid];
    return YES;
}

- (NSArray<MNBaseBidResponse *> *)getBidResponsesForAdUnitId:(NSString *)adUnitId andContextUrl:(NSString *)contextUrl {
    if (adUnitId == nil || [adUnitId isEqualToString:@""] || contextUrl == nil) {
        return nil;
    }
    __block NSMutableArray<MNBaseBidResponse *> *filteredBidResponsesList = [NSMutableArray new];
    dispatch_sync(self.dataStoreReadWriteQueue, ^{
      for (NSNumber *bidderId in self.defaultBidsStore) {
          AD_UNIT_MAP_TYPE *adUnitIdMap              = [self.defaultBidsStore objectForKey:bidderId];
          DEFAULT_BIDS_ARR_TYPE *bidsForAdUnitIdList = [adUnitIdMap objectForKey:adUnitId];

          DEFAULT_BIDS_ARR_TYPE *adUnitFilteredDefaultBids = [DEFAULT_BIDS_ARR_TYPE new];
          if (bidsForAdUnitIdList != nil) {
              [adUnitFilteredDefaultBids addObjectsFromArray:bidsForAdUnitIdList];
          }

          if (NO == [adUnitId isEqualToString:WILDCARD]) {
              DEFAULT_BIDS_ARR_TYPE *bidsForWildcardList = [adUnitIdMap objectForKey:WILDCARD];
              if (bidsForWildcardList != nil) {
                  [adUnitFilteredDefaultBids addObjectsFromArray:bidsForWildcardList];
              }
          }

          MNBaseBidResponse *filteredBidResponse =
              [self applyFiltersOnDefaultBids:adUnitFilteredDefaultBids withContextUrl:contextUrl];
          if (filteredBidResponse != nil) {
              [filteredBidResponsesList addObject:filteredBidResponse];
          }
      }

      if ([filteredBidResponsesList count] == 0) {
          filteredBidResponsesList = nil;
      }
    });
    return filteredBidResponsesList;
}

- (MNBaseBidResponse *)applyFiltersOnDefaultBids:(DEFAULT_BIDS_ARR_TYPE *)defaultBidsList
                                  withContextUrl:(NSString *)contextUrl {
    NSInteger maxBid              = -1;
    MNBaseDefaultBid *filteredBid = nil;

    for (MNBaseDefaultBid *defaultBid in defaultBidsList) {
        NSString *contextUrlRegex = [defaultBid contextUrlRegex];
        if (NO == [MNBaseUtil doesStrMatch:contextUrl regexStr:contextUrlRegex]) {
            continue;
        }
        if ([[defaultBid bid] integerValue] > maxBid) {
            filteredBid = defaultBid;
            maxBid      = [[filteredBid bid] integerValue];
        }
    }
    if (filteredBid == nil) {
        return nil;
    }
    MNBaseBidResponse *filteredBidResponse = [filteredBid bidResponse];
    return filteredBidResponse;
}

/// Clean the data-store
- (BOOL)flushStore {
    self.defaultBidsStore = [BIDDER_MAP_TYPE new];
    return YES;
}

@end
