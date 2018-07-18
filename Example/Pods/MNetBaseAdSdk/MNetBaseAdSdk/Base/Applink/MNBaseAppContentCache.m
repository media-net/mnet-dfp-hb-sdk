//
//  MNBaseAppContentCache.m
//  Pods
//
//  Created by nithin.g on 02/08/17.
//
//

#import "MNBaseAppContentCache.h"

@interface MNBaseAppContentCache ()
@property (atomic) NSMutableArray<NSString *> *keysList;
@end

@implementation MNBaseAppContentCache
static MNBaseAppContentCache *instance;

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self      = [super init];
    _keysList = [[NSMutableArray alloc] init];
    return self;
}

- (BOOL)hasKey:(NSString *)key {
    @synchronized(self) {
        return [self.keysList containsObject:key];
    }
}

- (BOOL)addKey:(NSString *)key {
    @synchronized(self) {
        if ([self.keysList containsObject:key]) {
            return YES;
        }
        [self.keysList addObject:key];
        return YES;
    }
}

- (BOOL)flushCache {
    @synchronized(self) {
        [self.keysList removeAllObjects];
        return YES;
    }
}

@end
