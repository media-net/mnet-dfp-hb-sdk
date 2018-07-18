//
//  MNBaseFingerprint.h
//  Pods
//
//  Created by nithin.g on 22/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseFingerprint : NSObject
+ (id)getInstance;
- (NSString *)getUUID;

@end
