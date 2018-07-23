//
//  MNBasePublisherTimeoutSettings.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 04/01/18.
//

#import "MNBasePublisherTimeoutSettings.h"
#import "MNBaseConstants.h"

@implementation MNBasePublisherTimeoutSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        _gptrd        = [NSNumber numberWithInt:DEFAULT_GPT_DELAY];
        _prfd         = [NSNumber numberWithInt:DEFAULT_PREFETCH_DELAY];
        _hbDelayExtra = [NSNumber numberWithInt:DEFAULT_HB_EXTRA_DELAY];
    }
    return self;
}

@end
