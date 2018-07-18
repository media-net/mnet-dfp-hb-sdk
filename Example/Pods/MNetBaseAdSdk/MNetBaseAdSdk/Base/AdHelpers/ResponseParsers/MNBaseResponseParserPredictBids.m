//
//  MNBaseResponseParserPredictBids.m
//  Pods
//
//  Created by nithin.g on 15/09/17.
//
//

#import "MNBaseResponseParserPredictBids.h"
#import "MNBaseError.h"
#import "MNBaseLogger.h"
#import "MNBaseResponseProcessorsManager.h"
#import "MNBaseResponseTransformerManager.h"
#import "MNBaseResponseValuesFromRequest.h"
#import <MNetJSONModeller/MNJMManager.h>

@implementation MNBaseResponseParserPredictBids

+ (instancetype)getInstance {
    return [[MNBaseResponseParserPredictBids alloc] init];
}

- (NSArray<MNBaseBidResponse *> *)parseResponse:(NSDictionary *)responseDict
                         exclusivelyForAdUnitId:(NSString *)exclusiveAdUnitId
                                withExtraParams:(MNBaseResponseParserExtras *)parserExtras
                                       outError:(NSError **)outErr {
    if (responseDict == nil) {
        (*outErr) = [MNBaseError createErrorWithDescription:@"Response is empty"];
        return nil;
    }

    id ads = [responseDict objectForKey:@"ads"];
    if (ads == nil || [ads isKindOfClass:[NSDictionary class]] == NO) {
        NSString *errMsg = @"Ads key in the response does not contain a dictionary";
        if (ads == nil) {
            errMsg = @"Ads key in the response is empty";
        }
        (*outErr) = [MNBaseError createErrorWithDescription:errMsg];
        return nil;
    }
    NSDictionary *adsDict                               = (NSDictionary *) ads;
    NSMutableArray<MNBaseBidResponse *> *bidResponseArr = [[NSMutableArray<MNBaseBidResponse *> alloc] init];

    NSString *predictionId;
    /*
     NOTE: This is a temporary solution.
     The problem here is that the response-transformer only works for moving stuff inside the ad_details dict.
     At the top-most level, it doesn't work.
     Unfortunately, there's an ext at the top-most level, which has a predictionId which is useful.
     So right now, this value is manually copied.
     There could be a future-fix if the response-structure changes
     */
    if ([responseDict objectForKey:@"ext"]) {
        id extObj = [responseDict objectForKey:@"ext"];
        if (extObj != nil && [extObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *extDict = (NSDictionary *) extObj;
            predictionId          = [extDict objectForKey:@"prediction_id"];
        }
    }

    // Checking for exclusive ad-unit-id
    BOOL isExclusive = YES;
    if (exclusiveAdUnitId == nil || [exclusiveAdUnitId isEqualToString:@""]) {
        isExclusive = NO;
    }

    for (NSString *adUnitId in adsDict) {
        // Filter for adunit Id if it's given. Else adding everything
        if (isExclusive && [exclusiveAdUnitId isEqualToString:adUnitId] == NO) {
            continue;
        }

        MNBaseResponseValuesFromRequest *responseExtras = [[MNBaseResponseValuesFromRequest alloc] init];
        responseExtras.adUnitId                         = adUnitId;
        if (parserExtras) {
            responseExtras.contextUrl          = parserExtras.contextUrl;
            responseExtras.adCycleId           = parserExtras.adCycleId;
            responseExtras.visitId             = parserExtras.visitId;
            responseExtras.viewController      = parserExtras.viewController;
            responseExtras.viewControllerTitle = parserExtras.viewControllerTitle;
            responseExtras.keywords            = parserExtras.keywords;
        }

        responseExtras.predictionId = predictionId;

        NSDictionary *adsForAdUnitId = [adsDict objectForKey:adUnitId];
        if (adsForAdUnitId == nil || [adsForAdUnitId isKindOfClass:[NSDictionary class]] == NO) {
            MNLogD(@"Skipping parsing for adUnit - %@, since no value for ad-unit-id key is found", adUnitId);
            continue;
        }

        id adsDetails = [adsForAdUnitId objectForKey:@"ads_details"];
        if (adsDetails == nil || [adsDetails isKindOfClass:[NSArray class]] == NO) {
            MNLogD(@"Skipping parsing for adUnit - %@, since adsDetails object is missing", adUnitId);
            continue;
        }

        NSArray *adsDetailsList = (NSArray *) adsDetails;
        NSMutableArray<MNBaseBidResponse *> *bidResponsesForAdUnitId =
            [[NSMutableArray<MNBaseBidResponse *> alloc] initWithCapacity:[adsDetailsList count]];

        for (NSDictionary *adObj in adsDetailsList) {
            MNBaseBidResponse *bidResponse = [[MNBaseBidResponse alloc] init];
            [MNJMManager fromDict:adObj toObject:bidResponse];

            if (bidResponse == nil) {
                MNLogD(@"Unable to parse one bid-response object, inside ad_details for ad-unit-id - %@", adUnitId);
                continue;
            }

            [bidResponsesForAdUnitId addObject:bidResponse];
        }

        // Call the response transformer
        // Apply all the transformers
        MNBaseResponseTransformerManager *transformManager =
            [MNBaseResponseTransformerManager getInstanceWithBidResponseArr:bidResponsesForAdUnitId
                                                       withOriginalResponse:adsForAdUnitId
                                                          andResponseExtras:responseExtras];
        bidResponsesForAdUnitId = [transformManager transformResponse];

        // Call the response-processor
        MNBaseResponseProcessorsManager *processManager =
            [MNBaseResponseProcessorsManager getInstanceWithResponse:responseDict withResponseExtras:responseExtras];
        [processManager processResponse];

        // Adding the local bid-responses array to the global one
        if (bidResponsesForAdUnitId != nil && [bidResponsesForAdUnitId count] > 0) {
            [bidResponseArr addObjectsFromArray:bidResponsesForAdUnitId];
        }
    }

    return bidResponseArr;
}

@end
