//
//  MNBaseUser+Internal.h
//  Pods
//
//  Created by nithin.g on 04/08/17.
//
//

#import "MNBaseUser.h"
#import <MNetJSONModeller/MNJMManager.h>

#ifndef MNBaseUser_Internal_h
#define MNBaseUser_Internal_h

@interface MNBaseUser () <MNJMMapperProtocol>

+ (NSDictionary *)getGenderToStrMap;

/// An ID for identifying the user
@property (atomic) NSString *userId;

/// Gender of the user
@property (atomic) NSString *gender;

/// Name of the user
@property (atomic) NSString *name;

/// Year of birth of the user
@property (atomic) NSNumber *birthYear;

/// Comma separated list of keywords, interests, or intent
@property (atomic) NSString *keywords;
@end

#endif /* MNBaseUser_Internal_h */
