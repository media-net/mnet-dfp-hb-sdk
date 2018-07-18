//
//  MNBaseResponseParserExtras.m
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseResponseParserExtras.h"

@implementation MNBaseResponseParserExtras

+ (instancetype)getInstanceWithAdCycleId:(NSString *)adCycleId
                                 visitId:(NSString *)visitId
                              contextUrl:(NSString *)contextUrl
                     viewControllerTitle:(NSString *)viewControllerTitle
                          viewController:(UIViewController *)viewController
                                keywords:(NSString *)keywords {
    MNBaseResponseParserExtras *instance = [[MNBaseResponseParserExtras alloc] init];
    instance.adCycleId                   = adCycleId;
    instance.visitId                     = visitId;
    instance.contextUrl                  = contextUrl;
    instance.viewController              = viewController;
    instance.viewControllerTitle         = viewControllerTitle;
    instance.keywords                    = keywords;
    return instance;
}

@end
