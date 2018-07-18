//
//  MNBaseURL.h
//  Pods
//
//  Created by nithin.g on 26/07/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseURL : NSObject
- (BOOL)isHttpAllowed;

+ (instancetype)getSharedInstance;

- (NSString *)getBaseUrlDp;
- (NSString *)getBaseConfigUrl;
- (NSString *)getBasePulseUrl;
- (NSString *)getBaseResourceUrl;

- (NSString *)getLatencyTestUrl;
- (NSString *)getAdLoaderPredictBidsUrl;
- (NSString *)getAdLoaderPrefetchPredictBidsUrl;

- (NSString *)getConfigUrl;
- (NSString *)getPulseUrl;
- (NSString *)getFingerPrintUrl;
- (NSString *)getAuctionLoggerUrl;

@end
