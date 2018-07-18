//
//  MNBaseNotificationNames.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 04/01/18.
//

#import <Foundation/Foundation.h>

extern NSString *_Nonnull const MNBaseNotificationSdkConfigUpdated;

@interface MNBaseNotificationManager : NSObject
+ (BOOL)postNotificationWithName:(NSString *_Nonnull)notificationName;
+ (id _Nullable)addObserverToNotification:(NSString *_Nonnull)notificationName
                                withBlock:(void (^_Nonnull)(NSNotification *_Nonnull))notifyBlock;
+ (BOOL)removeObserver:(id _Nonnull)observer withName:(NSString *_Nonnull)notificationName;
@end
