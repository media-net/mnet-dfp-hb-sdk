//
//  MNBaseBidStore.m
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseBidStore.h"
#import "MNBaseBidStoreImpl.h"

@implementation MNBaseBidStore

static id<MNBaseBidStoreProtocol> bidStore;

/// Get the default bid-store
+ (id<MNBaseBidStoreProtocol>)getStore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      bidStore = [[MNBaseBidStoreImpl alloc] init];
    });
    return bidStore;
}

@end
