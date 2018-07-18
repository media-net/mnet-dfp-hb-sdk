//
//  MNBaseBidResponseExtension.m
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseBidResponseExtension.h"
#import "MNBaseLogger.h"

@implementation MNBaseBidResponseExtension

- (NSDictionary *)propertyKeyMap {
    return @{
        @"adxAdUnitId" : @"adxAdUnitId",
    };
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    MNJMCollectionsInfo *arrayType = [MNJMCollectionsInfo instanceOfArrayWithClassType:[NSString class]];
    return @{
        @"prlog" : arrayType,
        @"prflog" : arrayType,
        @"awlog" : arrayType,
        @"videoLogsTemplate" : arrayType,
    };
}

#pragma mark - Helpers

- (NSArray<NSString *> *)getAdxLogListForKey:(MNBaseAdxLoggingUrlsMapper)key {
    // NOTE: Yes, I know valueForKeyCan be used here. Not doing it though.
    // Why? What if tomorrow the order changes
    switch (key) {
    case MNBaseAdxLogLoad:
        return self.prlog;
        break;

    case MNBaseAdxLogSuccess1:
        return self.prflog;
        break;

    case MNBaseAdxLogSuccess2:
        return self.awlog;
        break;
    }

    return nil;
}

- (BOOL)mergeWithExtension:(MNBaseBidResponseExtension *)extension {
    if (extension == nil) {
        return NO;
    }

    // Explicitly naming all the properties here.
    // Do not want to dynamically loop through all the properties
    // Do not want touch default properties.
    NSArray<NSString *> *properties =
        @[ @"prlog", @"prflog", @"awlog", @"adxAdUnitId", @"videoLogsTemplate", @"isFinal" ];

    BOOL didMergeAny = NO;
    for (NSString *propertyKey in properties) {
        // Find out the values that are nil in self
        if (NO == [self respondsToSelector:NSSelectorFromString(propertyKey)] ||
            [self valueForKey:propertyKey] != nil) {
            continue;
        }

        // Checking if the extension's value is not empty
        if ([extension respondsToSelector:NSSelectorFromString(propertyKey)]) {
            id val = [extension valueForKey:propertyKey];
            if (val != nil) {
                @try {
                    [self setValue:val forKey:propertyKey];
                    didMergeAny = YES;
                } @catch (NSException *ex) {
                    MNLogE(@"EXCEPTION - %@", ex);
                }
            }
        }
    }

    return didMergeAny;
}

@end
