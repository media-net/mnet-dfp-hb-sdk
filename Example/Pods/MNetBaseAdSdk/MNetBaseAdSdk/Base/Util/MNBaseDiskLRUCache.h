//
//  MNBaseDiskLRUCache.h
//  Pods
//
//  Created by kunal.ch on 24/03/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseDiskLRUCache : NSObject

/**
 ** Singelton instance to be created only once.
 **/
+ (MNBaseDiskLRUCache *)sharedLRUCache;

/**
 ** Returns YES if Caches file is present for the given key
 ** else returns NO
 **/
- (BOOL)hasCacheForKey:(NSString *)key;

/**
 ** Exctracts and retutns caches data associated for given key.
 ** If data is not present for key, nil will be returned
 **/
- (NSData *)getDataForKey:(NSString *)key;

/**
 ** Stores the gives data for the given key
 **/
- (void)saveData:(NSData *)data forKey:(NSString *)key;

/**
 ** Clears all cahes files
 **/
- (void)clearAllCachedFiles;

- (NSString *)getCachedFilePathForKey:(NSString *)key;

/**
 ** Clears cached file for key
 **/
- (void)clearCacheForKey:(NSString *)key;

@end
