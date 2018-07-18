//
//  MNTestDevicesManager.h
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNTestDevicesManager : NSObject

+ (instancetype)getSharedInstance;
- (void)addDeviceId:(NSString *)deviceId;
- (NSArray<NSString *> *)getTestDeviceIds;

@end
