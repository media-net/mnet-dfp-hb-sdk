//
//  MNBaseAdRequest.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseAdSize.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/// The class that describes the ad request object
@interface MNBaseAdRequest : NSObject

/// Keywords for the ad
@property (atomic, nullable) NSString *keywords;

/// The website link for the current screen. This is for better context.
@property (atomic, nullable) NSString *contextLink;

/// Get a new request object
+ (MNBaseAdRequest *_Nonnull)newRequest;

@end
