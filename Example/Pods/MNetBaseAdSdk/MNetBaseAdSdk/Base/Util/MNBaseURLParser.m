//
//  MNBaseURLParser.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 17/01/18.
//

#import "MNBaseURLParser.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

// MRAID Commands
static NSString *kCreateCalendarEventCommand  = @"createCalendarEvent";
static NSString *kCloseCommand                = @"close";
static NSString *kExpandCommand               = @"expand";
static NSString *kOpenCommand                 = @"open";
static NSString *kPlayVideoCommand            = @"playVideo";
static NSString *kSetOrientationCommand       = @"setOrientationProperties";
static NSString *kResizeCommand               = @"resize";
static NSString *kStorePictureCommand         = @"storePicture";
static NSString *kUseCustomCloseCommand       = @"useCustomClose";
static NSString *kTelCommand                  = @"tel";
static NSString *kShouldUseCostomCloseCommand = @"shouldUseCustomClose";

// YBNCA url handling
static NSString *kYBNCA = @"ybnca";

@interface MNBaseURLParser ()
- (BOOL)checkParamsForCommand:(NSString *)command params:(NSDictionary *)params;
@end

@implementation MNBaseURLParser

- (NSDictionary *)parseURL:(NSString *)urlString {
    if (urlString == nil || [urlString isEqualToString:@""]) {
        return nil;
    }
    NSURL *url        = [NSURL URLWithString:urlString];
    NSString *host    = url.host;
    NSString *command = host;

    // check if valid command return nil if not valid
    if ([[self getCommandsArray] containsObject:command] == NO) {
        return nil;
    }

    // Parse url and extract all parameters
    NSDictionary *params = [MNBaseUtil parseURL:url];

    // if command is kYBNCA return params
    if ([command isEqualToString:kYBNCA]) {
        return [params copy];
    }

    // Check for valid parameters for the given command.
    if ([self checkParamsForCommand:command params:params] == NO) {
        return nil;
    }

    NSObject *paramObj;

    if ([command isEqualToString:kCreateCalendarEventCommand]) {

        paramObj = [params valueForKey:@"eventJSON"];

    } else if ([command isEqualToString:kExpandCommand]) {

        NSMutableDictionary *expandDict = [[NSMutableDictionary alloc] init];
        [expandDict setValue:[params valueForKey:@"url"] forKey:@"url"];
        [expandDict setValue:[params valueForKey:kShouldUseCostomCloseCommand] forKey:kUseCustomCloseCommand];
        paramObj = expandDict;

    } else if ([command isEqualToString:kOpenCommand] || [command isEqualToString:kPlayVideoCommand] ||
               [command isEqualToString:kStorePictureCommand] || [command isEqualToString:kTelCommand]) {

        paramObj = [params valueForKey:@"url"];

    } else if ([command isEqualToString:kSetOrientationCommand] || [command isEqualToString:kResizeCommand]) {

        paramObj = params;

    } else if ([command isEqualToString:kUseCustomCloseCommand]) {

        paramObj = [params valueForKey:kShouldUseCostomCloseCommand];
    }

    NSMutableDictionary *commandDict = [@{@"command" : command} mutableCopy];
    if (paramObj) {
        commandDict[@"paramObj"] = paramObj;
    }

    return commandDict;
}

- (NSArray *)getCommandsArray {
    return @[
        kCreateCalendarEventCommand,
        kExpandCommand,
        kOpenCommand,
        kPlayVideoCommand,
        kSetOrientationCommand,
        kResizeCommand,
        kStorePictureCommand,
        kUseCustomCloseCommand,
        kTelCommand,
        kYBNCA,
    ];
}

- (BOOL)checkParamsForCommand:(NSString *)command params:(NSDictionary *)params {
    if ([command isEqualToString:kCreateCalendarEventCommand]) {

        return ([params valueForKey:@"eventJSON"] != nil);

    } else if ([command isEqualToString:kOpenCommand] || [command isEqualToString:kPlayVideoCommand] ||
               [command isEqualToString:kStorePictureCommand] || [command isEqualToString:kTelCommand]) {

        return ([params valueForKey:@"url"] != nil);

    } else if ([command isEqualToString:kSetOrientationCommand]) {

        return ([params valueForKey:@"allowOrientationChange"] != nil &&
                [params valueForKey:@"forceOrientation"] != nil);

    } else if ([command isEqualToString:@"resize"]) {

        return ([params valueForKey:@"width"] != nil && [params valueForKey:@"height"] != nil &&
                [params valueForKey:@"offsetX"] != nil && [params valueForKey:@"offsetY"] != nil &&
                [params valueForKey:@"customClosePosition"] != nil && [params valueForKey:@"allowOffscreen"] != nil);

    } else if ([command isEqualToString:kShouldUseCostomCloseCommand]) {

        return ([params valueForKey:kShouldUseCostomCloseCommand] != nil);
    }
    return YES;
}

@end
