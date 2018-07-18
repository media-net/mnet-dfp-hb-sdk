//
//  MNBaseGeoLocation.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseGeoLocation.h"
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseGeoLocation () <MNJMMapperProtocol>

@end

@implementation MNBaseGeoLocation

+ (MNBaseGeoLocation *)newInstance {

    MNBaseGeoLocation *geoLocation = [[MNBaseGeoLocation alloc] init];
    return geoLocation;
}

- (NSDictionary *)propertyKeyMap {
    return @{

        @"latitude" : @"lat",
        @"longitude" : @"lon",
        @"locationSource" : @"type",
        @"offset" : @"utcoffset",
        @"country" : @"country",
        @"region" : @"region",
        @"city" : @"city",
        @"zipCode" : @"zip"
    };
}
@end
