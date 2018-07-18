//
//  MNBaseAppContentManager.h
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import <Foundation/Foundation.h>

/// This class instance is responsible for sending content-data to pulse
@interface MNBaseAppContentManager : NSObject
- (instancetype)initWithAdUnitId:(NSString *)adUnitId andAdCycleId:(NSString *)adCycleId;
- (BOOL)sendContentForLink:(NSString *)originalCrawlingLink andViewController:(UIViewController *)viewController;
@end
