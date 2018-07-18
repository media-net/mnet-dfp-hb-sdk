//
//  MNBaseAdLoaderProtocol.h
//  Pods
//
//  Created by nithin.g on 13/09/17.
//
//

#import "MNBaseAdLoader.h"
#import "MNBaseBidRequest.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

@protocol MNBaseAdLoaderProtocol <NSObject>

/// Returns an instance of the adLoader
+ (instancetype _Nonnull)getLoaderInstance;

/// This method specifies if a particular ad-loader can load an ad.
/// It also prepares the ad in case it's ready
- (BOOL)canLoadAdForAdUnitId:(NSString *_Nonnull)adUnitId withOptions:(MNBaseAdLoaderOptions *_Nullable)options;

/// Make the ad-loader call for the bid-request
- (NSURLSessionDataTask *_Nullable)loadAdFor:(MNBaseBidRequest *_Nonnull)bidRequest
                                 withOptions:(MNBaseAdLoaderOptions *_Nullable)options
                            onViewController:(UIViewController *_Nullable)viewController
                                     success:(nonnull void (^)(MNBaseBidResponsesContainer *_Nullable))successHandler
                                        fail:(nonnull void (^)(NSError *_Nonnull))failureHandler;
@end
