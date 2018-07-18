//
//  MNBaseAdClickEvent.h
//  Pods
//
//  Created by nithin.g on 04/07/17.
//
//

#import "MNBaseBidResponse.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdClickEvent : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *adUnitId;
@property (atomic) NSString *adCycleId;
@property (atomic) NSString *appLink;
@property (atomic) NSNumber *bidderId;
@property (atomic) NSNumber *bid;

+ (instancetype)getInstanceFromBidResponse:(MNBaseBidResponse *)response;
- (NSDictionary *)propertyKeyMap;
@end
