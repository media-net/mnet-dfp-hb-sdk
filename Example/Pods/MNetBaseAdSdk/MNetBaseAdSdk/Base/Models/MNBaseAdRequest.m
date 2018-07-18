//
//  MNBaseAdRequest.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdRequest+Internal.h"
#import "MNBaseLinkStore.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import <MNALAppLink/MNALAppLink.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdRequest () <MNJMMapperProtocol>

@end

@implementation MNBaseAdRequest

+ (MNBaseAdRequest *)newRequest {
    MNBaseAdRequest *adRequest = [[MNBaseAdRequest alloc] init];
    return adRequest;
}

- (NSDictionary *)addExtraWith:(NSString *)key andValue:(NSString *)value {
    if (self.extras == nil) {
        self.extras = [[NSDictionary alloc] init];
    }
    [self.extras setValue:value forKey:key];
    return self.extras;
}

- (void)updateContextLink {
    if (self.contextLink != nil) {
        return;
    }

    if (self.rootViewController == nil) {
        void (^getTopViewController)(void) = ^{
          self.rootViewController = [MNBaseUtil getTopViewController];
        };
        if ([NSThread isMainThread]) {
            getTopViewController();
        } else {
            dispatch_sync(dispatch_get_main_queue(), getTopViewController);
        }
    }

    if (self.rootViewController == nil) {
        MNLogD(@"Unable to get any top-view-controller.");
        return;
    }

    NSString *extUrl = [MNBaseUtil getLinkForVC:self.rootViewController];
    MNLogD(@"LINK: %@", extUrl);

    if (extUrl != nil) {
        [[MNBaseLinkStore getSharedInstance] setLink:extUrl];
        self.contextLink = extUrl;
    }
}

- (void)updateVCTitle {
    if (self.viewControllerTitle != nil) {
        return;
    }

    if (self.rootViewController == nil) {
        self.rootViewController = [MNBaseUtil getTopViewController];
    }

    self.viewControllerTitle = [MNBaseUtil getViewControllerTitle:self.rootViewController];
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

@end
