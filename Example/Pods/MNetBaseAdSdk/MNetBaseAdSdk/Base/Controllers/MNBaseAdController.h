//
//  MNBaseAddController.h
//  Pods
//
//  Created by akshay.d on 20/02/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseBidResponsesContainer.h"
#import <Foundation/Foundation.h>

@protocol MNBaseAdControllerDelegate;
@protocol MNBaseVideoAdControllerDelegate;
@protocol MNBaseAdControllerSizeDelegate;

@interface MNBaseAdController : NSObject

@property MNBaseBidResponse *adResponse;
@property MNBaseBidResponsesContainer *responsesContainer;

@property BOOL isInterstitial;
@property (weak, atomic) UIViewController *rootViewController;

@property (weak, atomic) id<MNBaseAdControllerDelegate> delegate;
@property (weak, atomic) id<MNBaseVideoAdControllerDelegate> videoControllerDelegate;
@property (weak, atomic) id<MNBaseAdControllerSizeDelegate> adSizeControllerDelegate;

- (BOOL)processResponse;
- (bool)isReady;
- (void)invalidate;
- (void)showAdFromRootViewController;
- (void)restart;
- (void)makeLoggingBeaconsReq;
- (void)makeInAdLoggingReq;
- (void)logAdClickedEvent:(BOOL)isInterstitial;

@end

@protocol MNBaseAdControllerSizeDelegate <NSObject>
- (void)adViewDidChangeSize:(CGSize)size;
@end

@protocol MNBaseAdControllerDelegate <NSObject>

- (void)adDidLoad;
- (void)adDidShow;
- (void)adViewCreated:(UIView *)view;
- (void)adDidFail:(NSError *)error;
- (void)adGotClicked;
- (void)adDidClose;
- (void)adViewVisible;
- (void)adViewNotVisible;

@end

@protocol MNBaseVideoAdControllerDelegate <NSObject>

- (void)videoDidStarted;
- (void)videoDidCompleted;
- (void)videoDidShow;
- (void)videoViewCreated:(UIView *)view;
- (void)videoAdDidFail:(NSError *)error;
- (void)videoAdDidLoad;
- (void)videoAdDidGetDuration:(NSNumber *)duration;
- (void)videoGotClicked;
- (void)videoGotDismissed;

@end
