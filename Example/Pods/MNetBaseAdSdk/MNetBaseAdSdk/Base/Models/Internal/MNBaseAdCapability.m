//
//  MNBaseAdCapability.m
//  Pods
//
//  Created by nithin.g on 19/05/17.
//
//
#import <objc/runtime.h>

#import "MNBaseAdCapability.h"
#import "MNBaseConstants.h"

@implementation MNBaseAdCapability

- (instancetype)init {
    self = [super init];
    [self getDefaultCapability];
    return self;
}

- (void)getDefaultCapability {
    self.banner           = [MNJMBoolean createWithBool:YES];
    self.responsiveBanner = [MNJMBoolean createWithBool:YES];
    self.video            = [MNJMBoolean createWithBool:YES];
    self.rewardedVideo    = [MNJMBoolean createWithBool:YES];
    self.native           = [MNJMBoolean createWithBool:NO];
    self.audio            = [MNJMBoolean createWithBool:NO];
    self.mraid            = [MNJMBoolean createWithBool:YES];
}

- (bool)isClassPresent:(NSString *)classStr {
    Class controllerClass = objc_getClass([classStr UTF8String]);
    return (controllerClass != nil);
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}
@end
