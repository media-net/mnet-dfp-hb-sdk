//
//  MNBaseMacroManager.h
//  Pods
//
//  Created by nithin.g on 09/10/17.
//
//

#import "MNBaseBidResponse.h"
#import <Foundation/Foundation.h>

@interface MNBaseMacroManager : NSObject

NS_ASSUME_NONNULL_BEGIN

+ (instancetype)getSharedInstance;

- (NSArray<NSString *> *)processMacrosForLoggingPixels:(NSArray<NSString *> *)loggingUrls
                                          withResponse:(MNBaseBidResponse *)bidResponse;

- (NSArray<NSString *> *)processMacrosForApLogsForBidders:(NSArray<NSString *> *)loggingUrls
                                             withResponse:(MNBaseBidResponse *_Nullable)bidResponse;

- (NSArray<NSString *> *)processMacrosForExpiryLogs:(NSArray<NSString *> *)loggingUrls
                                       withResponse:(MNBaseBidResponse *)bidResponse;

- (NSString *)processMacrosForAdCode:(NSString *)adCode withResponse:(MNBaseBidResponse *)bidResponse;

- (NSDictionary *)processServerExtras:(NSDictionary *)serverExtrasMap withResponse:(MNBaseBidResponse *)bidResponse;

NS_ASSUME_NONNULL_END
@end
