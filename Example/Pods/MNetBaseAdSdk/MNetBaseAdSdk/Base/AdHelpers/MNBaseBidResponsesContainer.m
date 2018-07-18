//
//  MNBaseBidResponsesContainer.m
//  MNBaseAdSdk
//
//  Created by nithin.g on 18/10/17.
//

#import "MNBaseBidResponsesContainer.h"
#import "MNBaseUtil.h"

@implementation MNBaseBidResponsesContainer

@synthesize selectedBidResponse = _selectedBidResponse;

+ (instancetype)getInstanceWithBidResponses:(NSArray<MNBaseBidResponse *> *)bidResponsesArr {
    MNBaseBidResponsesContainer *instance = [[MNBaseBidResponsesContainer alloc] init];
    [instance setBidResponsesArr:bidResponsesArr];
    [instance setAuctionDetails:nil];
    [instance setApLogs:nil];
    [instance setAreDefaultBids:NO];
    return instance;
}

- (MNBaseBidResponse *_Nullable)getBidResponseForBidderId:(NSNumber *)bidderId {
    NSArray<MNBaseBidResponse *> *bidResponsesArr = self.bidResponsesArr;
    if (bidderId == nil || bidResponsesArr == nil || [bidResponsesArr count] == 0) {
        return nil;
    }

    for (MNBaseBidResponse *bidResponse in bidResponsesArr) {
        if ([[bidResponse bidderId] isEqualToValue:bidderId]) {
            return bidResponse;
        }
    }
    return nil;
}

- (MNBaseBidResponse *)getBidResponseForBidType:(NSString *)bidType {
    NSNumber *responseIndex = [self getIndexForBidResponseArr:self.bidResponsesArr forBidType:bidType];
    if (responseIndex == nil) {
        return nil;
    }

    return [self.bidResponsesArr objectAtIndex:[responseIndex unsignedIntegerValue]];
}

- (NSNumber *)getIndexForBidResponseArr:(NSArray<MNBaseBidResponse *> *)bidResponsesArr forBidType:(NSString *)type {
    if (bidResponsesArr != nil && type != nil && [bidResponsesArr count] > 0) {
        for (NSUInteger bidIndex = 0; bidIndex < [bidResponsesArr count]; bidIndex++) {
            MNBaseBidResponse *response = [bidResponsesArr objectAtIndex:bidIndex];
            NSString *bidType           = response.bidType;
            if (bidType && [bidType isEqualToString:type]) {
                return [NSNumber numberWithUnsignedInteger:bidIndex];
            }
        }
    }
    return nil;
}

- (NSArray<MNBaseBidResponse *> *_Nullable)getBidResponsesCloneWithoutAdx {
    NSMutableArray *bidResponsesArrClone = [self.bidResponsesArr mutableCopy];

    // Remove the Adx entry from bidResponsesArrClone
    NSNumber *adExObjIndex = [self getIndexForBidResponseArr:self.bidResponsesArr forBidType:BID_TYPE_ADX];

    if (adExObjIndex != nil) {
        [bidResponsesArrClone removeObjectAtIndex:[adExObjIndex unsignedIntegerValue]];
    }

    return [NSArray arrayWithArray:bidResponsesArrClone];
}

#pragma mark - Selecting the bid response

- (MNBaseBidResponse *)getSelectedBidResponseCandidate {
    NSArray<MNBaseBidResponse *> *bidResponsesArr = self.bidResponsesArr;
    if (NO == bidResponsesArr || [bidResponsesArr count] == 0) {
        return nil;
    }

    NSNumber *selectedIndex = [self findResponseIndexForBidderIdStr:self.selectedBidderIdStr inList:bidResponsesArr];
    if (selectedIndex == nil) {
        // Fetch the first fpd response
        selectedIndex = [self getIndexForBidResponseArr:bidResponsesArr forBidType:BID_TYPE_FIRST_PARTY];
    }

    if (selectedIndex == nil) {
        return nil;
    }
    return [self.bidResponsesArr objectAtIndex:[selectedIndex integerValue]];
}

- (NSNumber *)findResponseIndexForBidderIdStr:(NSString *)bidderIdStr
                                       inList:(NSArray<MNBaseBidResponse *> *)bidResponseArr {
    if (NO == [self isBidderIdStrSet:bidderIdStr]) {
        return nil;
    }

    NSUInteger index;
    for (index = 0; index < [bidResponseArr count]; index++) {
        MNBaseBidResponse *bidResponseObj = [bidResponseArr objectAtIndex:index];
        NSNumber *currentBidderId         = bidResponseObj.bidderId;
        NSString *currentBidderIdStr      = [currentBidderId stringValue];

        if ([currentBidderIdStr isEqualToString:bidderIdStr]) {
            return [NSNumber numberWithUnsignedInteger:index];
        }
    }
    return nil;
}

- (BOOL)isBidderIdStrSet:(NSString *)bidderIdStr {
    if ([MNBaseUtil isNil:bidderIdStr]) {
        return NO;
    }
    NSString *trimmedBidderId = [bidderIdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return (NO == [trimmedBidderId isEqualToString:@""]);
}

#pragma mark - Recycling logic

/// Recycle all the bids in the current response.
- (BOOL)recycleAllBids {
    return [self recycleBidsFromAdResponseExceptBidResponse:nil];
}

/// Recycle all the bids in the current response except for the selected response.
- (BOOL)recycleAllBidsExceptSelectedResponse {
    return [self recycleBidsFromAdResponseExceptBidResponse:self.selectedBidResponse];
}

- (BOOL)recycleBidsFromAdResponseExceptBidResponse:(MNBaseBidResponse *_Nullable)exceptionBidResponse {
    if (self.bidResponsesArr == nil || [self.bidResponsesArr count] == 0) {
        return NO;
    }

    NSMutableArray *responsesArr = [NSMutableArray arrayWithArray:self.bidResponsesArr];
    if (exceptionBidResponse != nil) {
        NSUInteger index = [responsesArr indexOfObject:exceptionBidResponse];
        if (index != -1) {
            [responsesArr removeObjectAtIndex:index];
        }
    }

    // This array will hold the bid-responses that've not been added to the bid-store.
    NSMutableArray<MNBaseBidResponse *> *finalBidResponsesArr = [NSMutableArray arrayWithArray:self.bidResponsesArr];

    // NOTE: This will only recycle the fpds and the tpds. Nothing else
    NSArray<NSString *> *allowedBidTypes = @[ BID_TYPE_FIRST_PARTY, BID_TYPE_THIRD_PARTY ];
    BOOL didAddToBidStore                = NO;
    for (MNBaseBidResponse *response in responsesArr) {
        NSString *bidType = [response bidType];
        if (bidType == nil || NO == [allowedBidTypes containsObject:bidType]) {
            continue;
        }

        id<MNBaseBidStoreProtocol> bidStore = [MNBaseBidStore getStore];
        BOOL insertionStatus                = [bidStore insert:response];
        if (insertionStatus) {
            // remove that item in the bid-responses array, if inserted to the bid-store
            [finalBidResponsesArr removeObject:response];
        }
        didAddToBidStore = didAddToBidStore || insertionStatus;
    }
    self.bidResponsesArr = [NSArray<MNBaseBidResponse *> arrayWithArray:finalBidResponsesArr];

    return didAddToBidStore;
}

- (MNBaseBidResponse *)selectedBidResponse {
    return _selectedBidResponse;
}

- (void)setSelectedBidResponse:(MNBaseBidResponse *)selectedBidResponse {
    _selectedBidResponse = selectedBidResponse;
    if (_selectedBidResponse != nil) {
        if ([_selectedBidResponse bidderId] != nil) {
            _selectedBidderIdStr = [[_selectedBidResponse bidderId] stringValue];
        }
    }
}

#pragma mark - Stripping logic

- (void)stripAllExceptSelectedBidResponse {
    if (self.bidResponsesArr == nil && self.selectedBidResponse == nil) {
        return;
    }
    NSMutableArray *bidResponseArrClone = [NSMutableArray arrayWithObject:self.selectedBidResponse];
    self.bidResponsesArr                = [bidResponseArrClone copy];
}

@end
