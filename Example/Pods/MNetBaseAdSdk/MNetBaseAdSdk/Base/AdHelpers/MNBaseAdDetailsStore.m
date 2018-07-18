//
//  MNBaseAdDetailsStore.m
//  Pods
//
//  Created by nithin.g on 29/06/17.
//
//

#import "MNBaseAdDetailsStore.h"
#import "MNBaseAdDetails.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdDetailsStore ()
@property NSMutableDictionary<NSString *, MNBaseAdDetails *> *adDetailsDict;
@end

@implementation MNBaseAdDetailsStore
static MNBaseAdDetailsStore *instance;
static NSString *appSupportDirPath;
static NSString *storeFileName = @"mnetAdDetailsStore.json";

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      appSupportDirPath = [MNBaseUtil getSupportDirectoryPath];
      instance          = [[[self class] alloc] init];
    });

    return instance;
}

+ (void)initializeStore {
    [self getSharedInstance];
}

- (instancetype)init {
    self               = [super init];
    self.adDetailsDict = [[NSMutableDictionary alloc] init];
    [self readAndSyncDataFromFile];
    return self;
}

#pragma mark - All getter methods
- (MNBaseAdDetails *)getDetailsForAdunit:(NSString *)adunitId andPubId:(NSString *)pubId {
    NSString *key = [self getKeyFromAdunit:adunitId andPubId:pubId];
    return [self getAdDetailsForKey:key];
}

#pragma mark - All update methods
- (BOOL)updateBid:(NSNumber *)bidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId {
    if (bidVal == nil) {
        return NO;
    }

    NSString *key              = [self getKeyFromAdunit:adunitId andPubId:pubId];
    MNBaseAdDetails *adDetails = [self obtainAdDetailsForKey:key];
    adDetails.fpBid            = [bidVal doubleValue];
    return [self updateAdDetails:adDetails forKey:key];
}

- (BOOL)updateAdxBid:(NSNumber *)adxBidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId {
    if (adxBidVal == nil) {
        return NO;
    }

    NSString *key              = [self getKeyFromAdunit:adunitId andPubId:pubId];
    MNBaseAdDetails *adDetails = [self obtainAdDetailsForKey:key];
    adDetails.lastAdxBid       = [adxBidVal doubleValue];
    return [self updateAdDetails:adDetails forKey:key];
}

- (BOOL)updateAdxWinBid:(NSNumber *)adxWinbidVal forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId {
    if (adxWinbidVal == nil) {
        return NO;
    }

    NSString *key              = [self getKeyFromAdunit:adunitId andPubId:pubId];
    MNBaseAdDetails *adDetails = [self obtainAdDetailsForKey:key];
    adDetails.lastAdxWinBid    = [adxWinbidVal doubleValue];
    return [self updateAdDetails:adDetails forKey:key];
}

- (BOOL)updateAdxWinStatus:(BOOL)adxWinStatus forAdunit:(NSString *)adunitId andPubId:(NSString *)pubId {
    NSString *key = [self getKeyFromAdunit:adunitId andPubId:pubId];

    MNBaseAdDetails *adDetails = [self obtainAdDetailsForKey:key];
    adDetails.lastAdxWinStatus = (adxWinStatus) ? @"won" : @"lost";
    return [self updateAdDetails:adDetails forKey:key];
}

#pragma mark - Internal helper methods
- (NSString *)getKeyFromAdunit:(NSString *)adunit andPubId:(NSString *)pubId {
    NSString *sep = @"_";
    NSString *key = [NSString stringWithFormat:@"%@%@%@", adunit, sep, pubId];
    return key;
}

// It creates an empty adDetails if it does not exist
- (MNBaseAdDetails *)obtainAdDetailsForKey:(NSString *)key {
    MNBaseAdDetails *adDetails = [self getAdDetailsForKey:key];
    if (!adDetails) {
        adDetails = [[MNBaseAdDetails alloc] init];
    }
    return adDetails;
}

- (MNBaseAdDetails *)getAdDetailsForKey:(NSString *)key {
    MNBaseAdDetails *adDetails;
    if (key) {
        adDetails = [self.adDetailsDict objectForKey:key];
    }
    return adDetails;
}

- (BOOL)updateAdDetails:(MNBaseAdDetails *)adDetails forKey:(NSString *)key {
    if (key && adDetails) {
        [self.adDetailsDict setObject:adDetails forKey:key];
        return [self persistAdDetailsDict];
    }
    return NO;
}

#pragma mark - File handler methods
- (BOOL)persistAdDetailsDict {
    NSString *adDetailsStr = [MNJMManager toJSONStr:self.adDetailsDict];
    return [self writeToFile:adDetailsStr];
}

- (void)readAndSyncDataFromFile {
    NSString *adDetailsStr = [self readFromFile];
    if (!adDetailsStr) {
        return;
    }

    adDetailsStr = [adDetailsStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([adDetailsStr isEqualToString:@""]) {
        return;
    }

    [self syncDataWithStr:adDetailsStr];
}

- (void)syncDataWithStr:(NSString *)adDetailsStr {
    NSData *jsonData = [adDetailsStr dataUsingEncoding:NSUTF8StringEncoding];

    NSError *jsonErr;
    NSDictionary *customAdDetailsDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonErr];
    if (!jsonErr) {
        for (NSString *key in customAdDetailsDict) {
            NSDictionary *adDetailsItemDict = [customAdDetailsDict objectForKey:key];
            MNBaseAdDetails *adDetailsItem  = [[MNBaseAdDetails alloc] init];
            [MNJMManager fromDict:adDetailsItemDict toObject:adDetailsItem];

            if (adDetailsItem) {
                [self.adDetailsDict setObject:adDetailsItem forKey:key];
            }
        }
    } else {
        MNLogRemote(@"Error - %@", jsonErr);
    }
}

- (BOOL)writeToFile:(NSString *)fileContents {
    @synchronized(self) {
        return [MNBaseUtil writeToFileName:storeFileName withFolder:appSupportDirPath withContents:fileContents];
    }
}

- (NSString *)readFromFile {
    return [MNBaseUtil readFromFileName:storeFileName withFolder:appSupportDirPath];
}

@end
