//
//  MNBaseLocationDataTracker.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

#import "MNBase.h"
#import "MNBaseConstants.h"
#import "MNBaseGeoLocation.h"
#import "MNBaseLocationDataTracker.h"
#import "MNBaseLogger.h"
#import "MNBasePulseTracker.h"
#import "MNBaseSdkConfig.h"
#import "MNBaseUtil.h"
#import "MNBaseWeakTimerTarget.h"

@interface MNBaseLocationDataTracker ()

@property (atomic) CLLocation *currentLocation;
@property (atomic) MNBaseGeoLocation *currentGeoLocation;

@property (atomic) CLLocationManager *locationManager;
@property (atomic) BOOL isLocationUpdateManuallyStopped;
@property (atomic) BOOL isFetchingLocation;
@property (atomic) BOOL isTimerScheduled;

@end

@implementation MNBaseLocationDataTracker

static MNBaseLocationDataTracker *instance;
static NSTimeInterval updateInterval;

- (id)init {
    self                 = [super init];
    self.currentLocation = nil;

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];

    return self;
}

#pragma mark - Public methods

+ (void)startLocationUpdatesWithInterval:(NSTimeInterval)timeInterval {
    updateInterval = timeInterval;
    [[self class] startLocationUpdates];
}

+ (void)startLocationUpdates {
    void (^locationUpdateBlock)(void) = ^{
      @try {
          MNLogD(@"Starting Location updates");
          MNBaseLocationDataTracker *locationObj      = [[self class] getInstance];
          locationObj.isLocationUpdateManuallyStopped = NO;
          [locationObj updateLocation];
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - startLocationUpdates %@", e);
      }
    };

    // NOTE: This check is not done to check for dead-locks (as is the case with dispatch_sync).
    // This is just to make sure that the location updates start as soon as possible and not be scheduled later on
    // (main-threads can be really busy sometimes)
    if ([NSThread isMainThread]) {
        locationUpdateBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), locationUpdateBlock);
    }
}

+ (void)stopLocationUpdates {
    void (^stopLocationUpdateBlock)(void) = ^{
      @try {
          MNLogD(@"Stopping Location updates");
          MNBaseLocationDataTracker *locationObj      = [[self class] getInstance];
          locationObj.isLocationUpdateManuallyStopped = YES;
      } @catch (NSException *e) {
          MNLogE(@"EXCEPTION - stopLocationUpdates %@", e);
      }
    };

    if ([NSThread isMainThread]) {
        stopLocationUpdateBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), stopLocationUpdateBlock);
    }
}

+ (MNBaseGeoLocation *)getGeoLocation {
    return [[[self class] getInstance] currentGeoLocation];
}

+ (id)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance       = [[MNBaseLocationDataTracker alloc] init];
      updateInterval = [[[MNBaseSdkConfig getInstance] getLocationUpdateInterval] doubleValue];
    });

    return instance;
}

#pragma mark - Location helpers

- (CLLocation *)fetchBestFromLocations:(NSArray<CLLocation *> *)locationsArr {
    // Pick the best location from the array
    // Not using verticalAccuracy right now.
    CLLocation *bestLocation = nil;
    for (CLLocation *location in locationsArr) {
        if (location && location.horizontalAccuracy > 0) {
            if (!bestLocation) {
                bestLocation = location;
            } else {
                // NOTE: less the accuracy, lower the error.
                // Hence, lower accuracy is better, but -1 is illegal
                if (location.horizontalAccuracy < bestLocation.horizontalAccuracy) {
                    bestLocation = location;
                }
            }
        }
    }

    // Make sure that the selected location is the latest.
    if (bestLocation && bestLocation.timestamp > self.currentLocation.timestamp) {
        return bestLocation;
    }

    return nil;
}

- (void)updateGeoLocation {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.currentLocation
                   completionHandler:^(NSArray *placemarksArr, NSError *error) {
                     if (error != nil) {
                         MNLogD(@"Error in reverse geocode location");
                         MNLogD(@"Error - %@", error);
                         return;
                     }

                     self.currentGeoLocation =
                         [MNBaseUtil mapPlacemarkToGeoLocation:placemarksArr withCurrentLocation:self.currentLocation];
                     MNLogD(@"LOC_DATA: Got a new location.");
                     [MNBasePulseTracker logRemoteCustomEventType:MNBasePulseEventLocation
                                                    andCustomData:self.currentGeoLocation];
                   }];
}

- (BOOL)checkIfUpdateIsEnabled {
    BOOL isLocationUpdateEnabled = NO;

    if ([CLLocationManager locationServicesEnabled]) {
        isLocationUpdateEnabled = [self checkLocationAuthFromStatus:[CLLocationManager authorizationStatus]];
    }

    return isLocationUpdateEnabled;
}

- (BOOL)checkLocationAuthFromStatus:(CLAuthorizationStatus)status {
    BOOL isUpdatable;
    switch (status) {
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        isUpdatable = YES;
        break;
    default:
        MNLogD(@"authorizationStatus - %d", [CLLocationManager authorizationStatus]);
        isUpdatable = NO;
    }

    return isUpdatable;
}

#pragma mark - Timer logic

- (void)updateLocation {
    if ([self checkIfUpdateIsEnabled] && !self.isLocationUpdateManuallyStopped &&
        [[MNBase getInstance] appContainsChildDirectedContent] == NO) {
        MNLogD(@"LOC_DATA: Updating location");

        [self.locationManager startUpdatingLocation];
        self.isFetchingLocation = YES;
    } else {
        MNLogD(@"LOC_DATA: Not updating location since it's disabled");
    }
}

// Called by didUpdateLocations after it is complete
- (void)updateFinishedCallback {
    [self schedulePeriodicLocationUpdates];
}

- (void)schedulePeriodicLocationUpdates {
    // This synchronized block is because of an issue with CLLocationManager.
    // stopUpdatingLocation never stops sending locations. It keeps sending them repeatedly
    // http://stackoverflow.com/q/30330757/1518924

    // This block makes sure timer is not called multiple times
    @synchronized(self) {
        if (self.isTimerScheduled || ![self checkIfUpdateIsEnabled] || self.isLocationUpdateManuallyStopped) {
            return;
        }
        self.isTimerScheduled = YES;
    }

    MNLogD(@"LOC_DATA: Starting timer");
    MNBaseWeakTimerTarget *timerTarget = [[MNBaseWeakTimerTarget alloc] init];
    [timerTarget setTarget:self];
    [timerTarget setSelector:NSSelectorFromString(@"timerCallback:")];

    [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                     target:timerTarget
                                   selector:timerTarget.timerFireTargetSelector
                                   userInfo:nil
                                    repeats:NO];
}

- (void)timerCallback:(NSTimer *)timer {
    // Destroying the timer at every instance
    [timer invalidate];
    timer = nil;

    self.isFetchingLocation = NO;
    self.isTimerScheduled   = NO;

    if (self) {
        [self updateLocation];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];

    CLLocation *bestLocation = [self fetchBestFromLocations:locations];
    if (bestLocation) {
        self.currentLocation = bestLocation;
        [self updateGeoLocation];
    }

    [self updateFinishedCallback];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    MNLogRemote(@"Location manager has failed to fetch the location - %@", error);

    // Write as a warning
    [self updateFinishedCallback];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    MNLogD(@"Location AuthorizeChangedstatus - %d", status);

    if (![self checkLocationAuthFromStatus:status]) {
        self.currentLocation    = nil;
        self.currentGeoLocation = nil;
    }

    if (!self.isFetchingLocation) {
        [self updateLocation];
    }
}

@end
