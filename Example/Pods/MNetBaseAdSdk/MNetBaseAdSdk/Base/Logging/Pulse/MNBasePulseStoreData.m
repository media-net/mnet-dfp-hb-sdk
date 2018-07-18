//
//  MNBasePulseStoreData.m
//  Pods
//
//  Created by nithin.g on 25/07/17.
//
//

#import "MNBasePulseStoreData.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

@interface MNBasePulseStoreData ()
@property (atomic) NSMutableArray<NSData *> *entryList;
@property (atomic) NSNumber *timestampOfFirstEntry;
@end

@implementation MNBasePulseStoreData
- (instancetype)init {
    self       = [super init];
    _entryList = [[NSMutableArray alloc] init];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return self;
    }
    self.entryList             = [decoder decodeObjectForKey:@"entryList"];
    self.timestampOfFirstEntry = [decoder decodeObjectForKey:@"timestampOfFirstEntry"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    if (self.entryList != nil) {
        [encoder encodeObject:self.entryList forKey:@"entryList"];
    }
    if (self.timestampOfFirstEntry != nil) {
        [encoder encodeObject:self.timestampOfFirstEntry forKey:@"timestampOfFirstEntry"];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MNBasePulseStoreData *storeDataCopy = [[MNBasePulseStoreData alloc] init];
    storeDataCopy.timestampOfFirstEntry = self.timestampOfFirstEntry;
    [storeDataCopy addEntries:self.entryList];
    return storeDataCopy;
}

- (BOOL)addEntry:(NSData *)entry {
    if (entry == nil) {
        return NO;
    }
    // Have to do this for backward-compatibility
    if (NO == [entry isKindOfClass:[NSData class]]) {
        MNLogD(@"Skipping adding an entry since it's not of NSData type");
        return NO;
    }
    if ([self.entryList count] == 0) {
        self.timestampOfFirstEntry = [MNBaseUtil getTimestamp];
    }
    MNLogD(@"PULSE: Adding entry in pulse store");
    [self.entryList addObject:entry];
    return YES;
}

- (BOOL)addEntries:(NSArray<NSData *> *)entries {
    if (entries == nil || [entries count] == 0) {
        return NO;
    }
    BOOL finalResp = NO;
    for (NSData *entry in entries) {
        if (entry != nil) {
            BOOL insertionStatus = [self addEntry:entry];
            finalResp            = finalResp || insertionStatus;
        }
    }
    return finalResp;
}

- (NSUInteger)getNumEntries {
    return [self.entryList count];
}

- (NSTimeInterval)getTimeSinceFirstEntry {
    if ([self.entryList count] == 0 || self.timestampOfFirstEntry == nil) {
        return 0;
    }
    NSTimeInterval timestampOfFirstEntry = [self.timestampOfFirstEntry longValue];
    NSTimeInterval currentTimestamp      = [[MNBaseUtil getTimestamp] longValue];

    return currentTimestamp - timestampOfFirstEntry;
}

- (NSArray<NSData *> *)getAllEntries {
    return [NSArray arrayWithArray:self.entryList];
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"entryList" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSData class]],
    };
}

@end
