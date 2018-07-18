//
//  MNBaseBidResponseExtension.h
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseConstants.h"
#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMBoolean.h>
#import <MNetJSONModeller/MNJMManager.h>

typedef NS_ENUM(NSInteger, MNBaseAdxLoggingUrlsMapper) {
    MNBaseAdxLogLoad,
    MNBaseAdxLogSuccess1,
    MNBaseAdxLogSuccess2,
};

@interface MNBaseBidResponseExtension : NSObject <MNJMMapperProtocol>

@property (atomic) NSArray<NSString *> *prlog;
@property (atomic) NSArray<NSString *> *prflog;
@property (atomic) NSArray<NSString *> *awlog;
@property (atomic) NSString *adxAdUnitId;

@property (atomic) NSArray<NSString *> *videoLogsTemplate;
@property (atomic) MNJMBoolean *isFinal;

- (NSArray<NSString *> *)getAdxLogListForKey:(MNBaseAdxLoggingUrlsMapper)key;

- (BOOL)mergeWithExtension:(MNBaseBidResponseExtension *)extension;

@end
