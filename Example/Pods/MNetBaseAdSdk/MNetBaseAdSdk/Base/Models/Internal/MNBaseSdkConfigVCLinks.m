//
//  MNBaseSdkConfigVCLinks.m
//  Pods
//
//  Created by nithin.g on 07/08/17.
//
//

#import "MNBaseSdkConfigVCLinks.h"

@implementation MNBaseSdkConfigVCLinks

- (NSDictionary *)propertyKeyMap {
    return @{@"isEnabled" : @"enabled"};
}

- (NSDictionary<NSString *, MNJMCollectionsInfo *> *)collectionDetailsMap {
    return @{
        @"linkMap" :
            [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSString class] andValueType:[NSString class]],
    };
}
@end
