//
//  MNJMClassPropertyManager+Internal.h
//  MNetJSONModeller
//
//  Created by nithin.g on 29/10/17.
//

#ifndef MNJMClassPropertyManager_Internal_h
#define MNJMClassPropertyManager_Internal_h

#import "MNJMClassPropertyManager.h"
#import "MNJMLRUManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNJMClassPropertyManager ()

@property (nonatomic) MNJMLRUManager *lruMemoisationCache;

- (BOOL)doesClassContainReservedPrefix:(NSString *_Nullable)classNameStr;
- (NSString *_Nullable)getObjCTypeForProperty:(objc_property_t)property;
@end

NS_ASSUME_NONNULL_END

#endif /* MNJMClassPropertyManager_Internal_h */
