//
//  MNBaseAdIdManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 19/12/17.
//

#import "MNBaseAdIdManager.h"
#import "MNBase.h"
#import "MNBaseUtil.h"
#import <AdSupport/ASIdentifierManager.h>

static NSString *kCustomAdIdKeyChainKey = @"keychainKey";
static NSString *kCustomAdIdFilename    = @"MNBaseCustomAdId.txt";

@interface MNBaseAdIdManager ()
@property (nonnull) NSString *customAdId;
@end

@implementation MNBaseAdIdManager

static MNBaseAdIdManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseAdIdManager alloc] init];
    });
    return instance;
}

- (NSString *)getAdvertId {
    NSString *adId;
    ASIdentifierManager *adManager = [ASIdentifierManager sharedManager];
    if (NO == [[MNBase getInstance] appContainsChildDirectedContent] && [adManager isAdvertisingTrackingEnabled]) {
        adId = [[adManager advertisingIdentifier] UUIDString];
    } else {
        adId = [self getCustomId];
    }

    /*
     From the docs -
     "If the value is nil, wait and get the value again later.
     This happens, for example, after the device has been restarted but before the user has unlocked the device."
     This was observed once, randomly, on the iOS 11 device (though it had nothing to do with restarting).
    */
    if (adId == nil) {
        adId = @"";
    }
    return adId;
}

#pragma mark - Generate and maintain the custom ad-id
- (NSString *)getCustomId {
    if (self.customAdId != nil) {
        return self.customAdId;
    }
    NSString *customId = [self readCustomIdFromStore];
    if (customId == nil) {
        customId = [MNBaseUtil createId];
        [self writeCustomIdToStore:customId];
    }
    self.customAdId = customId;
    return customId;
}

- (NSString *)readCustomIdFromStore {
    NSString *customId =
        [MNBaseUtil readFromFileName:kCustomAdIdFilename withFolder:[MNBaseUtil getSupportDirectoryPath]];

    if (customId == nil || [customId isEqualToString:@""]) {
        // Check in the keystore
        customId = [MNBaseUtil readFromKeyChainForKey:kCustomAdIdKeyChainKey];
        if (customId == nil && [customId isEqualToString:@""]) {
            customId = nil;
        }
    }
    return customId;
}

- (void)writeCustomIdToStore:(NSString *)customId {
    if (customId == nil || [customId isEqualToString:@""]) {
        return;
    }
    [MNBaseUtil writeToFileName:kCustomAdIdFilename
                     withFolder:[MNBaseUtil getSupportDirectoryPath]
                   withContents:customId];
    [MNBaseUtil writeToKeyChain:customId withKey:kCustomAdIdKeyChainKey];
}

@end
