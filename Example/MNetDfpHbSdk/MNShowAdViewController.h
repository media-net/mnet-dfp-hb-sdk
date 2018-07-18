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

@interface MNShowAdViewController : UIViewController <GADBannerViewDelegate, GADInterstitialDelegate, GADAdSizeDelegate>

typedef enum {
    AD_MOB_HB,
    DFP_HB,
    DFP_INTERSTITIAL_HB,
    DFP_REWARDED,
    DFP_MEDIATION,
    ADMOB_MEDIATION,
    ADMOB_INTERSTITIAL_MEDIATION,
    DFP_INTERSTITIAL_MEDIATION,
    DFP_BANNER_MANUAL_HB,
    DFP_INSTERSTITIAL_MANUAL_HB,
    MNET_AUTOMATION_DFP_ADVIEW,
} AdType;

@property (nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (nonatomic) AdType adType;
@property BOOL isInterstital;

@end
