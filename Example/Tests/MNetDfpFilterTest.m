//
//  MNetDfpFilterTest.m
//  MNetDfpHbSdk_Tests
//
//  Created by nithin.g on 22/10/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <XCTest/XCTest.h>
@import MNetDfpHbSdk;

@interface MNetDfpFilterTest : XCTestCase

@end

@implementation MNetDfpFilterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testAdUnitFilter{
    MNetDfpAdUnitFilterAdUnitId *filter = [[MNetDfpAdUnitFilterAdUnitId alloc] init];
    
    /*
     [
     <CONFIG-AD-UNIT>,
     <PUBLISHER-AD-UNIT>,
     <Expected match, 1 for true>,
     ]
     */
    NSArray<NSArray<NSString *> *> *testCases = @[
                                                  // c-ad-unit should match pub-ad-unit with urls and other stuff
                                                  @[
                                                      @"8CU12342",
                                                      @"8CU12342/sample-url-added-unnecessarily",
                                                      @"1"
                                                      ],
                                                  @[
                                                      @"8CU12342",
                                                      @"sample-url-added-unnecessarily-8CU12342",
                                                      @"1"
                                                      ],
                                                  @[
                                                      @"8CU12342/sample-url-added-unnecessarily",
                                                      @"8CU12342",
                                                      @"0"
                                                      ],
                                                  // Exact match checks
                                                  @[
                                                      @"8CU12342",
                                                      @"8CU12342",
                                                      @"1"
                                                      ],
                                                  @[
                                                      @"8CU012342",
                                                      @"8CU102342",
                                                      @"0"
                                                      ],
                                                  // Empty pub-ad-unit should not match config-ad-unit
                                                  @[
                                                      @"8CU012342",
                                                      @"",
                                                      @"0"
                                                      ],
                                                  // Empty config-ad-unit should not match anything
                                                  @[
                                                      @"",
                                                      @"8CU012342",
                                                      @"0"
                                                      ],
                                                  ];
    
    for (NSArray<NSString *> *test in testCases){
        NSString *configAdUnitId = test[0];
        NSString *pubAdUnitId = test[1];
        BOOL expectedMatch = [test[2] isEqualToString:@"1"];
        
        BOOL actualMatch = [filter matchConfigAdUnitId:configAdUnitId WithPubId:pubAdUnitId];
        XCTAssert(expectedMatch == actualMatch, @"Expected %@, but got %@ for config-ad-unit %@, pub-ad-unit %@", expectedMatch?@"YES":@"NO", actualMatch?@"YES":@"NO", configAdUnitId, pubAdUnitId);
    }
}

@end
