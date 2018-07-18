//
//  MNBaseResponseTransformerManager.h
//  Pods
//
//  Created by nithin.g on 17/09/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseResponseValuesFromRequest.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseTransformerManager : NSObject

+ (instancetype)getInstanceWithBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                         withOriginalResponse:(NSDictionary *)originalResponseDict
                            andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras;

- (NSMutableArray<MNBaseBidResponse *> *)transformResponse;

@end
