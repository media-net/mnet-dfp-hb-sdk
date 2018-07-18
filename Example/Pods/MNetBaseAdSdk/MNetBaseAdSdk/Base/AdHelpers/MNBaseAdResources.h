//
//  MNBaseAdResources.h
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import <Foundation/Foundation.h>

extern NSString *MNET_CLICKTHROUGH_WEBVIEW_BACK;
extern NSString *MNET_CLICKTHROUGH_WEBVIEW_FORWARD;
extern NSString *MNET_CLICKTHROUGH_WEBVIEW_RELOAD;
extern NSString *MNET_CLICKTHROUGH_WEBVIEW_CLOSE;
extern NSString *MNET_ADVIEW_CLOSE_BTN;
extern NSString *MNET_ADVIEW_VIDEO_MUTE;
extern NSString *MNET_ADVIEW_VIDEO_UNMUTE;
extern NSString *MNET_ADVIEW_VIDEO_RELOAD;
extern NSString *MNET_ADVIEW_VIDEO_EXPAND;
extern NSString *MNET_ADVIEW_PLAY_BUTTON;

@interface MNBaseAdResources : NSObject
+ (NSString *)getDarkThemeForResource:(NSString *)resourceStr;
@end
