//
//  MNBaseCustomTargets.h
//  MNBaseAdSdk
//
//  Created by kunal.ch on 08/01/18.
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseCustomTargets : NSObject <MNJMMapperProtocol>
@property (atomic) NSString *key;
@property (atomic) NSString *value;
@property (atomic) NSString *prefix;

- (BOOL)containsInAppPrefix;
@end
