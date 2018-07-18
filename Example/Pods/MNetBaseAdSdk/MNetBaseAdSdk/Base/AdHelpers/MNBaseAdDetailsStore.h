//
//  MNBaseAdDetailsStore.h
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import "MNBaseAdDetails.h"
#import <Foundation/Foundation.h>

@interface MNBaseAdDetailsStore : NSObject

+ (void)initializeStore;
+ (instancetype)getSharedInstance;

#pragma mark - All getter methods
- (MNBaseAdDetails *)getDetailsForAdunit:(NSString *)adunitId andPubId:(NSString *)pubId;

#pragma mark - All update methods
- (BOOL)updateBid:(NSNumber *)bidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId;
- (BOOL)updateAdxBid:(NSNumber *)adxBidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId;
- (BOOL)updateAdxWinBid:(NSNumber *)adxWinbidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId;
- (BOOL)updateAdxWinStatus:(BOOL)adxWinStatus forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId;
@end
