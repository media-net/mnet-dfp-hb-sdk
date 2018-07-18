//
//  MNBaseResponseTransformerStore.h
//  Pods
//
//  Created by nithin.g on 12/06/17.
//
//

#import "MNBaseResponseTransformer.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseTransformerStore : NSObject

+ (instancetype)getSharedInstance;
- (void)intializeTransformers;
- (NSArray<id<MNBaseResponseTransformer>> *)getTransformers;

@end
