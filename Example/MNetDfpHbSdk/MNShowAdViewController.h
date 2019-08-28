//
//  MNShowAdViewController.h
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]
@import GoogleMobileAds;

@interface MNShowAdViewController
    : UIViewController <GADBannerViewDelegate, GADInterstitialDelegate, GADAdSizeDelegate, GADAdLoaderDelegate,
                        DFPBannerAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate>

typedef enum {
    DFP_BANNER_MANUAL_HB,
    DFP_INSTERSTITIAL_MANUAL_HB,
    GAD_DFP,
    MNET_AUTOMATION_DFP_ADVIEW,
} AdType;

@property (nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (nonatomic) AdType adType;
@property BOOL isInterstital;

@end
