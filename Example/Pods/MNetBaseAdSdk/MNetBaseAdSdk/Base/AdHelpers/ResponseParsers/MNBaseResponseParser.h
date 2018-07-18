//
//  MNBaseResponseParser.h
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseResponseParserProtocol.h"
#import <Foundation/Foundation.h>

@interface MNBaseResponseParser : NSObject

+ (id<MNBaseResponseParserProtocol>)getParser;

@end
