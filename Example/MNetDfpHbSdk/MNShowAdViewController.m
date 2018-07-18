//
//  MNShowAdViewController.m
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <MNetDfpHbSdk/MNetDfpBidder.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import "MNDemoConstants.h"
#import "MNShowAdViewController.h"
#import "MNTestDevicesManager.h"
#import "UIView+Toast.h"

#define LOADER_TEXT @"Loading ad"
#define TITLE_TEXT_COLOR [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:0.5]

@import GoogleMobileAds;

@interface MNShowAdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loadAd;
@property (weak, nonatomic) IBOutlet UIButton *showAd;
@property (weak, nonatomic) IBOutlet UILabel *adViewTitle;

- (IBAction)back:(id)sender;
- (IBAction)loadAdAction:(id)sender;
- (IBAction)showAdAction:(id)sender;

@end

@implementation MNShowAdViewController

GADBannerView *gadBannerView;
DFPBannerView *dfpBannerView;
DFPInterstitial *dfpInterstitialAd;
GADInterstitial *gadInterstitialAd;

static const NSDictionary<NSNumber *, NSString *> *titleStringMap;

#pragma mark - Toast messages
static NSString *mnetBannerLoadAd  = @"Ad loaded";
static NSString *mnetBannerFailAd  = @"Ad failed";
static NSString *mnetBannerAdClick = @"Ad clicked";

static NSString *mnetInterstitialLoadAd    = @"Ad loaded";
static NSString *mnetInterstitialClickAd   = @"Ad clicked";
static NSString *mnetInterstitialFailAd    = @"Ad failed";
static NSString *mnetInterstitialShowAd    = @"Ad shown";
static NSString *mnetInterstitialDismissAd = @"Ad dismissed";

static NSString *mnetVideoLoadAd    = @"Video ad loaded";
static NSString *mnetVideoStartAd   = @"Video ad started";
static NSString *mnetVideoComplteAd = @"Video ad Complete";
static NSString *mnetVideoClickAd   = @"Video ad clicked";
static NSString *mnetVideoFailAd    = @"Video ad failed";

static NSString *mnetInterstitialVideoLoadAd     = @"Video ad loaded";
static NSString *mnetInterstitialVideoShowAd     = @"Video ad shown";
static NSString *mnetInterstitialVideoStartAd    = @"Video ad started";
static NSString *mnetInterstitialVideoClickAd    = @"Video ad clicked";
static NSString *mnetInterstitialVideoFailAd     = @"Video ad failed";
static NSString *mnetInterstitialVideoDismissAd  = @"Video ad dismissed";
static NSString *mnetInterstitialVideoCompleteAd = @"Video ad completed";

static NSString *mnetRewardedVideoLoadAd     = @"Ad loaded";
static NSString *mnetRewardedVideoShowAd     = @"Ad shown";
static NSString *mnetRewardedVideoStartAd    = @"Ad started";
static NSString *mnetRewardedVideoClickAd    = @"Ad clicked";
static NSString *mnetRewardedVideoFailAd     = @"Ad failed";
static NSString *mnetRewardedVideoCompleteAd = @"Reward received";

static NSString *mopubLoadAd  = @"Ad loaded";
static NSString *mopubFailAd  = @"Ad failed";
static NSString *mopubClickAd = @"Ad clicked";

static NSString *mopubInterstitialLoadAd  = @"Ad loaded";
static NSString *mopubInterstitialShowAd  = @"Ad shown";
static NSString *mopubInterstitialFailAd  = @"Ad failed";
static NSString *mopubInterstitialDismiss = @"Ad dismissed";

static NSString *gadLoadAd  = @"Ad loaded";
static NSString *gadFailAd  = @"Ad failed";
static NSString *gadClickAd = @"Ad clicked";

static NSString *gadInterstitialLoadAd    = @"Ad loaded";
static NSString *gadInterstitialFailAd    = @"Ad failed";
static NSString *gadInterstitialShowAd    = @"Ad shown";
static NSString *gadInterstitialDismissAd = @"Ad dismissed";

static NSArray<NSString *> *testDevicesList;

- (void)loadDevicesList {
    NSMutableArray<NSString *> *devicesList = [@[
        // Iphone 5s
        @"f97eacc0e37157c3124d3ddaeaca1ead",
        // Iphone 7 Plus
        @"32eca1d7a94a81b5c9e8dbd1d8675a4b",
        // Iphone
        @"c0be19a2dc871bfcda1e73d1ff0eb77b",
        // Simulator
        kGADSimulatorID,
    ] mutableCopy];
    NSArray *testDeviceIds                  = [[MNTestDevicesManager getSharedInstance] getTestDeviceIds];
    if (testDeviceIds != nil && [testDeviceIds count] > 0) {
        for (NSString *deviceId in testDeviceIds) {
            [devicesList addObject:deviceId];
        }
    }

    if (devicesList == nil) {
        testDevicesList = @[];
    } else {
        testDevicesList = [NSArray arrayWithArray:devicesList];
    }
}

- (void)printTestDevices {
    if (testDevicesList == nil || [testDevicesList count] == 0) {
        NSLog(@"TEST_DEVICE_ID: There are no test device ids configured");
        return;
    }
    NSLog(@"TEST_DEVICE_ID: Contains %lu test-ids", (unsigned long) [testDevicesList count]);
    for (NSString *testId in testDevicesList) {
        NSLog(@"TEST_DEVICE_ID: %@", testId);
    }
}

#pragma mark -  MNShowAdVC methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTitleMap];

    [self handleButtonStatesForAdType];
    NSNumber *adTypeNum  = ENUM_VAL(self.adType);
    NSString *adTitleStr = [titleStringMap objectForKey:adTypeNum];
    if (adTitleStr == nil) {
        adTitleStr = @"";
    }

    self.adViewTitle.textColor = TITLE_TEXT_COLOR;
    self.adViewTitle.text      = adTitleStr;

    CGFloat blurRadius              = 4.0f;
    self.topBar.layer.shadowOpacity = 0.4f;
    self.topBar.layer.shadowOffset  = CGSizeMake(0, blurRadius);
    self.topBar.layer.shadowRadius  = blurRadius;
    self.topBar.layer.shadowColor   = [[UIColor blackColor] CGColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDevicesList];
    [self printTestDevices];
}

- (void)initTitleMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      titleStringMap = @{
          ENUM_VAL(AD_MOB_HB) : @"ADMOB BANNER",
          ENUM_VAL(DFP_HB) : @"DFP BANNER",
          ENUM_VAL(DFP_INTERSTITIAL_HB) : @"DFP INTERSTITIAL",
          ENUM_VAL(DFP_REWARDED) : @"DFP MEDIATION REWARDED VIDEO",
          ENUM_VAL(DFP_MEDIATION) : @"DFP BANNER MEDIATION",
          ENUM_VAL(ADMOB_MEDIATION) : @"ADMOB BANNER MEDIATION",
          ENUM_VAL(DFP_INTERSTITIAL_MEDIATION) : @"DFP INTERSTITIAL MEDIATION",
          ENUM_VAL(ADMOB_INTERSTITIAL_MEDIATION) : @"ADMOB INTERSTITIAL MEDIATION",
          ENUM_VAL(DFP_BANNER_MANUAL_HB) : @"MANUAL DFP BANNER",
          ENUM_VAL(DFP_INSTERSTITIAL_MANUAL_HB) : @"MANUAL DFP INTERSTITIAL",
          ENUM_VAL(MNET_AUTOMATION_DFP_ADVIEW) : @"AUTOMATION DFP AD"
      };
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)handleButtonStatesForAdType {
    [[self loadAd] setEnabled:YES];
    [[self showAd] setHidden:YES];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadAdAction:(id)sender {
    [self clearAdView];

    switch ([self adType]) {

    case DFP_HB: {
        [self addLoaderToScreen];

        NSLog(@"creating banner ad view for dfp");
        CGSize adSize = GAD_SIZE_320x50;
        dfpBannerView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(adSize)];
        [[self adView] addSubview:dfpBannerView];
        [dfpBannerView setAdUnitID:DEMO_DFP_AD_UNIT_ID];
        [dfpBannerView setRootViewController:self];
        [dfpBannerView setValidAdSizes:@[
            NSValueFromGADAdSize(kGADAdSizeBanner),
            NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
        ]];
        [dfpBannerView setAdSizeDelegate:self];
        [dfpBannerView setDelegate:self];
        [self applyAdViewContraints:dfpBannerView height:adSize.height width:adSize.width];

        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"pos" : @"b"}];
        [request setTestDevices:testDevicesList];
        [request setKeywords:@[ @"sports", @"scores", @"content_link:https://my-custom-link.com.imnapp/keywords" ]];
        [request setGender:kGADGenderMale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
        [request setContentURL:@"https://my-custom-link.com.imnapp/contentURL"];
        /*
         [request setContentURL:@"https://my-custom-link.com/contentURL"];

         // These are additional keywords that can be picked up HB
         [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
         [request setGender:kGADGenderMale];
         [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
         [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

         GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         NSString *label = DFP_CUSTOM_EVENT_LABEL;
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://my-custom-link.com/additional_params",
         }
         forLabel:label];
         NSLog(@"%@", [customEventExtras extrasForLabel:label]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [dfpBannerView loadRequest:request];
        break;
    }

    case AD_MOB_HB: {
        [self addLoaderToScreen];

        NSLog(@"creating banner ad view for admob");
        [[self adView] addSubview:gadBannerView];
        [self applyAdViewContraints:gadBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];
        [gadBannerView setAdUnitID:DEMO_AD_MOB_AD_UNIT_ID];
        [gadBannerView setRootViewController:self];
        GADRequest *request = [GADRequest request];
        [request setTestDevices:testDevicesList];
        [gadBannerView loadRequest:request];

        break;
    }

    case DFP_INTERSTITIAL_HB: {
        [self addLoaderToScreen];
        dfpInterstitialAd   = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"pos" : @"i1"}];
        [request setTestDevices:testDevicesList];
        /*
         [request setContentURL:@"https://my-custom-link.com/contentURL"];

         // These are additional keywords that can be picked up HB
         [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
         [request setGender:kGADGenderMale];
         [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
         [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

         GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         NSString *label = DFP_CUSTOM_EVENT_LABEL;
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://my-custom-link.com/additional_params",
         }
         forLabel:label];
         NSLog(@"%@", [customEventExtras extrasForLabel:label]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [dfpInterstitialAd setDelegate:self];
        [dfpInterstitialAd loadRequest:request];
        break;
    }

    case DFP_MEDIATION: {
        [self addLoaderToScreen];

        NSLog(@"creating banner ad view for dfp");
        dfpBannerView = [[DFPBannerView alloc]
            initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
        [[self adView] addSubview:dfpBannerView];
        [dfpBannerView setAdUnitID:DEMO_DFP_MEDIATION_AD_UNIT_ID];
        [dfpBannerView setRootViewController:self];
        [dfpBannerView setDelegate:self];

        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"bid" : @"15"}];
        [request setTestDevices:testDevicesList];

        // User-defined stuff
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

        /*
         [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
         GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         NSString *label = DFP_CUSTOM_EVENT_LABEL;
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://my-custom-link.com/additional_params",
         }
         forLabel:DFP_CUSTOM_EVENT_LABEL];
         NSLog(@"%@", [customEventExtras extrasForLabel:DFP_CUSTOM_EVENT_LABEL]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [dfpBannerView loadRequest:request];

        [dfpBannerView setFrame:CGRectMake((_adView.frame.size.width - GAD_SIZE_320x50.width) / 2.0, 0,
                                           GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        break;
    }
    case ADMOB_MEDIATION: {
        [self addLoaderToScreen];

        NSLog(@"creating banner ad view for admob");
        gadBannerView = [[GADBannerView alloc]
            initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
        [[self adView] addSubview:gadBannerView];
        [gadBannerView setAdUnitID:DEMO_AD_MOB_MEDIATION_AD_UNIT_ID];
        [gadBannerView setRootViewController:self];
        [gadBannerView setDelegate:self];

        GADRequest *request = [GADRequest request];
        [request setTestDevices:testDevicesList];

        // custom user settings
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

        /*
         [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
         GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         NSString *label = AD_MOB_CUSTOM_EVENT_LABEL;
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://my-custom-link.com/additional_params",
         }
         forLabel:label];
         NSLog(@"%@", [customEventExtras extrasForLabel:label]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [gadBannerView loadRequest:request];

        [gadBannerView setFrame:CGRectMake((_adView.frame.size.width - GAD_SIZE_320x50.width) / 2.0, 0,
                                           GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        break;
    }
    case DFP_INTERSTITIAL_MEDIATION: {
        [self addLoaderToScreen];
        dfpInterstitialAd   = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_MEDIATION_INTERSTITIAL_AD_UNIT_ID];
        DFPRequest *request = [DFPRequest request];
        [request setTestDevices:testDevicesList];

        // User-defined stuff
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:3]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
        /*
         [request setKeywords:@[@"sports", @"scores",
         @"content_link:https://dfp-intersitial-my-custom-link.com/keywords"]]; NSString *label =
         DFP_CUSTOM_EVENT_LABEL; GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://dfp-intersitial-my-custom-link.com/additional_params",
         }
         forLabel:label];
         NSLog(@"%@", [customEventExtras extrasForLabel:label]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [dfpInterstitialAd setDelegate:self];
        [dfpInterstitialAd loadRequest:request];
        break;
    }
    case ADMOB_INTERSTITIAL_MEDIATION: {
        [self addLoaderToScreen];
        gadInterstitialAd = [[GADInterstitial alloc] initWithAdUnitID:DEMO_AD_MOB_MEDIATION_INTERSTITIAL_AD_UNIT_ID];
        [gadInterstitialAd setDelegate:self];

        GADRequest *request = [GADRequest request];
        [request setTestDevices:testDevicesList];

        // User-defined stuff
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
        /*
         [request setKeywords:@[@"sports", @"scores",
         @"content_link:https://admob-intersitial-my-custom-link.com/keywords"]];

         NSString *label = AD_MOB_CUSTOM_EVENT_LABEL;
         GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
         [customEventExtras setExtras:@{
         @"author":       @"hawking",
         @"shape":        @"saddle",
         @"element":      @"universe",
         @"content_link": @"https://admob-intersitial-my-custom-link.com/additional_params",
         }
         forLabel:label];
         NSLog(@"%@", [customEventExtras extrasForLabel:label]);
         [request registerAdNetworkExtras:customEventExtras];
         */

        [gadInterstitialAd loadRequest:request];
        break;
    }

    case DFP_BANNER_MANUAL_HB: {
        [self addLoaderToScreen];

        dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];

        [[self adView] addSubview:dfpBannerView];
        [self applyAdViewContraints:dfpBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];

        [dfpBannerView setAdUnitID:DEMO_DFP_AD_UNIT_ID];
        [dfpBannerView setRootViewController:self];
        [dfpBannerView setDelegate:self];
        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"pos" : @"b"}];
        [request setTestDevices:testDevicesList];
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

        [request setKeywords:@[
            @"sports", @"scores", @"content_link:http://mnadsdkdemo.beta.media.net.imnapp/dfp_keywords"
        ]];

        NSString *label                         = DFP_CUSTOM_EVENT_LABEL;
        GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
        [customEventExtras setExtras:@{
            @"author" : @"hawking",
            @"shape" : @"saddle",
            @"element" : @"universe",
            @"content_link" : @"http://mnadsdkdemo.beta.media.net.imnapp/dfp_event_extras",
        }
                            forLabel:label];
        NSLog(@"%@", [customEventExtras extrasForLabel:label]);
        [request registerAdNetworkExtras:customEventExtras];

        // Manual header bidding
        [MNetDfpBidder addBidsToDfpBannerAdRequest:request
                                        withAdView:dfpBannerView
                                  withCompletionCb:^(DFPRequest *modifiedRequest, NSError *error) {
                                    if (error) {
                                        NSLog(@"Error when adding bids to request - %@", error);
                                    }
                                    [dfpBannerView loadRequest:modifiedRequest];
                                  }];

        break;
    }
    case DFP_INSTERSTITIAL_MANUAL_HB: {
        [self addLoaderToScreen];
        dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
        [dfpInterstitialAd setDelegate:self];

        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"pos" : @"i2"}];
        [request setTestDevices:testDevicesList];

        [request setTestDevices:testDevicesList];
        [request setGender:kGADGenderFemale];
        [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
        [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];

        [request setKeywords:@[
            @"sports", @"scores", @"content_link:http://mnadsdkdemo.beta.media.net.imnapp/dfp_keywords"
        ]];

        NSString *label                         = DFP_CUSTOM_EVENT_LABEL;
        GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
        [customEventExtras setExtras:@{
            @"author" : @"hawking",
            @"shape" : @"saddle",
            @"element" : @"universe",
            @"content_link" : @"http://mnadsdkdemo.beta.media.net.imnapp/dfp_event_extras",
        }
                            forLabel:label];
        NSLog(@"%@", [customEventExtras extrasForLabel:label]);
        [request registerAdNetworkExtras:customEventExtras];

        [MNetDfpBidder addBidsToDfpInterstitialAdRequest:request
                                              withAdView:dfpInterstitialAd
                                        withCompletionCb:^(DFPRequest *modifiedRequest, NSError *error) {
                                          if (error) {
                                              NSLog(@"Error when adding bids to request - %@", error);
                                          }
                                          [dfpInterstitialAd loadRequest:modifiedRequest];
                                        }];
        break;
    }
    case MNET_AUTOMATION_DFP_ADVIEW: {
        [self addLoaderToScreen];

        NSLog(@"creating automation ad view for dfp");
        dfpBannerView = [[DFPBannerView alloc]
            initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
        [[self adView] addSubview:dfpBannerView];
        [self applyAdViewContraints:dfpBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];
        [dfpBannerView setAdUnitID:DEMO_AUTOMATION_DFP_AD_UNIT_ID];
        [dfpBannerView setRootViewController:self];
        [dfpBannerView setDelegate:nil];

        DFPRequest *request = [DFPRequest request];
        [request setTestDevices:testDevicesList];
        [dfpBannerView loadRequest:request];

        [self hideLoaderFromScreen];
        [self showTestDeviceAlertView];
    }
    }
}

- (void)showTestDeviceAlertView {
    // Show the alertview which gets the test-device ids
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"DFP Test device id"
                                                                             message:@"Input device id"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
      textField.placeholder     = @"name";
      textField.textColor       = [UIColor blackColor];
      textField.clearButtonMode = UITextFieldViewModeWhileEditing;
      textField.borderStyle     = UITextBorderStyleRoundedRect;
    }];
    [alertController
        addAction:[UIAlertAction actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                           NSArray *textfields        = alertController.textFields;
                                           UITextField *deviceIdfield = textfields[0];
                                           NSString *deviceId         = deviceIdfield.text;
                                           if (deviceId == nil) {
                                               NSLog(@"Got device-id as nil from the alert-view");
                                               return;
                                           }
                                           deviceId = [deviceId
                                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                           if ([deviceId isEqualToString:@""]) {
                                               NSLog(@"Got device-id as empty from the alert-view");
                                               return;
                                           }
                                           NSLog(@"Got test-device from console - %@", deviceId);
                                           [[MNTestDevicesManager getSharedInstance] addDeviceId:deviceId];
                                         }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)applyAdViewContraints:(UIView *)mnetAdView height:(CGFloat)h width:(CGFloat)w {
    mnetAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:mnetAdView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:mnetAdView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:mnetAdView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:w],
        [NSLayoutConstraint constraintWithItem:mnetAdView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1.0
                                      constant:h]

    ]];
}

- (void)clearAdView {
    for (UIView *subview in [[self adView] subviews]) {
        [subview removeFromSuperview];
    }
}

- (void)showErrorAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)btnStateEnabled:(BOOL)isEnabled forBtn:(UIButton *)btnVal {
    UIColor *bgColor;

    if (isEnabled) {
        bgColor = [UIColor colorWithRed:255.0 / 255.0 green:207.0 / 255.0 blue:10 / 255.0 alpha:1];

    } else {
        bgColor = [UIColor colorWithRed:216.0 / 255.0 green:216.0 / 255.0 blue:216.0 / 255.0 alpha:1];
    }
    [btnVal setHidden:!isEnabled];
    [btnVal setBackgroundColor:bgColor];
    [btnVal setEnabled:isEnabled];
}

- (IBAction)showAdAction:(id)sender {
    switch ([self adType]) {
    case DFP_INTERSTITIAL_HB: {
        [dfpInterstitialAd presentFromRootViewController:self];
        break;
    }
    case DFP_INTERSTITIAL_MEDIATION: {
        [dfpInterstitialAd presentFromRootViewController:self];
        break;
    }

    case ADMOB_INTERSTITIAL_MEDIATION: {
        [gadInterstitialAd presentFromRootViewController:self];
        break;
    }
    case DFP_INSTERSTITIAL_MANUAL_HB: {
        [dfpInterstitialAd presentFromRootViewController:self];
        break;
    }

    default:
        // Nothing
        break;
    }
}

#pragma mark - Loader helpers
static NSProgress *progressObject;
static NSTimer *loaderTimerObj;
static const NSUInteger totalLoaderUnits     = 100;
static const NSUInteger maxUnitsWhileLoading = 80;

- (void)addLoaderToScreen {
    __block NSUInteger currentUnit = 0;

    MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [loader.label setText:LOADER_TEXT];
    loader.mode = MBProgressHUDModeAnnularDeterminate;

    progressObject        = [NSProgress progressWithTotalUnitCount:totalLoaderUnits];
    loader.progressObject = progressObject;

    NSBlockOperation *handleProgressViewCallback = [NSBlockOperation blockOperationWithBlock:^{
      if (currentUnit < maxUnitsWhileLoading) {
          currentUnit += 1;
          progressObject.completedUnitCount = currentUnit;
      }
    }];

    NSTimeInterval timerInterval = 1 / 60.0;
    loaderTimerObj               = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                      target:handleProgressViewCallback
                                                    selector:@selector(main)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)hideLoaderFromScreen {
    progressObject.completedUnitCount = totalLoaderUnits;
    if (loaderTimerObj) {
        [loaderTimerObj invalidate];
        loaderTimerObj = nil;
    }

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - GADBannerView
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"DEMO: DFP %@", gadLoadAd);
    [self.view makeToast:gadLoadAd];

    [self hideLoaderFromScreen];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.view makeToast:gadFailAd];

    NSString *displayStr = [NSString stringWithFormat:@"GAD: banner view error %@", error];
    NSLog(@"DEMO: DFP %@", displayStr);
    [self.view makeToast:displayStr];

    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching GADBannerView"];

    [self hideLoaderFromScreen];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"DEMO: DFP %@", gadClickAd);
    [self.view makeToast:gadClickAd];
}

#pragma mark - GADInterstitial

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"DEMO: DFP Interstitial %@", gadInterstitialLoadAd);
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadInterstitialLoadAd];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"DEMO: DFP Interstitial %@", gadFailAd);
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching DFP Interstitial ad!"];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadFailAd];
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    NSLog(@"DEMO: Fail to present to screen");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"DEMO: DFP Interstitial %@", gadInterstitialDismissAd);
    [self btnStateEnabled:NO forBtn:self.showAd];
    [self.view makeToast:gadInterstitialDismissAd];
}

#pragma mark - Ad-size
- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
    NSLog(@"AdSize changed!");
    [self applyAdViewContraints:dfpBannerView height:size.size.height width:size.size.width];
}

#pragma mark - Error
- (void)dealloc {
    NSLog(@"DEALLOC: MNShowAdViewController");
}

@end
