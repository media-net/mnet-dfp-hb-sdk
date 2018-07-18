//
//  MNBasePulseStore+Internal.h
//  Pods
//
//  Created by nithin.g on 25/07/17.
//
//

#import "MNBasePulseStore.h"
#import "MNBasePulseStoreData.h"

#ifndef MNBasePulseStore_Internal_h
#define MNBasePulseStore_Internal_h

@interface MNBasePulseStore ()
@property (weak, atomic) id delegate;
@property (atomic) MNBasePulseStoreData *cachedData;

+ (NSString *)getStringForPulseStoreLimitType:(MNBasePulseStoreLimitType)limitType;
- (NSUInteger)getNumEntries;
@end

#endif /* MNBasePulseStore_Internal_h */
