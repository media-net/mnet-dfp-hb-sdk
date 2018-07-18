//
//  MNBaseResponseParserExtras.h
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import <Foundation/Foundation.h>

/// Instance of this object can be passed as additional args when parsing response
@interface MNBaseResponseParserExtras : NSObject

@property (atomic) NSString *visitId;
@property (atomic) NSString *adCycleId;
@property (atomic) NSString *contextUrl;
@property (atomic) NSString *viewControllerTitle;
@property (atomic) UIViewController *viewController;
@property (atomic) NSString *keywords;

+ (instancetype)getInstanceWithAdCycleId:(NSString *)adCycleId
                                 visitId:(NSString *)visitId
                              contextUrl:(NSString *)contextUrl
                     viewControllerTitle:(NSString *)viewControllerTitle
                          viewController:(UIViewController *)viewController
                                keywords:(NSString *)keywords;
@end
