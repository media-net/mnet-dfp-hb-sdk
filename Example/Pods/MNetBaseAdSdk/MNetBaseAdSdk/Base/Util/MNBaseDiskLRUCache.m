//
//  MNBaseDiskLRUCache.m
//  Pods
//
//  Created by kunal.ch on 24/03/17.
//
//

#import "MNBaseDiskLRUCache.h"
#import "MNBaseLogger.h"
#import "MNBaseSdkConfig.h"
#import <CommonCrypto/CommonDigest.h>

// TODO Get this from SDK config.
//#define mCacheMaxSize (25 * 1024 * 1024) // 25 MB

// TODO Get this from SDK config
//#define mCacheFileAge (7 * 24 * 60 * 60) // 1 week

@interface MNBaseLRUCacheFile : NSObject

@property (atomic) NSString *filePath;
@property (atomic) NSTimeInterval lastModififedTimestamp;
@property (atomic) uint64_t fileSize;

@end

@implementation MNBaseLRUCacheFile

@end

//****************************************************//

@interface MNBaseDiskLRUCache ()

@property (atomic, strong) dispatch_queue_t diskLRUQueue;

@property (atomic) NSString *cachePath;

@property (atomic) uint64_t maxByteForSizeCheck;

@end

@implementation MNBaseDiskLRUCache

+ (MNBaseDiskLRUCache *)sharedLRUCache {
    static dispatch_once_t onceTaken;
    static MNBaseDiskLRUCache *sharedLRUCache;
    dispatch_once(&onceTaken, ^{
      sharedLRUCache = [[self alloc] init];
    });
    return sharedLRUCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        MNLogD(@"init LRU cache");
        _diskLRUQueue = dispatch_queue_create("net.media.diskLRUQueue", DISPATCH_QUEUE_SERIAL);

        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (filePaths.count > 0) {
            _cachePath = [[[filePaths objectAtIndex:0] stringByAppendingPathComponent:@"net.media.lruCache"] copy];

            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:_cachePath]) {
                [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        [self checkForCacheSize];
    }

    return self;
}

- (NSData *)getDataForKey:(NSString *)key {

    __block NSData *data = nil;

    dispatch_sync(self.diskLRUQueue, ^{
      NSString *cachedFilepath = [self getCachedFilePathForKey:key];

      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL isDirectory           = NO;
      if ([fileManager fileExistsAtPath:cachedFilepath isDirectory:&isDirectory]) {
          data = [NSData dataWithContentsOfFile:cachedFilepath];

          [fileManager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
                        ofItemAtPath:cachedFilepath
                               error:nil];
      }
    });

    return data;
}

- (void)saveData:(NSData *)data forKey:(NSString *)key {

    dispatch_sync(self.diskLRUQueue, ^{
      NSString *cacheFilepath    = [self getCachedFilePathForKey:key];
      NSFileManager *fileManager = [NSFileManager defaultManager];

      if (![fileManager fileExistsAtPath:cacheFilepath]) {
          [fileManager createFileAtPath:cacheFilepath contents:data attributes:nil];

      } else {

          [data writeToFile:cacheFilepath atomically:YES];
      }
    });

    self.maxByteForSizeCheck += data.length;

    if (self.maxByteForSizeCheck >= ([[MNBaseSdkConfig getInstance] getCacheFileMaxSize] / 10)) {
        [self checkForCacheSize];
        self.maxByteForSizeCheck = 0;
    }
}

- (BOOL)hasCacheForKey:(NSString *)key {
    BOOL result = NO;
    //    __block BOOL result = NO;
    //
    //    dispatch_async(self.diskLRUQueue, ^{
    //        NSFileManager *fileManager = [NSFileManager defaultManager];
    //        result = [fileManager fileExistsAtPath:[self getCaheFilePathForKey:key]];
    //    });

    NSFileManager *fileManager = [NSFileManager defaultManager];
    result                     = [fileManager fileExistsAtPath:[self getCachedFilePathForKey:key]];
    return result;
}

/**
 ** Caculate cache size. Ensure the cache size does not exceeds the Cache limit.
 **/

- (void)checkForCacheSize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      @try {
          MNLogD(@"checking for cache size");
          NSFileManager *fileManager = [NSFileManager defaultManager];

          NSMutableArray *cachedFiles = [self getAllCachedFiles];

          dispatch_async(self.diskLRUQueue, ^{
            @try {
                @autoreleasepool {
                    NSArray *expiredFiles = [self getExpiredFilesFromCache:cachedFiles];

                    for (MNBaseLRUCacheFile *file in expiredFiles) {
                        [fileManager removeItemAtPath:file.filePath error:nil];
                        [cachedFiles removeObject:file];
                    }

                    while ([self getSizeOfCahedFiles:cachedFiles] >=
                               [[MNBaseSdkConfig getInstance] getCacheFileMaxSize] &&
                           cachedFiles.count > 0) {
                        NSString *previousFilePath = ((MNBaseLRUCacheFile *) [cachedFiles objectAtIndex:0]).filePath;
                        [fileManager removeItemAtPath:previousFilePath error:nil];
                        [cachedFiles removeObjectAtIndex:0];
                    }
                }
            } @catch (NSException *e) {
                MNLogE(@"EXCEPTION: Disk processing - %@", e);
            }
          });
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - checkForCacheSize %@", e);
      }
    });
}

/**
 ** Sorts the files according to date modified
 ** And returns all the cached files
 **/

- (NSMutableArray *)getAllCachedFiles {
    MNLogD(@"fetch all cached files");
    NSFileManager *fileManager = [NSFileManager defaultManager];

    /* Create an array object to return array of file paths */
    NSMutableArray *result = [NSMutableArray array];

    NSArray *cachedFiles = [fileManager contentsOfDirectoryAtPath:self.cachePath error:nil];

    /* compare and sort file according to date modified */
    if (cachedFiles.count == 0) {
        return result;
    }

    NSArray *sortedFiles = [cachedFiles sortedArrayUsingComparator:^NSComparisonResult(id x, id y) {
      NSString *file1 = [self.cachePath stringByAppendingPathComponent:(NSString *) x];
      NSString *file2 = [self.cachePath stringByAppendingPathComponent:(NSString *) y];

      NSDictionary *fileAttr1 = [fileManager attributesOfItemAtPath:file1 error:nil];
      NSDictionary *fileAttr2 = [fileManager attributesOfItemAtPath:file2 error:nil];

      NSDate *lastModifiedDate1 = [fileAttr1 fileModificationDate];
      NSDate *lastModifiedDate2 = [fileAttr2 fileModificationDate];

      return [lastModifiedDate1 compare:lastModifiedDate2];
    }];

    for (NSString *fileName in sortedFiles) {
        if ([fileName hasPrefix:@"."]) {
            continue;
        }

        MNBaseLRUCacheFile *lruCacheFile = [[MNBaseLRUCacheFile alloc] init];
        lruCacheFile.filePath            = [self.cachePath stringByAppendingPathComponent:fileName];

        NSDictionary *lruFileAttrs          = [fileManager attributesOfItemAtPath:lruCacheFile.filePath error:nil];
        lruCacheFile.fileSize               = [lruFileAttrs fileSize];
        lruCacheFile.lastModififedTimestamp = [[lruFileAttrs fileModificationDate] timeIntervalSinceReferenceDate];

        [result addObject:lruCacheFile];
    }

    return result;
}

- (NSArray *)getExpiredFilesFromCache:(NSArray *)cachedFiles {
    MNLogD(@"get expired files");
    NSMutableArray *result = [NSMutableArray array];
    if (cachedFiles == nil || cachedFiles.count == 0) {
        return result;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];

    for (MNBaseLRUCacheFile *file in cachedFiles) {
        if (now - file.lastModififedTimestamp >= [[MNBaseSdkConfig getInstance] getCacheMaxAge]) {
            [result addObject:file];
        }
    }
    return result;
}

- (NSString *)getCachedFilePathForKey:(NSString *)key {
    NSString *hashedKey  = MNBaseMD5(key);
    NSString *hashedPath = [self.cachePath stringByAppendingPathComponent:hashedKey];
    NSString *filePath   = [hashedPath stringByAppendingString:@"temp.mp4"];

    return filePath;
}

- (uint64_t)getSizeOfCahedFiles:(NSArray *)files {
    uint64_t currentSize = 0;

    for (MNBaseLRUCacheFile *file in files) {
        currentSize += file.fileSize;
    }

    return currentSize;
}

- (void)clearAllCachedFiles {
    dispatch_sync(self.diskLRUQueue, ^{
      NSFileManager *fileManager = [NSFileManager defaultManager];

      NSArray *allFiles = [self getAllCachedFiles];
      for (MNBaseLRUCacheFile *file in allFiles) {
          [fileManager removeItemAtPath:file.filePath error:nil];
      }
    });
}

- (void)clearCacheForKey:(NSString *)key {
    if ([self hasCacheForKey:key]) {
        NSString *cachedFilepath   = [self getCachedFilePathForKey:key];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory           = NO;
        if ([fileManager fileExistsAtPath:cachedFilepath isDirectory:&isDirectory]) {
            [fileManager removeItemAtPath:cachedFilepath error:nil];
        }
    }
}

NSString *MNBaseMD5(NSString *key) {

    if ([key length] <= 0) {
        return nil;
    }

    const char *cStringToHash = [key UTF8String];
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStringToHash, (CC_LONG)(strlen(cStringToHash)), hash);

    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [hashString appendFormat:@"%02X", hash[i]];
    }
    NSString *result = [NSString stringWithString:hashString];
    return result;
}

- (void)dealloc {

// if deployment target is below 6.0 then only call this
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_diskLRUQueue);
#endif
}

@end
