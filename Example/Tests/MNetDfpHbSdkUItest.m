//
//  MNetDfpHbSdkUItest.m
//  MNetDfpHbSdk_Tests
//
//  Created by vivekKumar.k on 27/09/18.
//  Copyright © 2018 gnithin. All rights reserved.
//
#import <XCTest/XCTest.h>
@import KIF;
@import NetworkEye;

@interface MNetDfpHbSdkUItest : KIFTestCase
@end

@implementation MNetDfpHbSdkUItest

-(void)beforeAll{
    [KIFUITestActor setDefaultTimeout:15];
    [tester acknowledgeSystemAlert];
}

-(void)beforeEach{
    [NEHTTPEye setEnabled:YES];
}

-(void) afterEach{
    [NEHTTPEye setEnabled:NO];
    [self resetToMainView];
    [self assertAdCalledOrNot];
}

-(void)resetToMainView{
    [tester waitForTimeInterval:3];
    [tester tapViewWithAccessibilityLabel:@"backButton"];
}

-(void)assertAdCalledOrNot{
    // refer this link for regex : https://regex101.com/r/BP5O39/1
    NSString *regex = @"https:\\/\\/rtb\\.msas\\.media\\.net\\/.*ads\\?.*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    NSArray<NEHTTPModel *> *array = [[NEHTTPModelManager defaultManager] allobjects];
    for(NEHTTPModel *ele in array){
        NSString *requestURL = [ele requestURLString];
        NSLog(@"URL : %@",requestURL);
        NSLog(@"********************************");
        if ([predicate evaluateWithObject: requestURL]){
            NSLog(@"URL MATCHED. Media.net ad Loaded");
            XCTAssert(YES);
            return;
        }
    }
    XCTAssert(NO,@"Media.net ad not loaded");
}

-(void)testBannerAd{
    [tester tapViewWithAccessibilityLabel:@"DFP Banner HB"];
    [tester tapViewWithAccessibilityLabel:@"LOAD AD"];
    [tester waitForViewWithAccessibilityLabel:@"Test Ad"];
    [tester waitForTimeInterval:3];
    
}

-(void)testInterstitialAd{
    [tester tapViewWithAccessibilityLabel:@"DFP Interstitial HB"];
    [tester tapViewWithAccessibilityLabel:@"LOAD AD"];
    [tester waitForViewWithAccessibilityLabel:@"SHOW AD"];
    [tester tapViewWithAccessibilityLabel:@"SHOW AD"];
    [tester waitForViewWithAccessibilityLabel:@"Test Ad"];
    [tester waitForTimeInterval:3];
    [tester tapViewWithAccessibilityLabel:@"Close Advertisement"];
}

@end
