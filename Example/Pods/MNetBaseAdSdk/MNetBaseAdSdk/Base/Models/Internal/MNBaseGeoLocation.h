//
//  MNBaseGeoLocation.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseGeoLocation : NSObject <MNJMMapperProtocol>

#define SOURCE_GPS 1;
#define SOURCE_IP 2;
#define SOURCE_USER_PROVIDED 3;

@property (atomic) double latitude;

@property (atomic) double longitude;

// 1 GPS/Location Services
// 2 IP Address
// 3 User provided (e.g., registration data)

@property (atomic) int locationSource;

@property (atomic) double offset;

@property (atomic) NSString *timezone;

@property (atomic) NSString *country;

@property (atomic) NSString *region;

@property (atomic) NSString *city;

@property (atomic) NSString *zipCode;

@property (atomic) int accuracy;

+ (MNBaseGeoLocation *)newInstance;

@end
