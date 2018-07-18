//
//  MNBaseAddSize.m
//  Pods
//
//  Created by akshay.d on 20/02/17.
//
//

#import "MNBaseAdSize.h"
#import <MNetJSONModeller/MNJMManager.h>

@interface MNBaseAdSize () <MNJMMapperProtocol>

@end

@implementation MNBaseAdSize

+ (instancetype)createAdSizeWithWidth:(NSUInteger)width andHeight:(NSInteger)height {
    MNBaseAdSize *instance = [MNBaseAdSize new];
    if (instance) {
        [instance setW:[NSNumber numberWithInteger:width]];
        [instance setH:[NSNumber numberWithInteger:height]];
    }
    return instance;
}

- (NSDictionary *)propertyKeyMap {
    return @{};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"width: %@, height: %@", (self.w != nil) ? [self.w stringValue] : @"",
                                      (self.h != nil) ? [self.h stringValue] : @""];
}

@end

extern MNBaseAdSize *_Nullable MNBaseCreateAdSize(NSInteger width, NSInteger height) {
    return [MNBaseAdSize createAdSizeWithWidth:width andHeight:height];
}
