//
//  MNetHeaderBidder.h
//  MNetDfpHbSdk
//
//  Created by nithin.g on 09/07/18.
//

#import "GoogleMobileAds/DFPBannerView.h"
#import "GoogleMobileAds/DFPInterstitial.h"
#import "GoogleMobileAds/DFPRequest.h"
#import <Foundation/Foundation.h>

/// The class that describes all the Manual Header-Bidding methods
@interface MNetDfpBidder : NSObject
NS_ASSUME_NONNULL_BEGIN
/// Add bids manually to the dfp banner adview
/// This will modify the existing dfpView object and
/// return it in completion callback (completionCb)
+ (NSError *_Nullable)addBidsToDfpBannerAdRequest:(DFPRequest *)bannerRequest
                                       withAdView:(DFPBannerView *)dfpView
                                 withCompletionCb:(void (^)(DFPRequest *_Nullable, NSError *_Nullable))completionCb;

/// Add bids manually to the dfp interstitial adview
/// This will modify the existing dfpView object and
/// return it in completion callback (completionCb)
+ (NSError *_Nullable)addBidsToDfpInterstitialAdRequest:(DFPRequest *)interstitialRequest
                                             withAdView:(DFPInterstitial *)dfpView
                                       withCompletionCb:
                                           (void (^)(DFPRequest *_Nullable, NSError *_Nullable))completionCb;

/// Add bids manually to the dfp request with ad loader object
/// This will modify the existing dfp request object and
/// return it in completion callback (completionCb)
+ (NSError *_Nullable)addBidsToAdRequest:(DFPRequest *)dfpAdRequest
                         withGADAdLoader:(GADAdLoader *)adLoader
                             withAdSizes:(NSArray *)adSizes
                      rootViewController:(UIViewController *)rootVC
                   withCompletionHandler:
                       (void (^)(DFPRequest *_Nullable, GADAdLoader *_Nullable, NSError *_Nullable))completionCb;

NS_ASSUME_NONNULL_END
@end
