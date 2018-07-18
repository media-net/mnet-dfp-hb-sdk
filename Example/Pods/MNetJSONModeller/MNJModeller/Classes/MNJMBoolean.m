//
//  MNJMBoolean.m
//  Pods
//
//  Created by nithin.g on 23/05/17.
//
//

#import "MNJMBoolean.h"

@implementation MNJMBoolean {
    NSNumber *boolValue;
}

+ (instancetype)createWithBool:(BOOL)boolVal {
    MNJMBoolean *boolObj = [[[self class] alloc] init];
    [boolObj setBool:boolVal];
    return boolObj;
}

- (id)init {
    self      = [super init];
    boolValue = [NSNumber numberWithBool:NO];
    return self;
}

- (void)setBool:(BOOL)boolVal {
    boolValue = [NSNumber numberWithBool:boolVal];
}

- (BOOL)isYes {
    return (boolValue == [NSNumber numberWithBool:YES]);
}

@end
