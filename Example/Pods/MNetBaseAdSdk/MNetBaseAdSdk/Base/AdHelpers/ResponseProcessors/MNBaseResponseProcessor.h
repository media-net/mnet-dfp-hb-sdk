//
//  MNBaseResponseProcessor.h
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseValuesFromRequest.h"
#import <Foundation/Foundation.h>

@protocol MNBaseResponseProcessor <NSObject>
- (void)processResponse:(NSDictionary *)response withResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras;
@end
