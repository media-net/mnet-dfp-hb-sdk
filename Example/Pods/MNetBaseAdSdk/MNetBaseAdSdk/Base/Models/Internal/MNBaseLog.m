//
//  MNBaseLog.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseLog.h"

@implementation MNBaseLog

- (id)initWith:(NSString *)tag message:(NSString *)message {
    return [self initWith:tag message:message error:@""];
}

- (id)initWith:(NSString *)tag message:(NSString *)message error:(NSString *)error {
    self = [super init];
    if (self) {
        _tag     = tag;
        _message = message;
        _error   = error;
    }
    return self;
}

- (id)init {
    return [self initWith:@"" message:@"" error:@""];
}

- (NSDictionary *)propertyKeyMap {
    return @{@"tag" : @"tag", @"message" : @"message", @"error" : @"error"};
}

@end
