//
//  MNBaseAdImpression.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdSize.h"
#import "MNBaseBannerAdRequest.h"
#import "MNBaseVideoAdRequest.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdImpression : NSObject <MNJMMapperProtocol>

#define TYPE_DEFAULT 0;
#define TYPE_INTERSTITIAL 1;

@property (atomic) NSString *adUnitId;
@property (atomic) int type; // 1 if ad is interstitial, 0 otherwise
@property (atomic) int isSecure;
@property (atomic) MNBaseBannerAdRequest *banner;
@property (atomic) MNBaseVideoAdRequest *video;
@property (atomic) NSNumber *clickThroughToBrowser;

+ (MNBaseAdImpression *)newInstance;

@end
