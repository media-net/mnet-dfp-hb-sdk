//
//  MNBaseDefaultBiddersManager.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 27/12/17.
//

#import "MNBaseAuctionManager.h"
#import "MNBaseDefaultBidsManager+Internal.h"
#import "MNBaseNotificationManager.h"
#import "MNBaseSdkConfig.h"

@implementation MNBaseDefaultBidsManager

+ (void)load {
    MNBaseDefaultBidsManager *defaultBids = [MNBaseDefaultBidsManager getSharedInstance];
    [defaultBids listenToSdkConfig];
}

static MNBaseDefaultBidsManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [MNBaseDefaultBidsManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataStore = [MNBaseDefaultBidsDataStore getSharedInstance];
    }
    return self;
}

- (void)listenToSdkConfig {
    self.sdkConfigNotificationObj = [MNBaseNotificationManager
        addObserverToNotification:MNBaseNotificationSdkConfigUpdated
                        withBlock:^(NSNotification *_Nonnull notificationObj) {
                          MNBaseHbConfigData *hbConfigData = [[MNBaseSdkConfig getInstance] getHbConfigData];
                          NSArray *defaultBids             = [hbConfigData defaultBids];
                          [self addDefaultBids:defaultBids];
                        }];
}

- (MNBaseBidResponsesContainer *_Nullable)getDefaultBidsForBidRequest:(MNBaseBidRequest *_Nonnull)bidRequest {
    if (bidRequest == nil) {
        return nil;
    }
    NSString *adUnitId                         = [bidRequest fetchAdUnitId];
    NSString *contextUrl                       = [bidRequest fetchContextUrl];
    NSArray<MNBaseBidResponse *> *bidResponses = [self getBidResponsesForAdUnitId:adUnitId andContextUrl:contextUrl];

    if (bidResponses == nil || [bidResponses count] == 0) {
        return nil;
    }
    MNBaseBidResponsesContainer *responsesContainer =
        [[MNBaseAuctionManager getInstance] performAuctionForResponses:bidResponses madeForBidRequest:bidRequest];
    [responsesContainer setAreDefaultBids:YES];
    return responsesContainer;
}

- (NSArray<MNBaseBidResponse *> *_Nullable)getBidResponsesForAdUnitId:(NSString *_Nonnull)adUnitId
                                                        andContextUrl:(NSString *_Nonnull)contextUrl {
    if (adUnitId == nil || [adUnitId isEqualToString:@""] || contextUrl == nil) {
        return nil;
    }
    contextUrl = [contextUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [self.dataStore getBidResponsesForAdUnitId:adUnitId andContextUrl:contextUrl];
}

- (BOOL)addDefaultBids:(NSArray<MNBaseDefaultBid *> *)defaultBids {
    return [self.dataStore addDefaultBids:defaultBids];
}

- (void)dealloc {
    if (self.sdkConfigNotificationObj != nil) {
        [MNBaseNotificationManager removeObserver:self.sdkConfigNotificationObj
                                         withName:MNBaseNotificationSdkConfigUpdated];
    }
}

@end
