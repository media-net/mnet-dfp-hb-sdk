//
//  MNBaseError+Internal.h
//  Pods
//
//  Created by nithin.g on 31/07/17.
//
//

#import "MNBaseError.h"

#ifndef MNBaseError_Internal_h
#define MNBaseError_Internal_h

@interface MNBaseError () <MNJMMapperProtocol>
- (NSDictionary *)propertyKeyMap;
@end

#endif /* MNBaseError_Internal_h */
