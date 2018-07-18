//
//  MNBaseBannerAdRequest.m
//  Pods
//
//  Created by akshay.d on 25/05/17.
//
//

#import "MNBaseBannerAdRequest.h"

@implementation MNBaseBannerAdRequest

+ (MNBaseBannerAdRequest *)newInstance {
    return [[MNBaseBannerAdRequest alloc] init];
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{@"format" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseImpFormat class]]};
}
@end
