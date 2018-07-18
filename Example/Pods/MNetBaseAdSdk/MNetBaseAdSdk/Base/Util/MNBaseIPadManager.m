//
//  MNBaseIPadManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 04/05/18.
//

#import "MNBaseIPadManager.h"

@interface MNBaseIPadManager ()
/// Stored value for isIPad
@property (atomic) NSNumber *isIPadVal;
@end

@implementation MNBaseIPadManager

static MNBaseIPadManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseIPadManager alloc] init];
    });
    return instance;
}

+ (BOOL)isIPad {
    return [[self getSharedInstance] detectIPad];
}

- (BOOL)detectIPad {
    @synchronized(self) {
        if (self.isIPadVal == nil) {
            void (^ipadDetectBlock)(void) = ^{
              BOOL isIPad    = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
              self.isIPadVal = [NSNumber numberWithBool:isIPad];
            };

            if ([NSThread isMainThread]) {
                ipadDetectBlock();
            } else {
                dispatch_sync(dispatch_get_main_queue(), ipadDetectBlock);
            }
        }

        if (self.isIPadVal != nil) {
            return [self.isIPadVal boolValue];
        }
        return NO;
    }
}

@end
