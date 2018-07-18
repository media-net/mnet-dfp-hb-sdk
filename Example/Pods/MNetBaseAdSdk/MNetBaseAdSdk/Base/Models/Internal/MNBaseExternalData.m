//
//  MNBaseExternalData.m
//  Pods
//
//  Created by nithin.g on 19/04/17.
//
//

#import "MNBaseExternalData.h"
#import "MNBaseUtil.h"

@implementation MNBaseExternalData

- (id)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        if (url) {
            url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        } else {
            url = @"";
        }

        if ([url isEqualToString:@""]) {
            url = [MNBaseUtil getDefaultBundleUrl];
        }

        self.url = url;
    }
    return self;
}

- (id)init {
    return [self initWithUrl:@""];
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

@end
