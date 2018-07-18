//
//  MNBaseQueue.m
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import "MNBaseQueue+Internal.h"
#import "MNBaseUtil.h"

@implementation MNBaseQueue

- (instancetype)init {
    self      = [super init];
    _dataList = [[NSMutableArray alloc] init];
    return self;
}

- (BOOL)enqueue:(NSObject *_Nonnull)data {
    if (data == nil) {
        return NO;
    }

    @synchronized(self) {
        [self.dataList addObject:data];
        return YES;
    }
}

- (NSObject *_Nullable)dequeue {
    @synchronized(self) {
        if ([self isEmptyQueue]) {
            return nil;
        }
        NSObject *poppedEntry = [self.dataList objectAtIndex:0];
        if (poppedEntry == nil) {
            return nil;
        }

        [self.dataList removeObjectAtIndex:0];
        return poppedEntry;
    }
}

- (NSObject *_Nullable)peek {
    @synchronized(self) {
        if ([self isEmptyQueue]) {
            return nil;
        }

        NSObject *topEntry = [self.dataList objectAtIndex:0];
        if (topEntry == nil) {
            return nil;
        }
        return topEntry;
    }
}

- (BOOL)isEmptyQueue {
    @synchronized(self) {
        return [self.dataList count] == 0;
    }
}

- (NSUInteger)queueLen {
    @synchronized(self) {
        return [self.dataList count];
    }
}

/// Get the list of contents from the queue
- (NSArray *_Nullable)getQueueContents {
    if (self.dataList == nil) {
        return nil;
    }
    return [NSArray arrayWithArray:self.dataList];
}

/// Pop the element from the list
- (NSObject *_Nullable)popElementAtIndex:(NSUInteger)index {
    if (self.dataList == nil || index >= [self.dataList count]) {
        return nil;
    }
    NSObject *element = [self.dataList objectAtIndex:index];
    [self.dataList removeObjectAtIndex:index];
    return element;
}

@end
