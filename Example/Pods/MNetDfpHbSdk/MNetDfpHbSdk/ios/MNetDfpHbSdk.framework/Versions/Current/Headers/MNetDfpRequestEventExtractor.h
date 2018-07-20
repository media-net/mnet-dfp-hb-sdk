//
//  MNetDfpRequestEventExtractor.h
//  MNetAdSdk
//
//  Created by nithin.g on 15/02/18.
//

#import "GoogleMobileAds/DFPRequest.h"
#import "MNetBaseAdSdk/MNBaseGeoLocation.h"
#import "MNetBaseAdSdk/MNBaseUser.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class MNetDfpExtractedData;

@interface MNetDfpRequestEventExtractor : NSObject
+ (MNetDfpExtractedData *_Nullable)extractDataFromDfpRequest:(DFPRequest *_Nonnull)dfpRequest;
@end

@interface MNetDfpExtractedData : NSObject
@property (atomic, nullable) CLLocation *location;
@property (atomic, nullable) MNBaseGeoLocation *geoLocation;
@property (atomic, nullable) MNBaseUser *user;
@property (atomic, nullable) NSString *contextLink;

@end
