//
//  MNBaseResponseProcessorsStore.m
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseProcessorsStore.h"
#import "MNBaseResponseProcessorCrawlingDetails.h"
#import "MNBaseResponseProcessorTimingDetails.h"

@interface MNBaseResponseProcessorsStore ()
@property (atomic) NSArray<id<MNBaseResponseProcessor>> *processorsList;
@end

@implementation MNBaseResponseProcessorsStore
static MNBaseResponseProcessorsStore *instance;

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[MNBaseResponseProcessorsStore alloc] init];
      NSMutableArray<id<MNBaseResponseProcessor>> *processorsList =
          [[NSMutableArray<id<MNBaseResponseProcessor>> alloc] init];
      [processorsList addObject:[MNBaseResponseProcessorTimingDetails new]];
      [processorsList addObject:[MNBaseResponseProcessorCrawlingDetails new]];
      instance.processorsList = processorsList;
    });
    return instance;
}

- (instancetype)init {
    self            = [super init];
    _processorsList = [[NSArray<id<MNBaseResponseProcessor>> alloc] init];

    return self;
}

- (NSArray<id<MNBaseResponseProcessor>> *)getProcessors {
    return self.processorsList;
}

@end
