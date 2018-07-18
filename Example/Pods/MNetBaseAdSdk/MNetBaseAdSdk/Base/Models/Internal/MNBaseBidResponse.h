//
//  BidResponse.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseBidResponseExtension.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseBidResponse : NSObject <MNJMMapperProtocol>

@property (atomic) NSNumber *bidderId;
@property (atomic) NSString *bidderName;
@property (atomic) NSString *providerRequestId;
@property (atomic) NSNumber *mainBid;
@property (atomic) NSDictionary *bidInfo;

@property (atomic) NSString *creativeId;
@property (atomic) NSString *creativeType;
@property (atomic) NSString *adType;
@property (atomic) NSString *adCode;
@property (atomic) NSString *adUrl;
@property (atomic) NSString *publisherId;
@property (atomic) NSString *auctionWinUrl;
@property (atomic) NSNumber *expiry;
@property (atomic) int varient;
@property (atomic) NSString *size;
@property (atomic) NSString *viewContextLink;
@property (atomic) NSString *viewControllerTitle;
@property (atomic) int height;
@property (atomic) int width;
@property (atomic) NSArray<NSString *> *loggingBeacons;
@property (atomic) NSDictionary *serverExtras;
@property (atomic) BOOL skippable;
@property (atomic) NSNumber *auctionBid;

@property (atomic) NSNumber *originalBidMultiplier1;
@property (atomic) NSNumber *originalBidMultiplier2;
@property (atomic) NSNumber *dfpBidMultiplier1;
@property (atomic) NSNumber *dfpBidMultiplier2;

@property (atomic) NSNumber *bid;
@property (atomic) NSNumber *dfpbid;
@property (atomic) NSNumber *ogBid;
@property (atomic) NSString *bidType;
@property (atomic) NSString *predictionId;
@property (atomic) NSString *responseType;

@property (atomic) NSNumber *cbdp;
@property (atomic) NSNumber *clsprc;

@property (atomic) NSString *keywords;

@property (atomic) NSArray<NSString *> *elogs;

@property (atomic) MNBaseBidResponseExtension *extension;

- (void)setVisitId:(NSString *)visitId;
- (void)setAdCycleId:(NSString *)adCycleId;

- (NSString *)getVisitId;
- (NSString *)getAdCycleId;
- (BOOL)isYBNCBidder;
// Fetch the raw, non-macro-replaced ad-code
- (NSString *)getRawAdCode;
@end
