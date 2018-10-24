//
//  MNetMNetDfpInterstitialAdParameterTest.m
//  MNetDfpHbSdk_Tests
//
//  Created by vivekKumar.k on 23/10/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNDemoConstants.h"
@import MNetDfpHbSdk;
@import GoogleMobileAds;

@interface MNetMNetDfpInterstitialAdParameterTest : XCTestCase <GADInterstitialDelegate>
@property XCTestExpectation *testExpectation;
@property NSArray *testDevicesList;
@end

@implementation MNetMNetDfpInterstitialAdParameterTest

- (void)setUp {
    [super setUp];
    self.testDevicesList =  @[
                              // Iphone 5s
                              @"c43d79026c4919f2c46a6a5884cbe2e9",
                              // Iphone 7 Plus
                              @"32eca1d7a94a81b5c9e8dbd1d8675a4b",
                              // Iphone
                              @"c0be19a2dc871bfcda1e73d1ff0eb77b",
                              // Simulator
                              kGADSimulatorID,
                              ];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInterstitialAdWithValidData{
    self.testExpectation = [self expectationWithDescription:@"App crash"];
    
    DFPInterstitial *dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
    [dfpInterstitialAd setDelegate:self];
    
    DFPRequest *request = [DFPRequest request];
    [request setCustomTargeting:@{@"pos" : @"i2"}];
    [request setTestDevices:self.testDevicesList];
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [request setGender:kGADGenderFemale];
    [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
#pragma GCC diagnostic pop
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
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)testInterstitialAdWithInValidData{
    self.testExpectation = [self expectationWithDescription:@"App crash"];
    
    DFPInterstitial *dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
    [dfpInterstitialAd setDelegate:self];
    
    DFPRequest *request = [DFPRequest request];
    [request setCustomTargeting:@{@"dummy" : @"key"}];
    [request setTestDevices:self.testDevicesList];
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [request setGender:kGADGenderFemale];
    [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
#pragma GCC diagnostic pop
    [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
    
    [request setKeywords:@[
                           @"sports, adventure", @"scores-cricket", @"content_link:http://dummy.ad.com/keyword?"
                           ]];
    
    NSString *label                         = DFP_CUSTOM_EVENT_LABEL;
    GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
    [customEventExtras setExtras:@{
                                   @"author" : @"clear",
                                   @"shape" : [NSNull null],
                                   @"element" : @"universe",
                                   @"content_link" : @"http://dummy.ad.com/event_extras",
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
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)testInterstitialAdWithCustomTargetEventExtraAndKeywordsNil{
    self.testExpectation = [self expectationWithDescription:@"App crash"];
    
    DFPInterstitial *dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
    [dfpInterstitialAd setDelegate:self];
    
    DFPRequest *request = [DFPRequest request];
    [request setCustomTargeting:nil];
    [request setTestDevices:self.testDevicesList];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [request setGender:kGADGenderFemale];
    [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
#pragma GCC diagnostic pop
    [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
    
    [request setKeywords:nil];
    
    NSString *label                         = DFP_CUSTOM_EVENT_LABEL;
    GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
    [customEventExtras setExtras:@{
                                   @"author" :[NSNull null],
                                   @"shape" : [NSNull null],
                                   @"element" :[NSNull null],
                                   @"content_link" : [NSNull null],
                                   }
                        forLabel:label];
    NSLog(@"%@", [customEventExtras extrasForLabel:label]);
    [request registerAdNetworkExtras:customEventExtras];
    
    // Manual header bidding
    [MNetDfpBidder addBidsToDfpInterstitialAdRequest:request
                                          withAdView:dfpInterstitialAd
                                    withCompletionCb:^(DFPRequest *modifiedRequest, NSError *error) {
                                        if (error) {
                                            NSLog(@"Error when adding bids to request - %@", error);
                                        }
                                        [dfpInterstitialAd loadRequest:modifiedRequest];
                                    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)testInterstitialAdWithCustomEventExtraAndKeywordsNonNil{
    self.testExpectation = [self expectationWithDescription:@"App crash"];
    
    DFPInterstitial *dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
    [dfpInterstitialAd setDelegate:self];
    
    DFPRequest *request = [DFPRequest request];
    [request setCustomTargeting:@{@"gender" : @"male", @"section" : @[ @"sports", @"finance"]}];
    [request setCategoryExclusions: @[@"cars", @"pets"]];
    [request setTestDevices:self.testDevicesList];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [request setGender:kGADGenderFemale];
    [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
#pragma GCC diagnostic pop
    [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
    
    [request setKeywords:@[@"lion,tiger",@"birds"]];
    
    NSString *label                         = DFP_CUSTOM_EVENT_LABEL;
    GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
    [customEventExtras setExtras:@{
                                   @"company":@"media.net",
                                   @"profile":@"software developer",
                                   }
                        forLabel:label];
    NSLog(@"%@", [customEventExtras extrasForLabel:label]);
    [request registerAdNetworkExtras:customEventExtras];
    
    // Manual header bidding
    [MNetDfpBidder addBidsToDfpInterstitialAdRequest:request
                                          withAdView:dfpInterstitialAd
                                    withCompletionCb:^(DFPRequest *modifiedRequest, NSError *error) {
                                        if (error) {
                                            NSLog(@"Error when adding bids to request - %@", error);
                                        }
                                        [dfpInterstitialAd loadRequest:modifiedRequest];
                                    }];
    [self waitForExpectationsWithTimeout:15 handler:nil];
}


- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    XCTAssert(YES, @"Ad did failed with error %@",error);
    [self.testExpectation fulfill];
}
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    XCTAssert(YES, @"Ad did recieved");
    [self.testExpectation fulfill];
}


@end
