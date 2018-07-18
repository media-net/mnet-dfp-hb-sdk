//
//  MNBaseVideoAdRequest.m
//  Pods
//
//  Created by akshay.d on 25/05/17.
//
//

#import "MNBaseVideoAdRequest.h"

@implementation MNBaseVideoAdRequest

+ (MNBaseVideoAdRequest *)newInstance {
    return [[MNBaseVideoAdRequest alloc] init];
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{@"format" : [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNBaseImpFormat class]]};
}

@end
