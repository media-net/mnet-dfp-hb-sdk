//
//  MNBaseMacroManager.m
//  Pods
//
//  Created by nithin.g on 09/10/17.
//
//

#import "MNBaseAdIdManager.h"
#import "MNBaseDataPrivacy.h"
#import "MNBaseDeviceInfo.h"
#import "MNBaseLogger.h"
#import "MNBaseMacroManager+Internal.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import "NSString+MNBaseStringCrypto.h"

@implementation MNBaseMacroManager

static NSString *adUnitIdMacro     = @"${CRID}";
static NSString *adCycleIdMacro    = @"${ACID}";
static NSString *crawledUrlMacro   = @"${REQ_URL}";
static NSString *auctionPriceMacro = @"${AUCTION_PRICE}";
static NSString *logIdMacro        = @"${LI}";
static NSString *didBidderWinMacro = @"${IWB}";

static NSString *providerIdMacro    = @"${PID}";
static NSString *providerNameMacro  = @"${PN}";
static NSString *bidPriceMacro      = @"${BDP}";
static NSString *cbdpMacro          = @"${CBDP}";
static NSString *closingPriceMacro  = @"${CLSPRC}";
static NSString *rawAdTagMacro      = @"${RT}";
static NSString *originalPriceMacro = @"${OGBDP}";
static NSString *adcodeMacro        = @"${ADCODE}";
static NSString *keywordsMacro      = @"${KEYWORDS}";

static NSString *apLogStr = @"aplog";
static NSString *awLogStr = @"awlog";
static NSString *adLogStr = @"adlog";

static NSString *dfpMacroKey = @"${DFPBD}";

static NSString *advertIdMacro     = @"${ADID}";
static NSString *advertIdHashMacro = @"${ADID_HASH}";

static MNBaseMacroManager *instance;
+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - Logging pixels

- (NSString *)processMacrosForAdCode:(NSString *)adCode withResponse:(MNBaseBidResponse *)bidResponse {
    if (adCode == nil) {
        return nil;
    }
    NSArray<NSString *> *adCodeList = @[ adCode ];
    NSArray *updatedAdCodeList      = [self processMacrosForLoggingPixels:adCodeList withResponse:bidResponse];
    return [updatedAdCodeList firstObject];
}

- (NSArray<NSString *> *)processMacrosForLoggingPixels:(NSArray<NSString *> *)loggingUrls
                                          withResponse:(MNBaseBidResponse *)bidResponse {
    if (loggingUrls == nil) {
        return nil;
    }
    NSDictionary *replacementMap      = [self createReplacementMapForResponse:bidResponse];
    NSDictionary *replacementMapFinal = [[NSDictionary alloc] initWithDictionary:replacementMap];
    return [self replaceMacrosForList:loggingUrls withReplacementMap:replacementMapFinal];
}

#pragma mark - apLogsForBidders

- (NSArray<NSString *> *)processMacrosForApLogsForBidders:(NSArray<NSString *> *)loggingUrls
                                             withResponse:(MNBaseBidResponse *)bidResponse {
    if (loggingUrls == nil) {
        return loggingUrls;
    }

    NSString *modifiedCode;
    if (bidResponse != nil && bidResponse.adCode != nil) {
        NSString *adCode                   = bidResponse.adCode;
        NSDictionary *adcodeReplacementMap = [self createReplacementMapForResponse:bidResponse];
        modifiedCode = [[self replaceMacrosForList:@[ adCode ] withReplacementMap:adcodeReplacementMap] firstObject];
    } else {
        modifiedCode = @"";
    }

    NSMutableDictionary *replacementMap = [[self createReplacementMapForResponse:bidResponse] mutableCopy];
    replacementMap[adcodeMacro]         = modifiedCode;
    return [self replaceMacrosForList:loggingUrls withReplacementMap:replacementMap];
}

#pragma mark - expiry logs

- (NSArray<NSString *> *)processMacrosForExpiryLogs:(NSArray<NSString *> *)loggingUrls
                                       withResponse:(MNBaseBidResponse *)bidResponse {
    if (loggingUrls == nil) {
        return loggingUrls;
    }

    NSMutableDictionary *replacementMapFinal = [[self createReplacementMapForResponse:bidResponse] mutableCopy];
    // NOTE: Do not move this code to createReplacementMapForResponse method
    // Macro replacement is automatically triggered while accessing [bidResponse adCode].
    // This causes recursive calls to createReplacementMapForResponse which crashes app.
    if (bidResponse != nil) {
        replacementMapFinal[rawAdTagMacro] = [bidResponse adCode];
    }
    return [self replaceMacrosForList:loggingUrls withReplacementMap:replacementMapFinal];
}

#pragma mark - server extras

- (NSDictionary *)processServerExtras:(NSDictionary *)serverExtrasMap withResponse:(MNBaseBidResponse *)bidResponse {
    if (serverExtrasMap == nil) {
        return nil;
    }

    NSDictionary *replacementMap = [self createReplacementMapForResponse:bidResponse];
    NSDictionary *modifiedServerExtras =
        [self applyValueReplacementFor:serverExtrasMap withReplacementMap:replacementMap];
    return modifiedServerExtras;
}

#pragma mark - Replacement values

- (NSArray<NSString *> *)replaceMacrosForList:(NSArray<NSString *> *)list
                           withReplacementMap:(NSDictionary<NSString *, NSString *> *)replacementMap {
    if (replacementMap == nil) {
        return list;
    }
    NSDictionary *extendedReplacementMap = [self getExtendedReplacementMap:replacementMap];

    NSMutableArray<NSString *> *modifiedList = [[NSMutableArray alloc] initWithCapacity:[list count]];
    for (NSString *originalStr in list) {
        NSString *modifiedStr = [MNBaseUtil replaceStr:originalStr fromMap:extendedReplacementMap];
        [modifiedList addObject:modifiedStr];
    }

    return [NSArray arrayWithArray:modifiedList];
}

- (NSDictionary *)applyValueReplacementFor:(NSDictionary *)originalMap
                        withReplacementMap:(NSDictionary<NSString *, NSString *> *)replacementMap {
    NSMutableDictionary *map = [originalMap mutableCopy];
    for (NSString *key in originalMap) {
        id value = [originalMap objectForKey:key];
        if (NO == [value isKindOfClass:[NSString class]]) {
            [map setObject:value forKey:key];
            continue;
        }

        NSDictionary *extendedReplacementMap = [self getExtendedReplacementMap:replacementMap];

        NSString *modifiedVal = [MNBaseUtil replaceStr:value fromMap:extendedReplacementMap];
        [map setObject:modifiedVal forKey:key];
    }

    return [[NSDictionary alloc] initWithDictionary:map];
}

- (NSDictionary *)getExtendedReplacementMap:(NSDictionary *)replacementMap {
    NSMutableDictionary *modifiedMap = [[NSMutableDictionary alloc] init];
    for (NSString *macroKey in replacementMap) {
        NSString *encodedKey = [MNBaseUtil urlEncode:macroKey];
        NSString *val        = [replacementMap objectForKey:macroKey];
        if (encodedKey != macroKey) {
            // It makes sense to macro-replace the encoded key with encoded value
            NSString *encodedVal = [MNBaseUtil urlEncode:val];
            [modifiedMap setObject:encodedVal forKey:encodedKey];
        }
        [modifiedMap setObject:val forKey:macroKey];
    }
    return modifiedMap;
}

#pragma mark Helper method

/// Make sure that this never returns null
- (NSString *_Nonnull)getReplacementStrForReqUrl:(MNBaseBidResponse *)bidResponse
                            shouldAppendKeywords:(BOOL)shouldAppendKeywords {
    NSString *contextLink = bidResponse.viewContextLink;
    if ([MNBaseUtil isNil:contextLink] == YES) {
        return @"";
    }
    if (NO == shouldAppendKeywords || [MNBaseUtil isNil:bidResponse.keywords] == YES) {
        return contextLink;
    }

    NSString *keywords             = [bidResponse keywords];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:contextLink];
    if (urlComponents == nil) {
        MNLogD(@"Url components cannot be created! %@ is malformed!", contextLink);
        return contextLink;
    }

    NSURLQueryItem *keywordsQueryItem         = [NSURLQueryItem queryItemWithName:@"keywords" value:keywords];
    NSArray<NSURLQueryItem *> *queryItemsList = [urlComponents queryItems];
    if (queryItemsList != nil && [queryItemsList count] > 0) {
        NSMutableArray<NSURLQueryItem *> *queryItems = [queryItemsList mutableCopy];
        [queryItems addObject:keywordsQueryItem];
        [urlComponents setQueryItems:queryItems];
    } else {
        [urlComponents setQueryItems:@[ keywordsQueryItem ]];
    }
    NSURL *modifiedUrl = [urlComponents URL];
    if (modifiedUrl == nil) {
        return contextLink;
    }
    return [modifiedUrl absoluteString];
}

- (NSDictionary *)createReplacementMapForResponse:(MNBaseBidResponse *)bidResponse {
    // Replace all macros with empty string
    NSMutableDictionary *replacementMap = [@{
        adUnitIdMacro : @"",
        adCycleIdMacro : @"",
        crawledUrlMacro : @"",
        auctionPriceMacro : @"",
        originalPriceMacro : @"",
        providerIdMacro : @"",
        bidPriceMacro : @"",
        cbdpMacro : @"",
        closingPriceMacro : @"",
        providerNameMacro : @"",
        advertIdMacro : @"",
        advertIdHashMacro : @"",
        dfpMacroKey : @"",
        rawAdTagMacro : @"",
        didBidderWinMacro : @"",
        adcodeMacro : @"",
        logIdMacro : @"",
        keywordsMacro : @"",
    } mutableCopy];

    // Return replacementMap with empty macro replacement if bidResponse is nil
    if (bidResponse == nil) {
        return replacementMap;
    }

    // NOTE: Do not forget to relpace macros with empty string if new macros are added
    if ([MNBaseUtil isNil:bidResponse.creativeId] == NO) {
        replacementMap[adUnitIdMacro] = bidResponse.creativeId;
    }

    if ([MNBaseUtil isNil:[bidResponse getAdCycleId]] == NO) {
        replacementMap[adCycleIdMacro] = [bidResponse getAdCycleId];
    }

    replacementMap[crawledUrlMacro] =
        [self getReplacementStrForReqUrl:bidResponse
                    shouldAppendKeywords:[[MNBaseSdkConfig getInstance] isEnabledAppendKeywordsRequrl]];

    if ([MNBaseUtil isNil:bidResponse.ogBid] == NO) {
        replacementMap[auctionPriceMacro]  = [bidResponse.ogBid stringValue];
        replacementMap[originalPriceMacro] = [bidResponse.ogBid stringValue];
    }

    if ([MNBaseUtil isNil:bidResponse.bidderId] == NO) {
        replacementMap[providerIdMacro] = [bidResponse.bidderId stringValue];
    }

    if ([MNBaseUtil isNil:bidResponse.bid] == NO) {
        replacementMap[bidPriceMacro] = [[bidResponse bid] stringValue];
    }

    if ([MNBaseUtil isNil:bidResponse.cbdp] == NO) {
        replacementMap[cbdpMacro] = [[bidResponse cbdp] stringValue];
    }

    if ([MNBaseUtil isNil:bidResponse.clsprc] == NO) {
        replacementMap[closingPriceMacro] = [[bidResponse clsprc] stringValue];
    }

    if ([MNBaseUtil isNil:[bidResponse bidderName]] == NO) {
        replacementMap[providerNameMacro] = [bidResponse bidderName];
    }

    if ([MNBaseUtil isNil:[bidResponse keywords]] == NO) {
        replacementMap[keywordsMacro] = [MNBaseUtil jsonEscape:[bidResponse keywords]];
    }

    // Replace advertising id macro
    MNBaseAdIdManager *adIdManager = [MNBaseAdIdManager getSharedInstance];
    if ([MNBaseUtil isNil:[adIdManager getAdvertId]] == NO && [[MNBaseDataPrivacy getSharedInstance] doNoTrack] == NO) {
        replacementMap[advertIdMacro]     = [adIdManager getAdvertId];
        replacementMap[advertIdHashMacro] = [[adIdManager getAdvertId] MD5];
    }

    // Formatter for dfp-bid
    NSNumberFormatter *dfpBidFormatter = [self getDfpBidFormatter];
    // Replace the auctioned-responses
    NSNumber *dfpBid    = bidResponse.dfpbid;
    NSString *dfpBidStr = @"";
    if (dfpBid != nil) {
        dfpBidStr = [dfpBidFormatter stringFromNumber:dfpBid];
    }

    replacementMap[dfpMacroKey] = dfpBidStr;

    return replacementMap;
}

- (NSNumberFormatter *)getDfpBidFormatter {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    return formatter;
}
@end
