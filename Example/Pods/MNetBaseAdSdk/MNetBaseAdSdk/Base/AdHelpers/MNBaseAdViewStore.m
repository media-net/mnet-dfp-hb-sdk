//
//  MNBaseAdViewStore.m
//  Pods
//
//  Created by nithin.g on 10/05/17.
//
//

#import "MNBaseAdViewStore.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import "MNBaseWeakTimerTarget.h"

@interface MNBaseAdViewStore ()
@property (atomic) NSMutableDictionary<NSString *, MNBaseAdViewStoreEntry *> *viewBuffer;
@end

@implementation MNBaseAdViewStore

static dispatch_once_t onceToken;
static MNBaseAdViewStore *sInstance = nil;

+ (id)getsharedInstance {
    dispatch_once(&onceToken, ^{
      sInstance = [[self alloc] init];
    });
    return sInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _viewBuffer = [[NSMutableDictionary alloc] init];
        _defaultTtl = [[MNBaseSdkConfig getInstance] getAdViewCacheDuration];
    }
    return self;
}

- (BOOL)addViewToStore:(UIView *)adView withKey:(NSString *)key {
    @synchronized(self.viewBuffer) {
        BOOL adViewValidation = (NO == [MNBaseUtil isNil:adView]);
        BOOL keyValidation    = (key != nil && ![key isEqualToString:@""]);

        if (adViewValidation && keyValidation) {
            MNBaseAdViewStoreEntry *adViewEntry = [[MNBaseAdViewStoreEntry alloc] initWithAdView:adView];
            [self.viewBuffer setObject:adViewEntry forKey:key];

            MNBaseWeakTimerTarget *timerTarget = [[MNBaseWeakTimerTarget alloc] init];
            [timerTarget setTarget:self];
            [timerTarget setSelector:NSSelectorFromString(@"timerExpiredCallback:")];

            // Start a self-destructing timer
            [NSTimer scheduledTimerWithTimeInterval:[self.defaultTtl longValue]
                                             target:timerTarget
                                           selector:timerTarget.timerFireTargetSelector
                                           userInfo:key
                                            repeats:NO];
            return YES;
        }

        return NO;
    }
}

- (void)timerExpiredCallback:(NSTimer *)timer {
    if (timer == nil) {
        return;
    }

    NSString *keyToRemove = (NSString *) timer.userInfo;
    if (keyToRemove != nil) {
        UIView *adView = [self popViewForKey:keyToRemove];
        [self reuseAdView:adView];
    }

    [timer invalidate];
    timer = nil;
}

- (BOOL)reuseAdView:(UIView *)adView {
    if (adView == nil) {
        MNLogD(@"Cannot reuse-ad-view since ad-view is nil");
        return NO;
    }
    // TODO MNBase refactor this code
    /*
    if (NO == [adView isKindOfClass:[MNBaseAdView class]]) {
        return NO;
    }

    MNBaseAdView *mnetAdView = (MNBaseAdView *) adView;
    if ([mnetAdView canCacheView]) {
        [mnetAdView loadAd];
        NSString *adUnitId = [[mnetAdView adRequest] adUnitId];

        //[[MNBaseAdViewReuseRepository getSharedInstance] cacheAdView:mnetAdView withCreativeId:adUnitId];
    } else {
        [mnetAdView recycleBids];
    }
     */
    return YES;
}

- (UIView *)getViewForKey:(NSString *)key {
    MNBaseAdViewStoreEntry *adViewEntry = [self.viewBuffer objectForKey:key];
    if (!adViewEntry) {
        return nil;
    }
    @synchronized(self.viewBuffer) {
        return [adViewEntry getView];
    }
}

- (UIView *)popViewForKey:(NSString *)key {
    @synchronized(self.viewBuffer) {
        UIView *adView = [self getViewForKey:key];
        [self.viewBuffer removeObjectForKey:key];
        return adView;
    }
}

@end

@interface MNBaseAdViewStoreEntry ()
@property (atomic) UIView *adView;

@end

@implementation MNBaseAdViewStoreEntry

- (instancetype)initWithAdView:(UIView *)adView {
    self = [super init];
    if (self) {
        _adView = adView;
    }
    return self;
}

- (UIView *)getView {
    return self.adView;
}

@end
