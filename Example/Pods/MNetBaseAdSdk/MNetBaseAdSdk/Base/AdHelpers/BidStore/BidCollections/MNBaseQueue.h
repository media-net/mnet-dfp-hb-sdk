//
//  MNBaseQueue.h
//  Pods
//
//  Created by nithin.g on 07/09/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseQueue : NSObject

/// Enqueues an object with it's expiry
- (BOOL)enqueue:(NSObject *_Nonnull)object;

/// Pops from queue. If the data is expired, then it'll discard that data and pop again
- (NSObject *_Nullable)dequeue;

/// Peek the top of the queue
- (NSObject *_Nullable)peek;

/// Returns the length of the queue
- (NSUInteger)queueLen;

/// Get the list of contents from the queue
- (NSArray *_Nullable)getQueueContents;

/// Pop the element from the list
- (NSObject *_Nullable)popElementAtIndex:(NSUInteger)index;

@end
