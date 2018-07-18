//
//  MNALBlackList.m
//  Pods
//
//  Created by nithin.g on 12/06/17.
//
//

#import "MNALBlackList.h"
#import "MNALConstants.h"
#import "MNALUtils.h"

#define ELEMENT_KEY @"elements"
#define INTENT_KEY @"keys"

@interface MNALBlackList ()
@property (nonatomic) NSDictionary<NSString *, NSDictionary *> *blacklist;
@end

@implementation MNALBlackList

static MNALBlackList *instance;
static dispatch_once_t onceToken;

+ (instancetype)getInstance {
    dispatch_once(&onceToken, ^{
      instance = [[[self class] alloc] init];

      // TODO: This needs to be extended to fetch the response from
      // the server as well
      instance.blacklist = @{
          MNAL_WIKIPEDIA_BUNDLE : @{
              INTENT_KEY : @[
                  @"containerURL", @"articleLocationController", @"recentSearchList", @"dataStore", @"savedPageList"
              ]
          },
          MNAL_HACKERNEWS_BUNDLE : @{},
          MNAL_NYTIMES_BUNDLE : @{
              INTENT_KEY : @[
                  @"search_controller",
              ]
          },
      };
    });
    return instance;
}

- (NSString *)getCurrentAppBundleId {
    NSString *bundleId = [MNALUtils getBundleId];
    return bundleId;
}

- (NSDictionary *)getBlackListForCurrentApp {
    NSString *bundleId = [self getCurrentAppBundleId];
    return [self getBlackListForApp:bundleId];
}

- (NSArray *)getIntentsBlackListForCurrentApp {
    NSString *bundleId = [self getCurrentAppBundleId];
    return [self getIntentsBlackListForApp:bundleId];
}

- (NSDictionary *)getBlackListForApp:(NSString *)appStr {
    return [self.blacklist objectForKey:appStr];
}

- (NSArray *)getIntentsBlackListForApp:(NSString *)appStr {
    NSDictionary *blackListDict = [self getBlackListForApp:appStr];

    NSArray *intentKeys;
    if (blackListDict) {
        intentKeys = [blackListDict valueForKey:INTENT_KEY];
    }
    return intentKeys;
}

@end
