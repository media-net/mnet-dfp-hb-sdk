//
//  MNTestDevicesManager.m
//  MNetDfpHbSdk_Example
//
//  Created by nithin.g on 09/07/18.
//  Copyright © 2018 gnithin. All rights reserved.
//

#import "MNTestDevicesManager.h"

@interface MNTestDevicesManager ()
@property (nonnull) NSMutableArray<NSString *> *testDevicesList;
@end

@implementation MNTestDevicesManager

static MNTestDevicesManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNTestDevicesManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _testDevicesList = [[NSMutableArray<NSString *> alloc] init];
    }
    return self;
}

- (void)addDeviceId:(NSString *)deviceId {
    [self.testDevicesList addObject:deviceId];
}

- (NSArray<NSString *> *)getTestDeviceIds {
    if (self.testDevicesList == nil || [self.testDevicesList count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:self.testDevicesList];
}

@end
