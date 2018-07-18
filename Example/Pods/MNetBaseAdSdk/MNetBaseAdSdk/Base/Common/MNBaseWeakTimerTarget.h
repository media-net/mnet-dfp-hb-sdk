//
//  MNBaseWeakTimerTarget.h
//  Pods
//
//  Created by nithin.g on 04/04/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseWeakTimerTarget : NSObject

@property (weak, atomic) id target;
@property (atomic) SEL selector;
@property (atomic, readonly) SEL timerFireTargetSelector;

- (id)init;
- (void)timerDidFire:(NSTimer *)timer;

@end
