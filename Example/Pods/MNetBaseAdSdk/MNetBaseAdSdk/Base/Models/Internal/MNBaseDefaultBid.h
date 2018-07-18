//
//  MNBaseDefaultBids.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseBidResponse.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseDefaultBid : NSObject <MNJMMapperProtocol>
@property (nonnull) NSNumber *bid;
@property (nonnull) NSNumber *bidderId;
@property (nonnull) NSString *contextUrlRegex;
@property (nonnull) NSString *adUnitId;
@property (nonnull) MNBaseBidResponse *bidResponse;
@end
