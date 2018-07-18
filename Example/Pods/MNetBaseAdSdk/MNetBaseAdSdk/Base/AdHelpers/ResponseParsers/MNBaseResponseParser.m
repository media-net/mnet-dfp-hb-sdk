//
//  MNBaseResponseParser.m
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseResponseParser.h"
#import "MNBaseResponseParserPredictBids.h"

@implementation MNBaseResponseParser
static NSArray<Class<MNBaseResponseParserProtocol>> *parsersList;
+ (void)load {
    NSMutableArray<Class<MNBaseResponseParserProtocol>> *parsersListMut =
        [[NSMutableArray<Class<MNBaseResponseParserProtocol>> alloc] init];

    [parsersListMut addObject:[MNBaseResponseParserPredictBids class]];

    parsersList = [NSArray<Class<MNBaseResponseParserProtocol>> arrayWithArray:parsersListMut];
}

+ (id<MNBaseResponseParserProtocol>)getParser {
    if (parsersList == nil || [parsersList count] == 0) {
        return nil;
    }

    /*
     NOTE:
     In the future, when there are more parsers, will have to filter them out based on some args.
     Right now, just popping the last item
     */
    Class<MNBaseResponseParserProtocol> parserClass = [parsersList lastObject];
    return [parserClass getInstance];
}

@end
