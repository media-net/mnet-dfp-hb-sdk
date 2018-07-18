//
//  MNBaseCustomTargets.m
//  MNBaseAdSdk
//
//  Created by kunal.ch on 08/01/18.
//

#import "MNBaseCustomTargets.h"
#define PREFIX_VAL @"in-app"

@implementation MNBaseCustomTargets

- (BOOL)containsInAppPrefix {
    return self.prefix != nil && ([self.prefix caseInsensitiveCompare:PREFIX_VAL] == NSOrderedSame);
}

@end
