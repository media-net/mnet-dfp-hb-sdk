//
//  MNBaseResponseProcessorsStore.h
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseProcessor.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseProcessorsStore : NSObject

+ (instancetype)getSharedInstance;
- (NSArray<id<MNBaseResponseProcessor>> *)getProcessors;

@end
