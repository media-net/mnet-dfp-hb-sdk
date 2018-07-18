//
//  MNBaseInvoker.h
//  Pods
//
//  Created by akshay.d on 22/02/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseInvoker : NSObject

+ (void)listSelectors:(id)t;

/// Invokes a selector for a particular target. Any return value will need to be passed.
/// If error is encountered, it's returned
+ (NSError *_Nullable)invoke:(SEL)selector
                          on:(id _Nonnull)target
                     returns:(void *)returnVal
                        with:(id _Nullable)params, ...;

/// Invokes a selector for a particular target and returns the value if any.
/// If error is encountered, it's silently logged and the return value is nil.
/// Use `invoke:on:returns:with:` if error is needed
+ (id _Nullable)invoke:(SEL)selector on:(id _Nonnull)target withDictParam:(NSDictionary *_Nonnull)param;

/// Invokes a selector for a particular target and returns the value if any.
/// If error is encountered, it's silently logged and the return value is nil.
/// Use `invoke:on:returns:with:` if error status is needed
+ (id _Nullable)invoke:(SEL)selector on:(id _Nonnull)target with:(id _Nullable)params, ...;

@end
