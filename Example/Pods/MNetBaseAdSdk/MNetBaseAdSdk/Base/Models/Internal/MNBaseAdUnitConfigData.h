//
//  MNBaseAdUnitConfigData.h
//  Pods
//
//  Created by nithin.g on 13/07/17.
//
//

#import "MNBaseCustomTargets.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdUnitConfigData : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *adUnitId;
@property (atomic) MNJMBoolean *autorefreshEnabled;
@property (atomic) NSNumber *autorefreshInterval;
@property (atomic) NSString *creativeId;
@property (atomic) NSArray<NSNumber *> *bidderIds;
@property (atomic) NSArray<MNBaseCustomTargets *> *customTargets;
@property (atomic) NSArray<NSString *> *sizes;
@property (atomic) NSArray<NSNumber *> *supportedAds;

- (BOOL)containsWildcardAdUnitId;
@end
