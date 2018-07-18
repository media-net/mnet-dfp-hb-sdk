//
//  MNBaseSafeAreaUtil.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 30/11/17.
//

#import "MNBaseSafeAreaUtil.h"
#import "MNBaseInvoker.h"

@implementation MNBaseSafeAreaUtil

/// Get the window-edge-insets for safe-area. Will return UIEdgeZero if not available
+ (UIEdgeInsets)getSafeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;

    if ([self isAtleastIos11]) {
        SEL safeAreaSel  = NSSelectorFromString(@"safeAreaInsets");
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        if ([window respondsToSelector:safeAreaSel]) {
            [MNBaseInvoker invoke:safeAreaSel on:window returns:&safeAreaInsets with:nil];
        }
    }

    return safeAreaInsets;
}

+ (id _Nullable)getSafeAreaLayoutGuideFromView:(UIView *_Nonnull)view {
    if (view == nil || NO == [self isAtleastIos11]) {
        return nil;
    }

    id safeLayoutGuide;
    SEL safeAreaLayoutGuideSel = NSSelectorFromString(@"safeAreaLayoutGuide");
    if ([view respondsToSelector:safeAreaLayoutGuideSel]) {
        __unsafe_unretained id unsafeLayoutGuide;
        [MNBaseInvoker invoke:safeAreaLayoutGuideSel on:view returns:&unsafeLayoutGuide with:nil];
        safeLayoutGuide = unsafeLayoutGuide;
    }
    return safeLayoutGuide;
}

+ (BOOL)isAtleastIos11 {
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){11, 0, 0}];
}

@end
