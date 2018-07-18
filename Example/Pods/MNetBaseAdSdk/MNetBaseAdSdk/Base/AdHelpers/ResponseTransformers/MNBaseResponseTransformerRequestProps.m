//
//  MNBaseResponseTransformerRequestProps.m
//  Pods
//
//  Created by nithin.g on 18/09/17.
//
//

#import "MNBaseResponseTransformerRequestProps.h"

@implementation MNBaseResponseTransformerRequestProps

- (NSMutableArray *)transformBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                       withOriginalResponse:(NSDictionary *)response
                          andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    if (responseExtras == nil || bidResponseArr == nil) {
        return bidResponseArr;
    }

    NSMutableArray<MNBaseBidResponse *> *updatedResponseArr =
        [[NSMutableArray alloc] initWithCapacity:[bidResponseArr count]];
    for (MNBaseBidResponse *bidResponse in bidResponseArr) {
        if (responseExtras.adUnitId != nil) {
            bidResponse.creativeId = responseExtras.adUnitId;
        }

        if (responseExtras.adCycleId != nil) {
            [bidResponse setAdCycleId:responseExtras.adCycleId];
        }

        if (responseExtras.visitId != nil) {
            [bidResponse setVisitId:responseExtras.visitId];
        }

        if (responseExtras.contextUrl != nil) {
            [bidResponse setViewContextLink:responseExtras.contextUrl];
        }

        if (responseExtras.predictionId != nil) {
            [bidResponse setPredictionId:responseExtras.predictionId];
        }

        if (responseExtras.viewControllerTitle != nil) {
            [bidResponse setViewControllerTitle:responseExtras.viewControllerTitle];
        }

        if (responseExtras.keywords != nil) {
            [bidResponse setKeywords:responseExtras.keywords];
        }

        [updatedResponseArr addObject:bidResponse];
    }

    return updatedResponseArr;
}

@end
