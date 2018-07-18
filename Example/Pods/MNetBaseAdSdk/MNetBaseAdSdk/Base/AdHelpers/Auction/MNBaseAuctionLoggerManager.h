//
//  MNBaseAuctionLoggerManager.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 24/10/17.
//

#import "MNBaseAuctionLogsStatus.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseAuctionLoggerManager : NSObject

+ (instancetype)getSharedInstance;

- (void)makeAuctionLoggerRequestFromResponsesContainer:(MNBaseBidResponsesContainer *)responsesContainer
                                 withAuctionLogsStatus:(MNBaseAuctionLogsStatus *)auctionLogsStatus
                                         withSuccessCb:(void (^_Nullable)(void))successCb
                                              andErrCb:(void (^_Nullable)(NSError *))errCb;

@end

NS_ASSUME_NONNULL_END
