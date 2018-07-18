//
//  MNBasePulseStoreData.h
//  Pods
//
//  Created by nithin.g on 25/07/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBasePulseStoreData : NSObject <MNJMMapperProtocol, NSCopying, NSCoding>
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)addEntries:(NSArray<NSData *> *)entries;

- (NSArray<NSData *> *)getAllEntries;
- (NSUInteger)getNumEntries;
- (NSTimeInterval)getTimeSinceFirstEntry;

@end
