//
//  MNBaseAdControllerLogger.h
//  Pods
//
//  Created by nithin.g on 09/06/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseAdControllerLogger : NSObject
- (instancetype)initWithLoggingUrls:(NSArray *)loggingUrls withPulseLoggerKey:(NSString *)key;
- (void)updateUrlsWithReplacementList:(NSArray *)replacementList;
- (void)makeRequestsAfterReplacement:(NSArray *)replacementList;
@end
