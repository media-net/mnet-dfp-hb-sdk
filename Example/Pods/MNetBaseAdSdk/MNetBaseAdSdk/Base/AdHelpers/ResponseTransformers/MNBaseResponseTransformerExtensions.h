//
//  MNBaseResponseTransformerExtensions.h
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import "MNBaseResponseTransformer.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseTransformerExtensions : NSObject <MNBaseResponseTransformer>

- (NSMutableArray *)transformBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                       withOriginalResponse:(NSDictionary *)response
                          andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras;

@end
