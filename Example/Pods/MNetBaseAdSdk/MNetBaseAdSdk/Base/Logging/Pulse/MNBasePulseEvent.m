//
//  MNBasePulseEvent.m
//  Pods
//
//  Created by nithin.g on 27/02/17.
//
//

#import "MNBasePulseEvent.h"
#import "MNBase.h"
#import "MNBaseAdIdManager.h"
#import "MNBaseConstants.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import "MNBaseUtil.h"

typedef enum {
    MNET_PULSE_CATEGORY_EVENT,
    MNET_PULSE_CATEGORY_LOG,
    MNET_PULSE_CATEGORY_ERROR,
    MNET_PULSE_CATEGORY_NONE,
} MNET_PULSE_CATEGORIES;

@interface MNBasePulseEvent ()
@property (atomic) NSString *__subTag;
@property (atomic) NSString *__customMessage;
@property (atomic) BOOL __isCustomDataADictionary;
@property (atomic) BOOL __isForcedEvent;
@end

@implementation MNBasePulseEvent

#pragma mark - Init methods
- (MNBasePulseEvent *)initWithType:(NSString *)tag
                       withSubType:(NSString *)subType
                       withMessage:(NSString *)message
                     andCustomData:(id)customData {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    if (customData == nil || NO == [customData isKindOfClass:[NSObject class]]) {
        customData = @{};
    }

    if (message == nil) {
        message = @"";
    }
    if (tag == nil) {
        // Get the default tag
        tag = MNBasePulseEventDefault;
    }
    ___subTag = subType;
    if (message == nil) {
        message = @"";
    }
    ___customMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _timestamp       = [MNBaseUtil getTimestamp];
    _tag             = tag;
    _loggingLevel    = @"";
    _loggingService  = @"";
    _platform        = PLATFORM_NAME;

    // Generating output for the particular type of event and sub-event
    _eventObj = [self generateEventForCustomData:customData withMessage:message];
    return self;
}

#pragma mark - Processing custom data
- (NSDictionary *)generateEventForCustomData:(id)customData withMessage:message {
    MNET_PULSE_CATEGORIES currentCategory;
    NSArray *eventTypes = @[
        MNBasePulseEventDevice, MNBasePulseEventNetwork, MNBasePulseEventLocation, MNBasePulseEventDeviceLang,
        MNBasePulseEventTimezone, MNBasePulseEventAddress, MNBasePulseEventUserAgent
    ];

    if (self.__isForcedEvent || [eventTypes containsObject:self.tag]) {
        currentCategory = MNET_PULSE_CATEGORY_EVENT;
    } else if ([self.tag isEqualToString:MNBasePulseEventError]) {
        currentCategory = MNET_PULSE_CATEGORY_ERROR;
    } else if ([self.tag isEqualToString:MNBasePulseEventLog]) {
        currentCategory = MNET_PULSE_CATEGORY_LOG;
    } else {
        currentCategory = MNET_PULSE_CATEGORY_NONE;
    }

    if (!self.__subTag && currentCategory == MNET_PULSE_CATEGORY_EVENT) {
        self.__subTag = @"sdk_data";
    }
    NSDictionary *parsedResponse;
    self.__isCustomDataADictionary = [customData isKindOfClass:[NSDictionary class]];

    NSDictionary *customDataDict = (NSDictionary *) [MNJMManager getCollectionFromObj:customData];
    if (customDataDict) {
        parsedResponse = [self prepareParsedResponseForDict:customDataDict forType:currentCategory];
    }

    if (!parsedResponse) {
        parsedResponse = @{};
    }
    return parsedResponse;
}

- (NSDictionary *)prepareParsedResponseForDict:(NSDictionary *)customDataDict
                                       forType:(MNET_PULSE_CATEGORIES)currentCategory {
    NSNumber *timestamp = [MNBaseUtil getTimestamp];
    NSString *adId      = [[MNBaseAdIdManager getSharedInstance] getAdvertId];
    if (adId == nil) {
        adId = @"";
    }

    NSMutableDictionary *parsedResponse = [[NSMutableDictionary alloc] init];

    // Add the corresponding data based on type
    if (currentCategory == MNET_PULSE_CATEGORY_EVENT) {
        if (!self.__isCustomDataADictionary) {
            // Filter out the unnecessary types depending on the type
            customDataDict = [self filterKeysOfDict:customDataDict forType:self.tag];
        }

        parsedResponse =
            [@{@"event_type" : self.__subTag, @"params" : customDataDict, @"event_timestamp" : timestamp} mutableCopy];
    } else if (currentCategory == MNET_PULSE_CATEGORY_LOG) {
        // NOTE: 7 is a number that is fetched from the relative positioning of the current method
        // in the callstack. If any wrapper methods are added, then it needs to be changed.
        // Hitherto, there's no cleaner solution
        NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:7];
        NSString *logPath      = [MNBaseUtil getClassNameFromStacktraceEntry:sourceString];

        parsedResponse = [@{@"message" : self.__customMessage, @"tag" : logPath} mutableCopy];

        if (customDataDict && [[customDataDict allKeys] count] > 0) {
            parsedResponse[@"params"] = customDataDict;
        }

    } else if (currentCategory == MNET_PULSE_CATEGORY_ERROR) {
        parsedResponse = [customDataDict mutableCopy];
    } else {
        if (self.__subTag && ![self.__subTag isEqualToString:@""]) {
            parsedResponse[@"event_type"] = self.__subTag;
            parsedResponse[@"params"]     = [customDataDict mutableCopy];
        } else {
            parsedResponse = [customDataDict mutableCopy];
        }
    }

    // Create a dict with common data;
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSString *versionName = [[MNBase getInstance] sdkVersionName];
    NSNumber *versionCode = [NSNumber numberWithUnsignedInteger:[[MNBase getInstance] sdkVersionNumber]];

    NSDictionary *defaultInternalData = @{
        @"visit_id" : [[MNBase getInstance] getVisitId],
        @"publisher_id" : [MNBase getInstance].customerId,
        @"package" : [MNBaseUtil getMainPackageName],
        @"app_version_name" : [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
        @"app_version_code" : [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"],
        @"sdk_version_name" : versionName,
        @"sdk_version_code" : [versionCode stringValue],
        @"ifa" : adId,
    };
    [parsedResponse addEntriesFromDictionary:defaultInternalData];

    if (self.__customMessage && ![self.__customMessage isEqualToString:@""]) {
        [parsedResponse setObject:self.__customMessage forKey:@"message"];
    }

    return parsedResponse;
}

- (NSDictionary *)filterKeysOfDict:customDataDict forType:(NSString *)type {
    NSDictionary *eventDict = [[self class] getBidReqToPulseMap];

    NSDictionary *whiteListDict = [eventDict objectForKey:type];
    // If the type is not found in the white-list dict, then return original dict
    if (!whiteListDict) {
        return customDataDict;
    }

    NSArray *whiteListedKeys      = [whiteListDict allKeys];
    NSMutableDictionary *respDict = [[NSMutableDictionary alloc] init];
    for (NSString *reqdKey in whiteListedKeys) {
        NSString *whiteListKey = whiteListDict[reqdKey];
        id reqdVal             = [customDataDict objectForKey:reqdKey];
        if (reqdVal) {
            respDict[whiteListKey] = reqdVal;
        }
    }
    return [respDict copy];
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"eventObj" : @"lg",
        @"timestamp" : @"ts",
        @"tag" : @"tp",
        @"loggingLevel" : @"lvl",
        @"loggingService" : @"svs",
        @"platform" : @"plt"
    };
}

+ (NSDictionary *)getBidReqToPulseMap {
    NSDictionary *bidReqToPulseMap = @{
        MNBasePulseEventDevice : @{
            @"model" : @"brand",
            @"make" : @"manufacturer",
            @"osv" : @"os_version",
            @"h" : @"display_height",
            @"w" : @"display_width",
            @"ppi" : @"display_density",
            @"device_ram" : @"device_ram",
            @"internal_free_space" : @"internal_free_space",
            @"pxratio" : @"pixel_ratio",
            @"model" : @"device_model",
            @"is_emulator" : @"is_emulator",
            @"mac" : @"mac",
            @"imei" : @"imei",
            @"is_rooted" : @"is_rooted"
        },
        MNBasePulseEventNetwork : @{
            @"ip" : @"ipv4",
            @"ipv6" : @"ipv6",
            @"carrier" : @"network_operator",
        },
        MNBasePulseEventLocation : @{
            @"zip" : @"zip",
            @"lat" : @"lat",
            @"lon" : @"long",
            @"city" : @"city",
            @"region" : @"region",
            @"country" : @"country",
            @"utcoffset" : @"utcoffset",
            @"type" : @"location_provider",
            @"accuracy" : @"location_accuracy",
        },
        MNBasePulseEventDeviceLang : @{@"language" : @"device_language"},
        MNBasePulseEventTimezone : @{@"utcoffset" : @"timezone"},
        MNBasePulseEventAddress :
            @{@"country" : @"country_code", @"region" : @"region", @"city" : @"city", @"zip" : @"zip_code"},
        MNBasePulseEventUserAgent : @{@"ua" : @"user_agent"}
    };
    return bidReqToPulseMap;
}

#pragma mark - NSCoding methods
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.timestamp                 = [decoder decodeObjectForKey:@"timestamp"];
    self.eventObj                  = [decoder decodeObjectForKey:@"eventObj"];
    self.loggingLevel              = [decoder decodeObjectForKey:@"loggingLevel"];
    self.loggingService            = [decoder decodeObjectForKey:@"loggingService"];
    self.tag                       = [decoder decodeObjectForKey:@"tag"];
    self.platform                  = [decoder decodeObjectForKey:@"platform"];
    self.__subTag                  = [decoder decodeObjectForKey:@"subTag"];
    self.__customMessage           = [decoder decodeObjectForKey:@"customMessage"];
    self.__isCustomDataADictionary = [decoder decodeBoolForKey:@"isCustomDataADictionary"];
    self.__isForcedEvent           = [decoder decodeBoolForKey:@"isForcedEvent"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (self.timestamp != nil) {
        [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    }
    if (self.eventObj != nil) {
        [encoder encodeObject:self.eventObj forKey:@"eventObj"];
    }
    if (self.loggingLevel != nil) {
        [encoder encodeObject:self.loggingLevel forKey:@"loggingLevel"];
    }
    if (self.loggingService != nil) {
        [encoder encodeObject:self.loggingService forKey:@"loggingService"];
    }
    if (self.tag != nil) {
        [encoder encodeObject:self.tag forKey:@"tag"];
    }
    if (self.platform != nil) {
        [encoder encodeObject:self.platform forKey:@"platform"];
    }
    if (self.__subTag != nil) {
        [encoder encodeObject:self.__subTag forKey:@"subTag"];
    }
    if (self.__customMessage != nil) {
        [encoder encodeObject:self.__customMessage forKey:@"customMessage"];
    }
    [encoder encodeBool:self.__isCustomDataADictionary forKey:@"isCustomDataADictionary"];
    [encoder encodeBool:self.__isForcedEvent forKey:@"isForcedEvent"];
}

@end
