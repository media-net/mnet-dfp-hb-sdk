//
//  MNetInternetFailureUITest.m
//  MNetDfpHbSdk_Tests
//
//  Created by vivekKumar.k on 09/10/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <XCTest/XCTest.h>
@import Nocilla;
@import KIF;
@interface MNetInternetFailureUITest : KIFTestCase

@end

@implementation MNetInternetFailureUITest
- (void)beforeAll{
    [tester acknowledgeSystemAlert];
}
- (void) testNetworkFailure{
    [[LSNocilla sharedInstance] start];
    NSError* notConnectedError = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
    stubRequest(@"GET",@".*".regex).andFailWithError(notConnectedError);
    stubRequest(@"POST",@".*".regex).andFailWithError(notConnectedError);
    [tester tapViewWithAccessibilityLabel:@"DFP Interstitial HB"];
    [tester tapViewWithAccessibilityLabel:@"LOAD AD"];
    [tester waitForViewWithAccessibilityLabel:@"Ad failed"];
    [[LSNocilla sharedInstance] stop];
    [[LSNocilla sharedInstance] clearStubs];
}
@end
