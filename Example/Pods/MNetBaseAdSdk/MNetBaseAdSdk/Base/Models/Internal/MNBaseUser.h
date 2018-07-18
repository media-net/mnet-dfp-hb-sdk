//
//  MNBaseUser.h
//  Pods
//
//  Created by nithin.g on 04/08/17.
//
//

#import <Foundation/Foundation.h>

typedef enum { MNBaseGenderOther, MNBaseGenderMale, MNBaseGenderFemale } MNBaseUserGender;

@interface MNBaseUser : NSObject

/// An ID for identifying the user
- (void)addUserId:(NSString *_Nonnull)userId;

/// Gender of the user.
- (void)addGender:(MNBaseUserGender)gender;

/// Name of the user
- (void)addName:(NSString *_Nullable)name;

/// Year of birth of the user. The string MUST be 4 digits indicating a valid year of birth
- (BOOL)addYearOfBirth:(NSString *_Nullable)yob;

/// Comma separated list of keywords, user-interests or intent
- (void)addKeywords:(NSString *_Nullable)keywords;

@end
