//
//  MNBaseResponseTransformerExtensions.m
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import "MNBaseResponseTransformerExtensions.h"

@implementation MNBaseResponseTransformerExtensions

- (NSMutableArray *)transformBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                       withOriginalResponse:(NSDictionary *)response
                          andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    NSMutableArray<MNBaseBidResponse *> *updatedBidResponseArr =
        [[NSMutableArray alloc] initWithCapacity:[bidResponseArr count]];

    MNBaseBidResponseExtension *parentExtension = [self getExtFromResponse:response];
    if (parentExtension == nil) {
        return bidResponseArr;
    }

    // Merge the extension for every entry in the bid-response-arr
    for (MNBaseBidResponse *bidResponse in bidResponseArr) {
        if (bidResponse.extension == nil) {
            bidResponse.extension = parentExtension;
        } else {
            [bidResponse.extension mergeWithExtension:parentExtension];
        }

        [updatedBidResponseArr addObject:bidResponse];
    }

    return updatedBidResponseArr;
}

- (MNBaseBidResponseExtension *)getExtFromResponse:(NSDictionary *)response {
    id extObj = [response valueForKey:@"ext"];
    if ([extObj isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }

    NSDictionary *extObjDict              = (NSDictionary *) extObj;
    MNBaseBidResponseExtension *extension = [[MNBaseBidResponseExtension alloc] init];
    [MNJMManager fromDict:extObjDict toObject:extension];
    return extension;
}

@end
