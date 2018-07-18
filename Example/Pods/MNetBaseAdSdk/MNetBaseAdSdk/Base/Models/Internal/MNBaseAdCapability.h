//
//  MNBaseAdCapability.h
//  Pods
//
//  Created by nithin.g on 19/05/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdCapability : NSObject <MNJMMapperProtocol>
@property (atomic) MNJMBoolean *video;
@property (atomic) MNJMBoolean *banner;
@property (atomic) MNJMBoolean *rewardedVideo;
@property (atomic) MNJMBoolean *native;
@property (atomic) MNJMBoolean *audio;
@property (atomic) MNJMBoolean *responsiveBanner;
@property (atomic) MNJMBoolean *mraid;
- (void)getDefaultCapability;
- (NSDictionary *)propertyKeyMap;

@end
