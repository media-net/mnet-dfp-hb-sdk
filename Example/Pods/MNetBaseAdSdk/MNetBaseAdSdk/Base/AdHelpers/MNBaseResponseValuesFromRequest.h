//
//  MNBaseResponseValuesFromRequest.h
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import <Foundation/Foundation.h>

/// The properties represent the values that need to be copied from the
/// request object.
@interface MNBaseResponseValuesFromRequest : NSObject

@property (atomic, nonnull) NSString *adUnitId;
@property (atomic, nonnull) NSString *visitId;
@property (atomic, nonnull) NSString *adCycleId;
@property (atomic, nonnull) NSString *contextUrl;
@property (atomic, nonnull) NSString *viewControllerTitle;
@property (atomic, nonnull) UIViewController *viewController;
@property (atomic) NSString *_Nullable predictionId;
@property (atomic) NSString *_Nullable keywords;

@end
