//
//  MNBaseResponseProcessorsManager.h
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseValuesFromRequest.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseProcessorsManager : NSObject

- (instancetype)init __attribute__((unavailable("Use + getInstanceWithAdUnit:andAdCycleId:")));

+ (instancetype)getInstanceWithResponse:(NSDictionary *)response
                     withResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras;
- (void)processResponse;

@end
