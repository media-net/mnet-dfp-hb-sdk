//
//  MNBaseResponseTransformerStore.m
//  Pods
//
//  Created by nithin.g on 12/06/17.
//
//

#import "MNBaseResponseTransformerStore.h"
#import "MNBaseResponseTransformer.h"
#import "MNBaseResponseTransformerExtensions.h"
#import "MNBaseResponseTransformerRequestProps.h"

@interface MNBaseResponseTransformerStore ()
@property NSMutableArray<id<MNBaseResponseTransformer>> *transformersList;
@end

@implementation MNBaseResponseTransformerStore
static MNBaseResponseTransformerStore *instance;
static dispatch_once_t onceToken;
static NSArray<id<MNBaseResponseTransformer>> *defaultTransformersList;

+ (instancetype)getSharedInstance {
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseResponseTransformerStore alloc] init];

      NSMutableArray<id<MNBaseResponseTransformer>> *transformersList =
          [[NSMutableArray<id<MNBaseResponseTransformer>> alloc] init];

      // Add all the default transformers here
      [transformersList addObject:[MNBaseResponseTransformerRequestProps new]];
      [transformersList addObject:[MNBaseResponseTransformerExtensions new]];

      defaultTransformersList = [NSArray arrayWithArray:transformersList];
    });
    return instance;
}

- (void)intializeTransformers {
    NSArray *transformersObjList = defaultTransformersList;
    self.transformersList =
        [[NSMutableArray<id<MNBaseResponseTransformer>> alloc] initWithCapacity:[transformersObjList count]];
    for (id<MNBaseResponseTransformer> transformer in transformersObjList) {
        if (transformer) {
            [self registerTransformer:transformer];
        }
    }
}

- (BOOL)registerTransformer:(id<MNBaseResponseTransformer>)transformer {
    if (transformer && [transformer conformsToProtocol:@protocol(MNBaseResponseTransformer)]) {
        [self.transformersList addObject:transformer];
        return YES;
    }
    return NO;
}

- (NSArray<id<MNBaseResponseTransformer>> *)getTransformers {
    NSArray<id<MNBaseResponseTransformer>> *transformers;
    if (self.transformersList) {
        transformers = [NSArray<id<MNBaseResponseTransformer>> arrayWithArray:self.transformersList];
    }

    return transformers;
}

@end
