//
//  MNBaseAdRequest+Internal.h
//  Pods
//
//  Created by nithin.g on 23/06/17.
//
//

#ifndef MNBaseAdRequest_Internal_h
#define MNBaseAdRequest_Internal_h

#import "MNBaseAdRequest.h"
#import "MNBaseGeoLocation.h"
#import "MNBaseUser.h"
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdRequest ()
@property (atomic) NSDictionary<NSString *, NSString *> *extras;
@property (atomic) MNBaseAdSize *size;
@property (atomic) MNBaseGeoLocation *customGeoLocation;
@property (weak, atomic) UIViewController *rootViewController;
@property (atomic) NSString *adUnitId;
@property (atomic) NSString *visitId;
@property (atomic) NSString *adCycleId;
@property (atomic) MNBaseUser *userDetails;
@property (atomic) NSString *viewControllerTitle;

@property (atomic) BOOL isInterstitial;
@property (atomic) BOOL isTest;
@property (atomic) BOOL isInternal;

@property (nonatomic) NSArray<MNBaseAdSize *> *adSizes;
@property (atomic, copy) NSDictionary<NSString *, NSString *> *customExtras;

- (NSDictionary *)addExtraWith:(NSString *)key andValue:(NSString *)value;
- (void)updateContextLink;
- (void)updateVCTitle;

@end

#endif /* MNBaseAdRequest_Internal_h */
