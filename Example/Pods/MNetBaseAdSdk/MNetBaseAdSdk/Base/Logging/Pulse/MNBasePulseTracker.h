//
//  MNBasePulseTracker.h
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBasePulseEventName.h"
#import <Foundation/Foundation.h>

@interface MNBasePulseTracker : NSObject
+ (void)logDeviceInfoAsync;

+ (void)logRemoteCustomEventType:(NSString *)type andCustomData:(id)customData;

+ (void)logRemoteCustomEventType:(NSString *)type withMessage:(NSString *)message andCustomData:(id)customData;
@end
