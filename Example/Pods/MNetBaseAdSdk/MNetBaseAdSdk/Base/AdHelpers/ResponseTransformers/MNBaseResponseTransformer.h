//
//  MNBaseResponseTransformer.h
//  Pods
//
//  Created by nithin.g on 12/06/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseResponseValuesFromRequest.h"
#import <Foundation/Foundation.h>

@protocol MNBaseResponseTransformer <NSObject>
- (NSMutableArray *)transformBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                       withOriginalResponse:(NSDictionary *)response
                          andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras;

@end
