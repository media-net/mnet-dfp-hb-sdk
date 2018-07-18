//
//  MNBaseLocationDataTracker.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "MNBaseGeoLocation.h"

@interface MNBaseLocationDataTracker : NSObject <CLLocationManagerDelegate>

+ (void)startLocationUpdatesWithInterval:(NSTimeInterval)timeInterval;
+ (void)startLocationUpdates;
+ (void)stopLocationUpdates;
+ (MNBaseGeoLocation *)getGeoLocation;

@end
