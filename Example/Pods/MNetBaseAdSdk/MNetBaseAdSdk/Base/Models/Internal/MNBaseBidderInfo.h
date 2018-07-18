//
//  MNBaseBidderInfo.h
//  Pods
//
//  Created by nithin.g on 14/09/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseBidderInfoDetails.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseBidderInfo : NSObject <MNJMMapperProtocol>

@property (atomic) NSNumber *mainBid;
@property (atomic) NSNumber *bidderId;
@property (atomic) NSDictionary *bidInfo;
@property (atomic) NSString *providerRequestId;
@property (atomic) MNBaseBidderInfoDetails *bidInfoDetails;

/// Creates a bidderInfo instance and maps the required fields form the bid-response.
/// If the bidReponse is empty, will return nil
+ (instancetype _Nullable)createInstanceFromBidResponse:(MNBaseBidResponse *)bidResponse;

@end

NS_ASSUME_NONNULL_END
