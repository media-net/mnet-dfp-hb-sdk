//
//  MNBasePrefetchBids+Internal.h
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#ifndef MNBasePrefetchBids_Internal_h
#define MNBasePrefetchBids_Internal_h

#import "MNBasePrefetchBids.h"

@interface MNBasePrefetchBids ()
@property (atomic, nonnull) MNBaseAdRequest *adRequest;

- (NSError *_Nullable)modifyAdRequest;

@end

#endif /* MNBasePrefetchBids_Internal_h */
