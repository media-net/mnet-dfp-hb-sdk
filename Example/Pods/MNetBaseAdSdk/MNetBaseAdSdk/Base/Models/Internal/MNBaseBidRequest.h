//
//  MNBaseBidRequest.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdCapability.h"
#import "MNBaseAdDetails.h"
#import "MNBaseAdImpression.h"
#import "MNBaseAdRequest+Internal.h"
#import "MNBaseBidderInfo.h"
#import "MNBaseDeviceInfo.h"
#import "MNBaseExtBidRequest.h"
#import "MNBaseHostAppInfo.h"
#import "MNBaseRequestRegulation.h"
#import "MNBaseUser.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNBaseBidRequest : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *viewControllerTitle;

@property (atomic) MNBaseHostAppInfo *hostAppInfo;

@property (atomic) MNBaseDeviceInfo *deviceInfo;

@property (atomic) MNBaseAdCapability *adCapability;

@property (atomic) NSMutableArray<MNBaseAdImpression *> *adImpressions;

@property (atomic) NSNumber *test;

@property (atomic) NSString *visitId;

@property (atomic) NSString *adCycleId;

@property (atomic) NSString *uuid;

@property (atomic) MNBaseAdDetails *adDetails;

@property (atomic) MNBaseUser *userDetails;

@property (atomic) MNJMBoolean *prefetchEnabledBidder;

@property (atomic) MNBaseRequestRegulation *requestRegulation;

@property (atomic) NSArray<MNBaseBidderInfo *> *bidders;

@property (atomic) NSDictionary *cachedBidInfoMap;

@property (atomic) NSString *sdkVersionName;

@property (atomic) NSNumber *sdkVersionCode;

@property (atomic) NSNumber *gdpr;

@property (atomic) NSNumber *gdprconsent;

@property (atomic) NSString *gdprstring;

@property (atomic) MNBaseExtBidRequest *ext;

+ (MNBaseBidRequest *_Nullable)create:(MNBaseAdRequest *)adRequest;

- (NSString *_Nullable)fetchAdUnitId;

- (NSString *_Nullable)fetchPublisherId;

- (NSString *_Nullable)fetchContextUrl;

- (NSString *_Nullable)fetchKeywords;

- (NSArray<MNBaseAdSize *> *_Nullable)fetchAdSizes;

@end

NS_ASSUME_NONNULL_END
