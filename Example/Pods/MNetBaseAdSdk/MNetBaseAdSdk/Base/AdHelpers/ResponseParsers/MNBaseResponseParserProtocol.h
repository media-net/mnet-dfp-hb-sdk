//
//  MNBaseResponseParserProtocol.h
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseBidResponse.h"
#import "MNBaseResponseParserExtras.h"
#import <Foundation/Foundation.h>

@protocol MNBaseResponseParserProtocol <NSObject>

+ (instancetype)getInstance;
- (NSArray<MNBaseBidResponse *> *)parseResponse:(NSDictionary *)responseDict
                         exclusivelyForAdUnitId:(NSString *)exclusiveAdUnitId
                                withExtraParams:(MNBaseResponseParserExtras *)parserExtras
                                       outError:(NSError **)outErr;
@end
