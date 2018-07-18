//
//  MNBaseInvoker.m
//  Pods
//
//  Created by akshay.d on 22/02/17.
//
//

#import "MNBaseInvoker.h"
#import "MNBaseError.h"
#import "MNBaseLogger.h"
#import <objc/runtime.h>

@implementation MNBaseInvoker

+ (void)listSelectors:(id)t {
    int i           = 0;
    unsigned int mc = 0;
    Method *mlist   = class_copyMethodList(object_getClass(t), &mc);
    MNLogD(@"%d methods", mc);
    for (i = 0; i < mc; i++)
        MNLogD(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
}

/// Invokes a selector for a particular target and returns the value if any.
/// If error is encountered, it's silently logged and the return value is nil.
/// Use `invoke:on:returns:with:` if error is needed
+ (id _Nullable)invoke:(SEL)selector on:(id _Nonnull)target withDictParam:(NSDictionary *_Nonnull)param {
    if (param == nil) {
        MNLogD(@"Param in invoke:on:withDictParam: cannot be nil");
        return nil;
    }
    return [self invoke:selector on:target with:@[ param ]];
}

/// Invokes a selector for a particular target and returns the value if any.
/// If error is encountered, it's silently logged and the return value is nil.
/// Use `invoke:on:returns:with:` if error status is needed
+ (id _Nullable)invoke:(SEL)selector on:(id _Nonnull)target with:(id _Nullable)params, ... {
    __unsafe_unretained id retVal;
    [self invoke:selector on:target returns:&retVal with:params];
    return retVal;
}

/// Invokes a selector for a particular target. Any return value will need to be passed.
/// If error is encountered, it's returned
+ (NSError *_Nullable)invoke:(SEL)selector
                          on:(id _Nonnull)target
                     returns:(void *)returnVal
                        with:(id _Nullable)params, ... {
    @try {
        NSError *targetErr = [self validateTarget:target forSel:selector];
        if (targetErr != nil) {
            MNLogD(@"Target validation err - %@", targetErr);
            return targetErr;
        }

        NSMethodSignature *methodSig = [[target class] instanceMethodSignatureForSelector:selector];
        NSUInteger numArgs           = 0;
        if (params != nil) {
            numArgs = [params count];
        }
        // Default args are self & _cmd
        numArgs += 2;
        // If the number of args are less, then nil is passed as default
        if (numArgs > [methodSig numberOfArguments]) {
            NSError *numberArgsErr =
                [MNBaseError createErrorWithDescription:@"Got more number of arguments than the selector supports"];
            return numberArgsErr;
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setSelector:selector];
        [invocation setTarget:target];
        // passing arguments
        int i = 2;
        for (id param in params) {
            [invocation setArgument:(void *) &param atIndex:i++];
        }
        [invocation invoke];
        if ([[invocation methodSignature] methodReturnLength] != 0) {
            [invocation getReturnValue:returnVal];
        }
    } @catch (NSException *invokeException) {
        NSString *exceptionStr =
            [NSString stringWithFormat:@"EXCEPTION: exception raised in invokeWithReturnVal - %@", invokeException];
        MNLogE(@"Invoke exception! - %@", exceptionStr);
        NSError *exceptionErr = [MNBaseError createErrorWithDescription:exceptionStr];
        return exceptionErr;
    }
    return nil;
}

+ (NSError *)validateTarget:(id)target forSel:(SEL)selector {
    if (target == nil || selector == nil) {
        NSString *errMsg;
        if (target == nil && selector == nil) {
            errMsg = [NSString stringWithFormat:@"Target and selector are both empty!"];
        } else if (target == nil) {
            errMsg = [NSString stringWithFormat:@"Target is empty for selector - %@!", NSStringFromSelector(selector)];
        } else {
            errMsg =
                [NSString stringWithFormat:@"Selector is empty for target - %@!", NSStringFromClass([target class])];
        }
        return [MNBaseError createErrorWithDescription:errMsg];
    }
    // Check for respondsToSelector
    if (NO == [target respondsToSelector:selector]) {
        NSString *errMsg =
            [NSString stringWithFormat:@"respondsToSelector failed - Target - %@ selector - %@",
                                       NSStringFromClass([target class]), NSStringFromSelector(selector)];
        return [MNBaseError createErrorWithDescription:errMsg];
    }
    return nil;
}

@end
