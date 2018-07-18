//
//  MNBasePulseStore.h
//  Pods
//
//  Created by nithin.g on 03/04/17.
//
//

#import <Foundation/Foundation.h>

typedef enum MNBasePulseStoreLimitType : NSUInteger {
    kMNBasePulseFileSizeLimit,
    kMNBasePulseNumEntriesLimit,
    kMNBasePulseTimeLimit,
    kMNBasePulseNone
} MNBasePulseStoreLimitType;

@protocol MNBasePulseStoreDelegate <NSObject>
@required
- (MNBasePulseStoreLimitType)comparatorWithFileSize:(NSUInteger)fileSize
                                         numEntries:(NSUInteger)numEntries
                             andTimeSinceFirstEntry:(NSTimeInterval)timestamp;

- (void)limitExceeded:(MNBasePulseStoreLimitType)limitExceededType withEntries:(NSArray<NSData *> *)entries;
@end

@interface MNBasePulseStore : NSObject
+ (instancetype)getSharedInstanceWithDelegate:(id)delegate;
- (BOOL)addEntries:(NSArray<NSData *> *)entryList;
- (void)runComparator;
- (void)flushCachedData;
@end
