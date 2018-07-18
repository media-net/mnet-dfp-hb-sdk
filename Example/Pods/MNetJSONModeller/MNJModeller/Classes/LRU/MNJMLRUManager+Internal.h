//
//  MNJMLRUManager+Internal.h
//  MNetJSONModeller
//
//  Created by nithin.g on 29/10/17.
//

#ifndef MNJMLRUManager_Internal_h
#define MNJMLRUManager_Internal_h

#import "MNJMLRUManager.h"

@interface MNJMLRUManager ()

@property (nonatomic) NSMutableArray<NSString *> *entryList;
@property (nonatomic) NSMutableDictionary *entryMap;
@property (nonatomic) NSUInteger cacheLimit;

- (void)clearCache;

@end

#endif /* MNJMLRUManager_Internal_h */
