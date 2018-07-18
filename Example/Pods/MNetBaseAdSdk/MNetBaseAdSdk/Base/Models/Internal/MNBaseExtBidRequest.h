//
//  MNBaseAdSource.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdRequest+Internal.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseExtBidRequest : NSObject <MNJMMapperProtocol>

/// 1 for bidder, 0 otherwise
@property (atomic) NSNumber *source;

/// Custom-extras are user-defined key-values
@property (atomic) NSDictionary<NSString *, NSString *> *customExtras;

+ (id)createWithAdRequest:(MNBaseAdRequest *)adRequest;

@end
