//
//  MNBaseSafeAreaUtil.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 30/11/17.
//

#import <Foundation/Foundation.h>

@interface MNBaseSafeAreaUtil : NSObject

/// Get the window-edge-insets for safe-area. Will return UIEdgeZero if not available
+ (UIEdgeInsets)getSafeAreaInsets;

/// Get the safe-area-layout from the view. Will return nil if not available.
+ (id _Nullable)getSafeAreaLayoutGuideFromView:(UIView *_Nonnull)view;

@end
