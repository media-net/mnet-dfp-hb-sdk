//
//  MNBasePulseStore.m
//  Pods
//
//  Created by nithin.g on 03/04/17.
//
//

#import "MNBaseConstants.h"
#import "MNBaseLogger.h"
#import "MNBasePulseStore+Internal.h"
#import "MNBaseUtil.h"
#import <MNetJSONModeller/MNJMManager.h>

@implementation MNBasePulseStore
static MNBasePulseStore *instance = nil;
static NSString *storeFileName    = PULSE_FILE_STORE_NAME;

+ (instancetype)getSharedInstanceWithDelegate:(id)delegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBasePulseStore alloc] init];
      [instance initializeStoreData];
    });
    instance.delegate = delegate;
    return instance;
}

- (void)initializeStoreData {
    NSString *filePath = [[MNBaseUtil getSupportDirectoryPath] stringByAppendingPathComponent:storeFileName];
    @try {
        self.cachedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch (NSException *e) {
        MNLogD(@"PULSE: Exception when unarchiving the file-path - %@", e);
    }
    if (self.cachedData == nil) {
        self.cachedData = [[MNBasePulseStoreData alloc] init];
        MNLogD(@"PULSE: initializeStoreData there is no cached data!");
    } else {
        MNLogD(@"PULSE: initializeStoreData Fetched cached data successfully - %lu",
               (unsigned long) [self.cachedData getNumEntries]);
    }
}

- (void)flushCachedData {
    @synchronized(self) {
        MNLogD(@"PULSE: Flushing cached data!");
        self.cachedData = [[MNBasePulseStoreData alloc] init];
        [self clearFile];
    }
}

- (BOOL)addEntries:(NSArray<NSData *> *)entryList {
    @synchronized(self) {
        BOOL entryStatus;
        if (entryList == nil || [entryList count] == 0) {
            return NO;
        }

        entryStatus = [self.cachedData addEntries:entryList];
        if (entryStatus) {
            [self saveFile];
            [self runComparator];
        }
        return entryStatus;
    }
}

- (NSUInteger)getNumEntries {
    @synchronized(self) {
        return [self.cachedData getNumEntries];
    }
}

- (void)runComparator {
    @synchronized(self) {
        NSUInteger fileSize                = [self getFileSize];
        NSUInteger numEntries              = [self.cachedData getNumEntries];
        NSTimeInterval timeSinceFirstEntry = [self.cachedData getTimeSinceFirstEntry];
        MNLogD(@"PULSE: Comparator FileSize: %lu, numEntries: %lu, timeSinceFirstEntry: %f", (unsigned long) fileSize,
               (unsigned long) numEntries, timeSinceFirstEntry);

        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(comparatorWithFileSize:numEntries:andTimeSinceFirstEntry:)]) {
            MNBasePulseStoreLimitType limitType = [self.delegate comparatorWithFileSize:fileSize
                                                                             numEntries:numEntries
                                                                 andTimeSinceFirstEntry:timeSinceFirstEntry];
            if (limitType != kMNBasePulseNone) {
                MNLogD(@"PULSE: Calling limit-exceeded callback");
                if ([self.delegate respondsToSelector:@selector(limitExceeded:withEntries:)]) {
                    [self.delegate limitExceeded:limitType withEntries:[self.cachedData getAllEntries]];
                } else {
                    MNLogD(@"Failed to call limitExceeded: since it's not implemented");
                }
                [self flushCachedData];
                return;
            }
        } else {
            MNLogD(@"Running comparator failed because either delegate is nil, or "
                   @"comparatorWithFileSize:numEntries:andTimeSinceFirstEntry: is not implemented");
        }
    }
}

#pragma mark - Helper methods
- (void)saveFile {
    @synchronized(self) {
        @try {
            MNLogD(@"PULSE: Saving file");
            NSString *filePath  = [[MNBaseUtil getSupportDirectoryPath] stringByAppendingPathComponent:storeFileName];
            BOOL archiveSuccess = [NSKeyedArchiver archiveRootObject:self.cachedData toFile:filePath];
            MNLogD(@"PULSE: archiveSuccess - %@", (archiveSuccess) ? @"YES" : @"NO");
        } @catch (NSException *e) {
            MNLogE(@"PULSE: Exception when saving file - %@", e);
        }
    }
}

- (void)clearFile {
    @synchronized(self) {
        @try {
            MNLogD(@"PULSE: Clearing file");
            NSString *dirPath = [MNBaseUtil getSupportDirectoryPath];
            [MNBaseUtil writeToFileName:storeFileName withFolder:dirPath withContents:@""];
        } @catch (NSException *e) {
            MNLogE(@"PULSE: Exception when clearing file - %@", e);
        }
    }
}

- (NSUInteger)getFileSize {
    @synchronized(self) {
        @try {
            NSUInteger fileSize = 0;
            NSString *appFile   = [[MNBaseUtil getSupportDirectoryPath] stringByAppendingPathComponent:storeFileName];

            NSError *attributesError;
            NSDictionary *fileAttributes =
                [[NSFileManager defaultManager] attributesOfItemAtPath:appFile error:&attributesError];
            if (!attributesError) {
                NSNumber *fileSizeObj = [fileAttributes objectForKey:NSFileSize];
                if (fileSizeObj != nil) {
                    fileSize = [fileSizeObj unsignedIntegerValue];
                }
            }
            return fileSize;
        } @catch (NSException *e) {
            MNLogE(@"Exception when fetching file size - %@", e);
        }
        return 0;
    }
}

#pragma mark - Public static helper
+ (NSString *)getStringForPulseStoreLimitType:(MNBasePulseStoreLimitType)limitType {
    NSString *limitStr;
    switch (limitType) {
    case kMNBasePulseFileSizeLimit: {
        limitStr = @"kMNBasePulseFileSizeLimit";
        break;
    }
    case kMNBasePulseNumEntriesLimit: {
        limitStr = @"kMNBasePulseNumEntriesLimit";
        break;
    }
    case kMNBasePulseTimeLimit: {
        limitStr = @"kMNBasePulseTimeLimit";
        break;
    }
    case kMNBasePulseNone: {
        limitStr = @"kMNBasePulseNone";
        break;
    }
    default: {
        limitStr = @"";
        break;
    }
    }
    return limitStr;
}

@end
