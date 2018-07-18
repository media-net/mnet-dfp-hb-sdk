//
//  MNBaseIntentData.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseExternalData.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseIntentData : NSObject <MNJMMapperProtocol>

@property (atomic) NSString *uri;
@property (atomic) MNBaseExternalData *externalData;
@property (atomic) NSString *keywords;

- (id)initWithURI:(NSString *)uri;
- (id)initWithExtUrl:(NSString *)extUrl;
- (id)initWithURI:(NSString *)uri AndExtUrl:(NSString *)extUrl;

@end
