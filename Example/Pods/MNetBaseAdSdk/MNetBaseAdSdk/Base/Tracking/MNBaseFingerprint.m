//
//  MNBaseFingerprint.m
//  Pods
//
//  Created by nithin.g on 22/05/17.
//
//

#import "MNBaseFingerprint.h"
#import "MNBaseFingerprintData.h"
#import "MNBaseHttpClient.h"
#import "MNBaseLogger.h"
#import "MNBaseURL.h"
#import "MNBaseUtil.h"

#define STORE_FILE_NAME @"MNBaseUuidStore.txt"
#define UUID_KEY @"mnet_uuid"

@interface MNBaseFingerprint ()
@property (atomic) NSString *uuid;
@property (atomic) NSString *storeFolderPath;

@end

@implementation MNBaseFingerprint
static MNBaseFingerprint *instance;

+ (id)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseFingerprint alloc] init];
      instance.storeFolderPath =
          [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
      [instance initializeStore];
      [instance fetchAndSetUUID];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];

    return self;
}

- (NSString *)getUUID {
    return self.uuid;
}

- (void)fetchAndSetUUID {
    // Check if the UUID exists
    self.uuid = [self readUUIDFromStore];

    // Final resort
    if (!self.uuid) {
        [self getUUIDFromServer];
    }
}

- (void)getUUIDFromServer {
    MNBaseFingerprintData *requestParams = [[MNBaseFingerprintData alloc] init];

    [MNBaseHttpClient doPostOn:[[MNBaseURL getSharedInstance] getFingerPrintUrl]
        headers:nil
        params:nil
        body:[MNJMManager toJSONStr:requestParams]
        success:^(NSDictionary *_Nonnull response) {
          NSString *uuid = [response objectForKey:@"uid"];
          if (uuid) {
              self.uuid = uuid;
              [self writeUUIDToStore];
          }
        }
        error:^(NSError *_Nonnull error) {
          MNLogRemote(@"Failed fetching UUID from server- %@", error);
        }];
}

- (void)writeUUIDToStore {
    if (!self.uuid) {
        return;
    }

    // Write to file
    [MNBaseUtil writeToFileName:STORE_FILE_NAME withFolder:self.storeFolderPath withContents:self.uuid];

    // Write to keystore
    [MNBaseUtil writeToKeyChain:self.uuid withKey:UUID_KEY];
}

- (NSString *)readUUIDFromStore {
    NSString *uuid = [MNBaseUtil readFromFileName:STORE_FILE_NAME withFolder:self.storeFolderPath];

    if (!uuid || [uuid isEqualToString:@""]) {
        // Check in the keystore
        uuid = [MNBaseUtil readFromKeyChainForKey:UUID_KEY];
        if (uuid && [uuid isEqualToString:@""]) {
            uuid = nil;
        }
    }

    return uuid;
}

- (void)initializeStore {
    [instance initializeFolder:self.storeFolderPath];

    NSString *filePath = [self.storeFolderPath stringByAppendingPathComponent:STORE_FILE_NAME];
    if (![MNBaseUtil doesPathExist:filePath]) {
        [MNBaseUtil writeToFileName:STORE_FILE_NAME withFolder:self.storeFolderPath withContents:@""];
    }
}

- (BOOL)initializeFolder:(NSString *)storeFolderPath {
    // Check for the presence of the applications support directory
    if (![[NSFileManager defaultManager] fileExistsAtPath:storeFolderPath isDirectory:NULL]) {
        NSError *dirCreationErr = nil;

        if (![[NSFileManager defaultManager] createDirectoryAtPath:storeFolderPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&dirCreationErr]) {
            MNLogD(@"APP_DISCOVER: %@", dirCreationErr.localizedDescription);
            return NO;
        }
    }

    // Mark the directory as excluded from iCloud backups
    NSError *backupExcludeErr = nil;
    NSURL *url                = [NSURL fileURLWithPath:storeFolderPath];
    if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&backupExcludeErr]) {

        MNLogD(@"APP_DISCOVER: Error excluding %@ from backup %@", url.lastPathComponent,
               backupExcludeErr.localizedDescription);
        return NO;
    }

    return YES;
}

@end
