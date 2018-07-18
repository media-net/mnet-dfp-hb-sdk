//
//  MNBaseQueue+Internal.h
//  Pods
//
//  Created by nithin.g on 08/09/17.
//
//

#ifndef MNBaseQueue_Internal_h
#define MNBaseQueue_Internal_h

#import "MNBaseQueue.h"

@interface MNBaseQueue ()
@property (atomic) NSMutableArray<NSObject *> *dataList;

- (BOOL)isEmptyQueue;
@end

#endif /* MNBaseQueue_Internal_h */
