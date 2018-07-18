//
//  MNBaseAdSizeConstants.m
//  Pods
//
//  Created by nithin.g on 23/06/17.
//
//

#import "MNBaseAdSizeConstants.h"

MNBaseAdSize *MNBaseAdSizeFromCGSize(CGSize size) {
    MNBaseAdSize *adSize = [MNBaseAdSize new];
    adSize.h             = [NSNumber numberWithInteger:size.height];
    adSize.w             = [NSNumber numberWithInteger:size.width];
    return adSize;
}

CGSize MNBaseCGSizeFromAdSize(MNBaseAdSize *adSize) {
    CGFloat width  = 0;
    CGFloat height = 0;
    if (adSize != nil) {
        if (adSize.w != nil) {
            width = [adSize.w floatValue];
        }
        if (adSize.h != nil) {
            height = [adSize.h floatValue];
        }
    }
    return CGSizeMake(width, height);
}
