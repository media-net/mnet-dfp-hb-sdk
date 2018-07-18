//
//  MNBaseBidStoreImpl.h
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseBidStoreProtocol.h"
#import "MNBaseQueue.h"
#import <Foundation/Foundation.h>

@interface MNBaseBidStoreImpl : NSObject <MNBaseBidStoreProtocol>

- (NSArray<MNBaseBidResponse *> *)getBidsForAdSizes:(NSArray<MNBaseAdSize *> *)sizes
                                           fromList:(NSArray<MNBaseBidResponse *> *)adSizesList;

@end
