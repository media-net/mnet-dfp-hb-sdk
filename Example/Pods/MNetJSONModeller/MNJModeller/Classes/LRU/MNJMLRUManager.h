//
//  MNJMLRUManager.h
//  MNetJSONModeller
//
//  Created by nithin.g on 29/10/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNJMLRUManager : NSObject

/// Creates an instance of LRU-cache
+ (instancetype _Nullable)getInstanceWithLimit:(NSUInteger)cacheLimit;

/// Add an entry to the lru-cache. This will mark the entry as most-recently-used.
/// Note that if you add an existing key, it'll not be added, and will not affect
/// the cache in anyway(it will not be marked as most-recently-used).
/// @return BOOL. Yes if added. No if key already exists.
- (BOOL)addEntry:(id)object withKey:(NSString *)key;

/// Get the entry for the key. If key is present, it will be marked as most-recently-used.
/// @return The entry added for the key. Nil if not present.
- (id _Nullable)getEntryforKey:(NSString *)key;

/// Removes the entry for the key.
// @return Returns the entry that is removed. Nil if not present.
- (id _Nullable)removeEntryForKey:(NSString *)key;

- (instancetype)init __attribute__((unavailable("Use +getInstanceWithLimit instead.")));

@end

NS_ASSUME_NONNULL_END
