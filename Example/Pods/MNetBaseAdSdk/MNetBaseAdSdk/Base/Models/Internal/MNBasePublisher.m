//
//  MNBasePublisher.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBasePublisher.h"

@implementation MNBasePublisher

- (id)initWithId:(NSString *)publisherId {
    self = [super init];
    if (self) {
        _id = publisherId;
    }
    return self;
}

- (id)init {
    return [self initWithId:@""];
}

- (NSDictionary *)propertyKeyMap {
    return @{@"id" : @"id"};
}
@end
