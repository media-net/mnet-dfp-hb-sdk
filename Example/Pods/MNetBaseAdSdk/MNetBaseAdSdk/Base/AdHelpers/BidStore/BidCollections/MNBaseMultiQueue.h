//
//  MNBaseBidCollectionQueue.h
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseQueue.h"
#import <Foundation/Foundation.h>

@interface MNBaseMultiQueue : NSObject

/// Add data in the multi-queue, for the corresponding keys.
- (BOOL)pushData:(NSObject *_Nonnull)data
    withFirstKey:(NSString *_Nonnull)firstKey
    andSecondKey:(NSString *_Nonnull)secondKey;

/// Get the queue for every second-key contained within the first key.
- (NSArray<MNBaseQueue *> *_Nullable)getQueuesForFirstKey:(NSString *_Nonnull)firstKey;

/// Get the queue for a specific key pair. Will return the first non-expired entry.
- (MNBaseQueue *_Nullable)getQueueForFirstKey:(NSString *_Nonnull)firstKey andSecondKey:(NSString *_Nonnull)secondKey;

- (void)flushQueueEntries;

/// Get the number of bids count per bid for specific ad-unit-id
- (NSDictionary<NSString *, NSNumber *> *_Nullable)getBidStoreCountForAdUnit:(NSString *_Nullable)adUnitId;

/// Get the number of bids count per bid for all the ad-unit-ids
- (NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *_Nullable)getBidStoreCount;

/// Get the inner map for key
- (NSDictionary<NSString *, MNBaseQueue *> *_Nullable)getInnerMapForKey:(NSString *_Nonnull)key;

@end
