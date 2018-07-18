//
//  MNBasePrefetchBids.h
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import "MNBaseAdRequest+Internal.h"
#import <Foundation/Foundation.h>

@interface MNBasePrefetchBids : NSObject

+ (instancetype _Nonnull)getInstance;

- (NSURLSessionDataTask *_Nullable)prefetchBidsForAdRequest:(MNBaseAdRequest *_Nonnull)adRequest
                                                     withCb:
                                                         (void (^_Nullable)(NSError *_Nullable prefetchErr))prefetchCb;

@end
