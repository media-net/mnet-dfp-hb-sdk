//
//  MNBaseHostAppInfo.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAppExternalData.h"
#import "MNBaseIntentData.h"
#import "MNBasePublisher.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseHostAppInfo : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *packageName;

@property (atomic) NSString *appVersion;

@property (atomic) MNBasePublisher *publisher;

@property (atomic) MNBaseIntentData *intentData;

@property (atomic) MNBaseAppExternalData *appExt;

+ (MNBaseHostAppInfo *)newInstance;
+ (MNBaseHostAppInfo *)getAppHostInfoWithExtUrl:(NSString *)extUrl;

@end
