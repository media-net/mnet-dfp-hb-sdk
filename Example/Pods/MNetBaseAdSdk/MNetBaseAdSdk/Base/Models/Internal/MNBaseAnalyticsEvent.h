//
//  MNBaseAnalyticsEvent.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseDeviceInfo.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAnalyticsEvent : NSObject <MNJMMapperProtocol>
@property (atomic) MNBaseDeviceInfo *deviceInfo;
@property (atomic) NSDictionary *timingsData;
@property (atomic) NSString *adUnitId;
@property (atomic) NSString *adCycleId;
@property (atomic) NSString *appLink;
@property (atomic) NSUInteger bidderId;
@property (atomic) double bid;

+ (MNBaseAnalyticsEvent *)newInstance;
- (NSDictionary *)propertyKeyMap;

@end
