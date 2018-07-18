//
//  MNBaseAdIdManager.h
//  MNBaseAdSdk
//
//  Created by nithin.g on 19/12/17.
//

#import <Foundation/Foundation.h>

@interface MNBaseAdIdManager : NSObject

+ (instancetype)getSharedInstance;
- (NSString *)getAdvertId;

@end
