//
//  MNBaseSdkConfigData.h
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseLoaders.h"
#import "MNBaseSdkConfigVCLinks.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseSdkConfigData : NSObject <MNJMMapperProtocol>

@property (atomic) MNJMBoolean *isRefreshAdEnabled;
@property (atomic) MNJMBoolean *mnetAdexOnThirdpartyEnabled;
@property (atomic) MNJMBoolean *mnetFireVideoEvents;
@property (atomic) float mnetMaxDfpVersionSupport;
@property (atomic) NSUInteger pulseMaxArrLen;
@property (atomic) NSUInteger pulseMaxSize;
@property (atomic) NSUInteger pulseMaxTimeInterval;
@property (atomic) NSUInteger locationUpdateInterval;
@property (atomic) NSUInteger appTrackerTimerInterval;
@property (atomic) float appStoreUpdateInterval;
@property (atomic) NSUInteger adViewCacheCleanInterval;
@property (atomic) NSUInteger adViewCacheDuration;
@property (atomic) NSUInteger appStoreMinNumerOfEntries;
@property (atomic) NSUInteger appStoreMaxNumerOfEntries;
@property (atomic) NSUInteger rewardedInstanceMaxAge;
@property (atomic) NSUInteger cacheMaxAge;
@property (atomic) NSUInteger cacheFileMaxSize;
@property (atomic) MNJMBoolean *isVideoAutoPlayEnabled;
@property (atomic) NSString *refreshAdDurationSec;
@property (atomic) MNBaseSdkConfigVCLinks *viewControllerLinks;
@property (atomic) MNJMBoolean *shouldMakeHttpRequests;
@property (atomic) float mnetSlotDebugRate;
@property (atomic) NSNumber *mnetConfigUpdateInterval;
@property (atomic) NSString *mnetAmMt;
@property (atomic) MNBaseLoaders *loaders;
@property (atomic) NSNumber *mnetNetworkRetryCount;
@property (atomic) NSNumber *urlLengthMax;
@property (atomic) MNJMBoolean *isEu;
@property (atomic) NSArray<NSString *> *mnetEuCc;
@property (atomic) NSString *ccAlpha2;
@property (atomic) NSString *ccAlpha3;
@property (atomic) NSNumber *gdprVendorId;
@property (atomic) NSArray<NSString *> *useWkwebviewForIosVersion;
@end
