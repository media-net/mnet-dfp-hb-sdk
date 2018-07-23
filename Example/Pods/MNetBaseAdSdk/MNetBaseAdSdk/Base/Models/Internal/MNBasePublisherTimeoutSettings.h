//
//  MNBasePublisherTimeoutSettings.h
//  MNBaseAdSdk
//
//  Created by kunal.ch on 04/01/18.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBasePublisherTimeoutSettings : NSObject <MNJMMapperProtocol>
@property (atomic) NSNumber *prfd;
@property (atomic) NSNumber *gptrd;
@property (atomic) NSNumber *hbDelayExtra;
@end
