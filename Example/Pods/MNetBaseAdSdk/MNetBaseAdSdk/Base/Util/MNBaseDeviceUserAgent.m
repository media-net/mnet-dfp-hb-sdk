//
//  MNBaseDeviceUserAgent.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/02/18.
//

#import "MNBaseDeviceUserAgent.h"

@interface MNBaseDeviceUserAgent ()
@property (atomic) NSString *userAgent;
@end

@implementation MNBaseDeviceUserAgent

+ (void)load {
    [self getSharedInstance];
}

static MNBaseDeviceUserAgent *sharedInstance;

+ (id)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [MNBaseDeviceUserAgent new];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self updateUserAgent];
    }
    return self;
}

- (void)updateUserAgent {
    void (^updateBlock)(void) = ^{
      UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
      self.userAgent     = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    };

    // Run updateBlock only on main-thread
    if ([NSThread isMainThread]) {
        updateBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), updateBlock);
    }
}

+ (NSString *)getDeviceUserAgent {
    return [[self getSharedInstance] userAgent];
}

@end
