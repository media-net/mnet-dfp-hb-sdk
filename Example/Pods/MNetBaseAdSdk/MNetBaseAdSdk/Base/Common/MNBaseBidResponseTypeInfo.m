//
//  MNBaseBidResponseTypeInfo.m
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import "MNBaseBidResponseTypeInfo.h"
#import "MNBaseConstants.h"

#define CLASS_KEY @"class_name"
#define SEL_KEY @"sel_name"

@implementation MNBaseBidResponseTypeInfo
static MNBaseBidResponseTypeInfo *instance;
static NSDictionary *adTypeMappings;

+ (id)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance       = [[[self class] alloc] init];
      adTypeMappings = @{
          BANNER_STRING : @{CLASS_KEY : BANNER_AD_CONTROLLER, SEL_KEY : SEL_BANNER_AD_CONTROLLER},
          RESPONSIVE_BANNER_STRING :
              @{CLASS_KEY : RESPONSIVE_BANNER_AD_CONTROLLER, SEL_KEY : SEL_RESPONSIVE_BANNER_AD_CONTROLLER},
          VIDEO_STRING : @{CLASS_KEY : VIDEO_AD_CONTROLLER, SEL_KEY : SEL_VIDEO_AD_CONTROLLER},
          REWARDED_VIDEO_STRING : @{CLASS_KEY : REWARDED_AD_CONTROLLER, SEL_KEY : SEL_REWARDED_AD_CONTROLLER},
          MRAID_STRING : @{CLASS_KEY : MNET_MRAID_AD_CONTROLLER, SEL_KEY : SEL_MRAID_AD_CONTROLLER},
      };
    });

    return instance;
}

- (BOOL)isResponseType:(NSString *)responseType {
    return ([adTypeMappings objectForKey:responseType] != nil);
}

- (NSString *)getAdControllerClassStrForResponseType:(NSString *)responseType {
    NSString *classStr      = nil;
    NSDictionary *adTypeMap = [adTypeMappings objectForKey:responseType];
    if (adTypeMappings) {
        classStr = [adTypeMap objectForKey:CLASS_KEY];
    }

    return classStr;
}

- (NSString *)getAdControllerSelStrForResponseType:(NSString *)responseType {
    NSString *selStr        = nil;
    NSDictionary *adTypeMap = [adTypeMappings objectForKey:responseType];
    if (adTypeMappings) {
        selStr = [adTypeMap objectForKey:SEL_KEY];
    }

    return selStr;
}

@end
