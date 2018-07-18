//
//  AdLoader.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdRequest+Internal.h"
#import "MNBaseBidRequest.h"
#import "MNBaseBidResponse.h"
#import "MNBaseBidResponsesContainer.h"
#import "MNBaseError.h"
#import <Foundation/Foundation.h>

@class MNBaseAdLoaderOptions;

typedef NS_ENUM(NSUInteger, MNBaseAdLoaderType) {
    MNBaseAdLoaderTypeNone,
    MNBaseAdLoaderTypePredictBids,
    MNBaseAdLoaderTypePrefetchPredictBids
};

@interface MNBaseAdLoader : NSObject

+ (instancetype _Nonnull)getSharedInstance;

- (instancetype _Nonnull)init __attribute__((unavailable("Use +[MNBaseAdLoader getSharedInstance]")));

/// Makes an http request for the MNBaseBidRequest and returns array of bid-responses, with the given options object
- (NSURLSessionDataTask *_Nullable)loadAdFor:(MNBaseAdRequest *_Nonnull)adRequest
                                 withOptions:(MNBaseAdLoaderOptions *_Nullable)options
                            onViewController:(UIViewController *_Nullable)viewController
                                     success:(nonnull void (^)(MNBaseBidResponsesContainer *_Nonnull))successHandler
                                        fail:(nonnull void (^)(NSError *_Nonnull))failureHandler;

@end

@interface MNBaseAdLoaderOptions : NSObject

@property (atomic) NSNumber *_Nonnull timeout;
@property (atomic) MNBaseAdLoaderType forceAdLoader;

+ (instancetype _Nonnull)getDefaultOptions;

@end
