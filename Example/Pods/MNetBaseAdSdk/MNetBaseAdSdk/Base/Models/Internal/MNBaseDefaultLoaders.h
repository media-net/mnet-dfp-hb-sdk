//
//  MNBaseDefaultLoaders.h
//  Pods
//
//  Created by kunal.ch on 29/08/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseDefaultLoaders : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *banner;
@property (atomic) NSString *medium;
@property (atomic) NSString *interstitial;
@end
