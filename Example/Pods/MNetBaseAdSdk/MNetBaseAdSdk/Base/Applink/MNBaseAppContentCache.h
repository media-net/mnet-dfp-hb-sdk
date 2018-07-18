//
//  MNBaseAppContentCache.h
//  Pods
//
//  Created by nithin.g on 02/08/17.
//
//

#import <Foundation/Foundation.h>

/// This is an in-memory store for the links whose content
/// is already in pulse.
/// NOTE: If the app is restarted, this is reset
@interface MNBaseAppContentCache : NSObject
+ (instancetype)getSharedInstance;
- (BOOL)hasKey:(NSString *)key;
- (BOOL)addKey:(NSString *)key;
- (BOOL)flushCache;

- (instancetype)init __attribute__((unavailable("Please use getSharedInstance")));

@end
