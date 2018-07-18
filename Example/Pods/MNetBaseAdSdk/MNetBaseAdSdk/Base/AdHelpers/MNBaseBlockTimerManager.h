//
//  MNBaseBlockTimerManager.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 03/11/17.
//

#import <Foundation/Foundation.h>

@interface MNBaseBlockTimerManager : NSObject

@property (atomic) BOOL shouldCancelExecution;
@property (atomic) BOOL didTimeoutHandlerCall;

+ (instancetype)getInstanceWithTimeoutInMillis:(double)timeoutInMillis block:(void (^)(void))block;
- (void)cancel;

@end
