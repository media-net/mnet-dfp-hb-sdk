//
//  MNBaseLoaders.h
//  Pods
//
//  Created by kunal.ch on 29/08/17.
//
//

#import "MNBaseDefaultLoaders.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseLoaders : NSObject <MNJMMapperProtocol>
@property (atomic) MNBaseDefaultLoaders *defaultLoaders;
@property (atomic) NSDictionary<NSString *, MNBaseDefaultLoaders *> *adUnitsLoaders;
@end
