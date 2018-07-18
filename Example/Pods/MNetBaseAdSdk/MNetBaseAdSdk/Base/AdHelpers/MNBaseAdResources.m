//
//  MNBaseAdResources.m
//  Pods
//
//  Created by nithin.g on 11/07/17.
//
//

#import "MNBaseAdResources.h"

@implementation MNBaseAdResources

NSString *MNET_CLICKTHROUGH_WEBVIEW_BACK    = @"MNBaseWebviewBack.png";
NSString *MNET_CLICKTHROUGH_WEBVIEW_FORWARD = @"MNBaseWebviewForward.png";
NSString *MNET_CLICKTHROUGH_WEBVIEW_RELOAD  = @"MNBaseWebviewReload.png";
NSString *MNET_CLICKTHROUGH_WEBVIEW_CLOSE   = @"MNBaseWebviewClose.png";
NSString *MNET_ADVIEW_CLOSE_BTN             = @"MNClose.png";
NSString *MNET_ADVIEW_VIDEO_MUTE            = @"MNMute.png";
NSString *MNET_ADVIEW_VIDEO_UNMUTE          = @"MNSound.png";
NSString *MNET_ADVIEW_VIDEO_RELOAD          = @"MNReload.png";
NSString *MNET_ADVIEW_VIDEO_EXPAND          = @"MNExpand.png";
NSString *MNET_ADVIEW_PLAY_BUTTON           = @"MNPlayButton.png";

+ (NSString *)getDarkThemeForResource:(NSString *)resourceStr {
    NSString *modifiedResourceStr = resourceStr;

    NSString *darkSuffix                      = @"Dark";
    NSString *sep                             = @".";
    NSMutableArray<NSString *> *resourceParts = [[resourceStr componentsSeparatedByString:sep] mutableCopy];

    if ([resourceParts count] > 1) {
        NSUInteger penUltimateIndex = ([resourceParts count] - 2);
        NSString *penUltimateStr    = [resourceParts objectAtIndex:penUltimateIndex];
        NSString *modifiedStr       = [penUltimateStr stringByAppendingString:darkSuffix];
        [resourceParts setObject:modifiedStr atIndexedSubscript:penUltimateIndex];

        modifiedResourceStr = [resourceParts componentsJoinedByString:sep];
    }

    return modifiedResourceStr;
}

@end
