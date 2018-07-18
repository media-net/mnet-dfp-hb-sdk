//
//  MNBaseAppExternalData.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 31/10/17.
//

#import "MNBaseAppExternalData.h"
#import "MNBaseUtil.h"

@implementation MNBaseAppExternalData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hostAppVersionId = [MNBaseUtil getHostAppVersionId];
    }
    return self;
}

- (NSDictionary *)propertyKeyMap {
    return @{@"hostAppVersionId" : @"ver_code"};
}

@end
