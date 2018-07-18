//
//  MNDemoConstants.h
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNDemoConstants : UIViewController

#define DEMO_MN_CUSTOMER_ID @"8CUO15940"
#define DEMO_MN_MRAID_CUSTOMER_ID @"8CU96S538"
#define DEMO_MN_AD_UNIT_300x250 @"216427370"
#define DEMO_MN_AD_UNIT_300x250_VIDEO @"698985027"
#define DEMO_MN_AD_UNIT_320x50 @"719925423"
#define DEMO_MN_AD_UNIT_450x300 @"testadunitid"
#define DEMO_MN_AD_UNIT_REWARDED @"835283116"
#define DEMO_MOPUB_AD_UNIT_ID @"d6f2811c2cb84b57bbbf3128c08a2165"
#define DEMO_DFP_AD_UNIT_ID @"/45361917/iosinapptest"
#define DEMO_AUTOMATION_DFP_AD_UNIT_ID @"/6499/example/banner"
#define DEMO_MRAID_AD_UNIT_320x50 @"579736769"

#define DEMO_DFP_MEDIATION_AD_UNIT_ID @"/45361917/iOSDFPAdaptertestBanner"
#define DEMO_MOPUB_MEDIATION_AD_UNIT_ID @"e4e9f244729648b4ab1c8c2c72567bbb"
#define DEMO_AD_MOB_MEDIATION_AD_UNIT_ID @"ca-app-pub-6365858186554077/1837780344"
#define DEMO_AD_MOB_REWARDED_VIDEO_MEDIATION_AD_UNIT_ID @"ca-app-pub-6365858186554077/7336579179"

#define DEMO_AD_MOB_HB_AD_UNIT_ID @"d6f2811c2cb84b57bbbf3128c08a2165"
#define DEMO_MOPUB_INTERSTITIAL_HB_AD_UNIT_ID @"27931f8c98bd452fb9a928f4d73b1630"
#define DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID @"/45361917/iosinapptest"

#define DEMO_DFP_MEDIATION_INTERSTITIAL_AD_UNIT_ID @"/45361917/iOSDFPAdaptertestInterstitial"
#define DEMO_MOPUB_MEDIATION_INTERSTITIAL_AD_UNIT_ID @"e216c9fae56b4e34b39876e7cb93d1e7"
#define DEMO_AD_MOB_MEDIATION_INTERSTITIAL_AD_UNIT_ID @"ca-app-pub-6365858186554077/4791246749"

#define DEMO_AD_MOB_AD_UNIT_ID @"ca-app-pub-6365858186554077/4154389946"

#define LONGITUDE 72.8561644
#define LATITUDE 19.0176147

// Custom event labels
#define AD_MOB_CUSTOM_EVENT_LABEL @"MNetAdMobCustomEvent"
#define DFP_CUSTOM_EVENT_LABEL @"MNetDfpCustomEvent"

// If has_include contains the import, the pod is not a framework
#if !__has_include(<MNetAdSdk/MNetURL.h>)
#define IS_FRAMEWORK 1
#endif

@end
