//
//  MNJMLRUManager.m
//  MNetJSONModeller
//
//  Created by nithin.g on 29/10/17.
//

#import "MNJMLRUManager+Internal.h"

// Fall back to this if the provided cacheLimit is 0
static NSUInteger defaultCacheLimit = 20;

@implementation MNJMLRUManager

+ (instancetype _Nullable)getInstanceWithLimit:(NSUInteger)cacheLimit {
    MNJMLRUManager *instance = [[MNJMLRUManager alloc] initWithLimit:cacheLimit];
    return instance;
}

- (instancetype)initWithLimit:(NSUInteger)cacheLimit {
    self = [super init];
    if (self) {
        if (cacheLimit == 0) {
            cacheLimit = defaultCacheLimit;
        }
        self.cacheLimit = cacheLimit;
        [self initializeCollections];
    }
    return self;
}

- (void)initializeCollections {
    self.entryList = [[NSMutableArray alloc] initWithCapacity:self.cacheLimit];
    self.entryMap  = [[NSMutableDictionary alloc] initWithCapacity:self.cacheLimit];
}

- (void)clearCache {
    @synchronized(self) {
        [self initializeCollections];
    }
}

- (BOOL)addEntry:(id)entry withKey:(NSString *)key {
    if (entry == nil || key == nil || [key isEqualToString:@""]) {
        return NO;
    }
    @synchronized(self) {
        if ([self.entryList containsObject:key]) {
            return NO;
        }
        [self.entryMap setValue:entry forKey:key];
        [self.entryList addObject:key];
        [self removeOldEntries];
    }
    return YES;
}

- (void)removeOldEntries {
    @synchronized(self) {
        while ([self.entryList count] > self.cacheLimit) {
            NSString *removedKey = [self.entryList objectAtIndex:0];
            [self.entryList removeObjectAtIndex:0];
            [self.entryMap removeObjectForKey:removedKey];
        }
    }
}

- (id _Nullable)getEntryforKey:(NSString *)key {
    if (key == nil || [key isEqualToString:@""]) {
        return nil;
    }
    @synchronized(self) {
        id entry = [self.entryMap objectForKey:key];
        if (entry == nil) {
            return nil;
        }

        [self.entryList removeObject:key];
        [self.entryList addObject:key];
        return entry;
    }
}

- (id _Nullable)removeEntryForKey:(NSString *)key {
    if (key == nil || [key isEqualToString:@""]) {
        return nil;
    }

    @synchronized(self) {
        id entry = [self.entryMap objectForKey:key];
        if (entry == nil) {
            return nil;
        }

        [self.entryMap removeObjectForKey:key];
        [self.entryList removeObject:key];
        return entry;
    }
}

@end
