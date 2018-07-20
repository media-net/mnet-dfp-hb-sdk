//
//  MNBaseHbConfigData.h
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseAdUnitConfigData.h"
#import "MNBaseDefaultBid.h"
#import "MNBaseLoaders.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseHbConfigData : NSObject <MNJMMapperProtocol>
@property (atomic) MNJMBoolean *isEnabled;
@property (atomic) NSArray<MNBaseAdUnitConfigData *> *adUnitConfigDataList;
@property (atomic) MNBaseLoaders *loaders;
@property (atomic) MNJMBoolean *adViewReuseEnabled;
@property (atomic) NSNumber *adViewReuseCacheTimeout;
@property (atomic) NSNumber *adViewReuseCacheMaxSize;
@property (atomic) NSArray<MNBaseDefaultBid *> *defaultBids;
@property (atomic) MNJMBoolean *inAppBrowsingEnabled;
@property (atomic) MNJMBoolean *isRtcEnabled;
@property (atomic) NSNumber *ybncaAdTimeout;
@property (atomic) MNJMBoolean *shouldShimmer;
/*
 Automatic HB is swizzling the methods of DFP and MoPub ad-request classes.
 The swizzling of the methods will only happen if isAutoHbEnabled is true.
 */
@property (atomic) MNJMBoolean *isAutoHbEnabled;
@property (atomic) MNJMBoolean *isAutoHbDfpEnabled;
@property (atomic) MNJMBoolean *isAutoHbMopubEnabled;

@property (atomic) MNJMBoolean *appendKeywordsRequrl;
@property (atomic) MNJMBoolean *mnetAgBidEnabled;
@property (atomic) MNJMBoolean *euDoNotTrack;
@property (atomic) MNJMBoolean *isSwizzlingVcEnabled;

@property (atomic) MNJMBoolean *isPulseEnabled;
@property (atomic) NSArray<NSString *> *pulseWhiteList;
@end
