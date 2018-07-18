//
//  MNBaseUser.m
//  Pods
//
//  Created by nithin.g on 04/08/17.
//
//

#import "MNBaseUser+Internal.h"
#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@implementation MNBaseUser
static NSDictionary *genderToStrMap;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      genderToStrMap =
          @{ENUM_VAL(MNBaseGenderMale) : @"M", ENUM_VAL(MNBaseGenderFemale) : @"F", ENUM_VAL(MNBaseGenderOther) : @"O"};
    });
}

+ (NSDictionary *)getGenderToStrMap {
    return genderToStrMap;
}

/// An ID for identifying the user
- (void)addUserId:(NSString *)userId {
    self.userId = userId;
}

/// Gender of the user.
- (void)addGender:(MNBaseUserGender)gender {
    self.gender = [genderToStrMap objectForKey:ENUM_VAL(gender)];
}

/// Name of the user
- (void)addName:(NSString *)name {
    self.name = name;
}

/// Year of birth of the user
- (BOOL)addYearOfBirth:(NSString *)yob {
    if (yob == nil) {
        return NO;
    }

    // Validate the yob string
    // The string MUST be 4 digits
    int expectedStrLen = 4;
    if ([yob length] != expectedStrLen) {
        return NO;
    }

    NSCharacterSet *notDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([yob rangeOfCharacterFromSet:notDigitsSet].location != NSNotFound) {
        return NO;
    }

    // A valid year of birth is ->
    // between current Year and 200(cutOffAge) years before it
    // 200 because, who knows. Somebody might live that long :p
    NSInteger cutOffAge    = 200;
    NSInteger birthYearInt = [yob integerValue];

    // Get the current year
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatter stringFromDate:[NSDate date]];
    NSInteger currentYearInt    = [currentYearString integerValue];

    // Get the starting year
    NSInteger startingYearInt = currentYearInt - cutOffAge;

    if (birthYearInt >= startingYearInt && birthYearInt <= currentYearInt) {
        self.birthYear = [NSNumber numberWithInteger:birthYearInt];
        return YES;
    }

    return NO;
}

/// Comma separated list of keywords, user-interests or intent
- (void)addKeywords:(NSString *)keywords {
    self.keywords = keywords;
}

- (NSString *)description {
    NSString *defaultEmpty = @"<EMPTY>";
    NSString *__userId     = (self.userId != nil) ? self.userId : defaultEmpty;
    NSString *__gender     = (self.gender != nil) ? self.gender : defaultEmpty;
    NSString *__name       = (self.name != nil) ? self.name : defaultEmpty;
    NSString *__birthYear  = (self.birthYear != nil) ? [self.birthYear stringValue] : defaultEmpty;
    NSString *__keywords   = (self.keywords != nil) ? self.keywords : defaultEmpty;

    return [NSString stringWithFormat:@"USER_ID:\"%@\", GENDER:\"%@\", NAME:\"%@\", YOB:\"%@\" KEYWORDS:\"%@\"",
                                      __userId, __gender, __name, __birthYear, __keywords];
}

- (NSDictionary *)propertyKeyMap {
    return @{@"userId" : @"id", @"birthYear" : @"yob"};
}

@end
