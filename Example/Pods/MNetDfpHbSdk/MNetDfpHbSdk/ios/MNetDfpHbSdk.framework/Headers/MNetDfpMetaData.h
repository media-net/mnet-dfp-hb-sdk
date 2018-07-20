//
//  MNetDfpMetaData.h
//  MNetDfpHbSdk
//
//  Created by nithin.g on 11/07/18.
//

#import "GoogleMobileAds/DFPBannerView.h"
#import "GoogleMobileAds/DFPInterstitial.h"
#import "GoogleMobileAds/DFPRequest.h"
#import <Foundation/Foundation.h>

@interface MNetDfpMetaData : NSObject
NS_ASSUME_NONNULL_BEGIN

@property (atomic) NSString *adUnitId;
@property (atomic) NSArray<NSValue *> *validAdSizes;
@property (atomic) UIViewController *rootVC;
@property (atomic) BOOL isInterstitial;
@property (atomic) DFPBannerView *dfpBannerAdView;
@property (atomic) DFPInterstitial *dfpInterstitialAd;
@property (atomic) DFPRequest *dfpAdRequest;

+ (id _Nullable)createBannerWithAdView:(DFPBannerView *)dfpBannerAdView
                             adRequest:(DFPRequest *)dfpAdRequest
                              adUnitId:(NSString *)adUnitId
                          validAdSizes:(NSArray<NSValue *> *)validAdSizes
                                rootVC:(UIViewController *)rootVC;

+ (id _Nullable)createInterstitialWithAd:(DFPInterstitial *)dfpInterstitialAd
                               adRequest:(DFPRequest *)dfpAdRequest
                                adUnitId:(NSString *)adUnitId;

NS_ASSUME_NONNULL_END
@end
