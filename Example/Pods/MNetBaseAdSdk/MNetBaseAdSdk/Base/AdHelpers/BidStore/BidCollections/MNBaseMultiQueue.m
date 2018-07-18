//
//  MNBaseBidCollectionQueue.m
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseMultiQueue.h"
#import "MNBaseBidResponse.h"
#import "MNBaseLogger.h"

#define PRIMARY_DICT_TYPE NSString *, NSMutableDictionary<SECONDARY_DICT_TYPE> *
#define SECONDARY_DICT_TYPE NSString *, MNBaseQueue *

@interface MNBaseMultiQueue ()
@property (atomic) NSMutableDictionary<PRIMARY_DICT_TYPE> *queueMap;
@end

@implementation MNBaseMultiQueue

- (instancetype)init {
    self      = [super init];
    _queueMap = [[NSMutableDictionary<PRIMARY_DICT_TYPE> alloc] init];
    return self;
}

- (BOOL)pushData:(NSObject *_Nonnull)data
    withFirstKey:(NSString *_Nonnull)firstKey
    andSecondKey:(NSString *_Nonnull)secondKey {
    if (data == nil || firstKey == nil || secondKey == nil) {
        return NO;
    }

    NSMutableDictionary<SECONDARY_DICT_TYPE> *secondMap = [self.queueMap objectForKey:firstKey];
    if (secondMap == nil) {
        secondMap = [[NSMutableDictionary<SECONDARY_DICT_TYPE> alloc] init];
        [self.queueMap setObject:secondMap forKey:firstKey];
    }

    MNBaseQueue *queue = [secondMap objectForKey:secondKey];
    if (queue == nil) {
        queue = [[MNBaseQueue alloc] init];
        [secondMap setObject:queue forKey:secondKey];
    }
    MNLogD(@"BID_STORE: Adding %@ %@", firstKey, secondKey);
    return [queue enqueue:data];
}

/// Get the inner map for key
- (NSDictionary<NSString *, MNBaseQueue *> *_Nullable)getInnerMapForKey:(NSString *_Nonnull)key {
    if (key == nil) {
        return nil;
    }
    return [self.queueMap objectForKey:key];
}

- (NSArray<MNBaseQueue *> *_Nullable)getQueuesForFirstKey:(NSString *_Nonnull)firstKey {
    if (firstKey == nil) {
        return nil;
    }
    NSMutableDictionary<SECONDARY_DICT_TYPE> *secondMap = [self.queueMap objectForKey:firstKey];
    if (secondMap == nil) {
        return nil;
    }

    NSMutableArray<MNBaseQueue *> *queuesList =
        [[NSMutableArray<MNBaseQueue *> alloc] initWithCapacity:[secondMap count]];
    for (NSString *secondKey in secondMap) {
        MNBaseQueue *queue = [secondMap objectForKey:secondKey];
        if (queue != nil) {
            [queuesList addObject:queue];
        }
    }

    if ([queuesList count] == 0) {
        return nil;
    }
    return queuesList;
}

/// Get the queue for a specific key pair. Will return the first non-expired entry.
- (MNBaseQueue *_Nullable)getQueueForFirstKey:(NSString *_Nonnull)firstKey andSecondKey:(NSString *_Nonnull)secondKey {
    if (firstKey == nil || secondKey == nil) {
        return nil;
    }

    NSString *keyPath = [self combineFirstKey:firstKey andSecondKey:secondKey];
    return (MNBaseQueue *) [self.queueMap valueForKeyPath:keyPath];
}

- (void)flushQueueEntries {
    for (NSString *firstKey in self.queueMap) {
        NSMutableDictionary<SECONDARY_DICT_TYPE> *secondDict = [self.queueMap objectForKey:firstKey];
        [secondDict removeAllObjects];
    }

    [self.queueMap removeAllObjects];
}

#pragma mark - Helpers

- (NSString *_Nullable)combineFirstKey:(NSString *_Nonnull)firstKey andSecondKey:(NSString *_Nonnull)secondKey {
    if (firstKey == nil || secondKey == nil) {
        return nil;
    }

    return [NSString stringWithFormat:@"%@.%@", firstKey, secondKey];
}

/// Get the number of bids count per bid for specific ad-unit-id
- (NSDictionary<NSString *, NSNumber *> *_Nullable)getBidStoreCountForAdUnit:(NSString *_Nullable)adUnitId {
    NSMutableDictionary<SECONDARY_DICT_TYPE> *adUnitIdEntries = [self.queueMap objectForKey:adUnitId];
    if (adUnitIdEntries == nil || [adUnitIdEntries count] == 0) {
        return nil;
    }
    NSMutableDictionary<NSString *, NSNumber *> *bidStoreCountMap =
        [[NSMutableDictionary alloc] initWithCapacity:[adUnitIdEntries count]];
    for (NSString *bidderId in adUnitIdEntries) {
        MNBaseQueue *queueEntry = [adUnitIdEntries objectForKey:bidderId];
        NSNumber *queueLen      = [NSNumber numberWithLong:[queueEntry queueLen]];
        [bidStoreCountMap setValue:queueLen forKey:bidderId];
    }
    return [NSDictionary dictionaryWithDictionary:bidStoreCountMap];
}

/// Get the number of bids count per bid for all the ad-unit-ids
- (NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *_Nullable)getBidStoreCount {
    if (self.queueMap == nil || [self.queueMap count] == 0) {
        return nil;
    }

    NSMutableDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *bidStoreCountMap =
        [[NSMutableDictionary alloc] initWithCapacity:[self.queueMap count]];
    for (NSString *adUnitId in self.queueMap) {
        NSDictionary<NSString *, NSNumber *> *bidStoreCountMapForAdUnitId = [self getBidStoreCountForAdUnit:adUnitId];
        if (bidStoreCountMapForAdUnitId == nil) {
            continue;
        }
        [bidStoreCountMap setValue:bidStoreCountMapForAdUnitId forKey:adUnitId];
    }
    return [NSDictionary dictionaryWithDictionary:bidStoreCountMap];
}

@end
