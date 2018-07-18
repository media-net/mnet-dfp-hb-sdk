//
//  MNBaseConfig.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseHbConfigData.h"
#import "MNBasePublisherTimeoutSettings.h"
#import "MNBaseSdkConfigData.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseConfig : NSObject <MNJMMapperProtocol>
@property (atomic) MNBaseHbConfigData *hbConfig;
@property (atomic) MNBaseSdkConfigData *sdkConfig;
@property (atomic) MNBasePublisherTimeoutSettings *publisherTimeoutSettings;
@property (atomic) NSString *pid;
@property (atomic) NSString *version;
@end
