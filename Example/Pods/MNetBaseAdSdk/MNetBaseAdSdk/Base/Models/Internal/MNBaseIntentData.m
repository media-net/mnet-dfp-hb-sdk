//
//  MNBaseIntentData.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseIntentData.h"
#import "MNBaseExternalData.h"
#import "MNBaseLinkStore.h"

@implementation MNBaseIntentData

- (id)init {
    return [self initWithURI:@""];
}

- (id)initWithURI:(NSString *)uri {
    return [self initWithURI:uri AndExtUrl:[[MNBaseLinkStore getSharedInstance] getLink]];
}

- (id)initWithExtUrl:(NSString *)extUrl {
    return [self initWithURI:@"" AndExtUrl:extUrl];
}

- (id)initWithURI:(NSString *)uri AndExtUrl:(NSString *)extUrl {
    self = [super init];
    if (self) {
        self.uri          = uri;
        self.externalData = [[MNBaseExternalData alloc] initWithUrl:extUrl];
    }
    return self;
}

- (NSDictionary *)propertyKeyMap {
    return @{@"uri" : @"url", @"externalData" : @"ext"};
}

@end
