//
//  MNBaseAdSource.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseExtBidRequest.h"

@implementation MNBaseExtBidRequest

+ (id)createWithAdRequest:(MNBaseAdRequest *)adRequest {
    BOOL isInternal = NO;
    NSDictionary *customExtras;
    if (adRequest != nil) {
        isInternal = [adRequest isInternal];
        if ([adRequest customExtras] != nil && [[adRequest customExtras] count] > 0) {
            customExtras = [adRequest customExtras];
        }
    }
    return [[MNBaseExtBidRequest alloc] initWithIsInternal:isInternal andCustomExtras:customExtras];
}

- (id)initWithIsInternal:(BOOL)isInternal andCustomExtras:(NSDictionary<NSString *, NSString *> *)customExtras {
    self = [super init];
    if (self) {
        _source       = [NSNumber numberWithInt:(isInternal ? 1 : 0)];
        _customExtras = customExtras;
    }
    return self;
}

- (id)init {
    return [self initWithIsInternal:false andCustomExtras:nil];
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"customExtras" :
            [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class] andValueType:[NSString class]]
    };
}

- (NSDictionary *)propertyKeyMap {
    return @{@"source" : @"source_fd"};
}
@end
