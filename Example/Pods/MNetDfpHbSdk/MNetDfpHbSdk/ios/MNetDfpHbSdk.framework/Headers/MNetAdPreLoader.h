//
//  AdPreLoader.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNetBaseAdSdk/MNBaseAdRequest.h"
#import "MNetBaseAdSdk/MNBaseConstants.h"
#import <Foundation/Foundation.h>

@interface MNetAdPreLoader : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (void)prefetchWith:(MNBaseAdRequest *_Nullable)request
              adUnitId:(NSString *_Nullable)adUnitId
    rootViewController:(UIViewController *_Nullable)rootViewController
       timeoutInMillis:(NSNumber *_Nullable)timeoutInMillis
               success:(void (^_Nullable)(NSDictionary *, NSString *))successHandler
               failure:(void (^_Nullable)(NSError *, NSString *))failureHandler;

NS_ASSUME_NONNULL_END
@end
