//
//  MNBaseBidStore.h
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseBidStoreProtocol.h"
#import <Foundation/Foundation.h>

@interface MNBaseBidStore : NSObject

/// Get the current bid-store
+ (id<MNBaseBidStoreProtocol>)getStore;

- (instancetype)init __attribute__((unavailable("Use [MNBaseBidStore getStore]")));

@end
