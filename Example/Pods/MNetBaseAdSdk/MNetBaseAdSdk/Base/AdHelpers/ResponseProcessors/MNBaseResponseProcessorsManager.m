//
//  MNBaseResponseProcessorsManager.m
//  Pods
//
//  Created by nithin.g on 07/07/17.
//
//

#import "MNBaseResponseProcessorsManager.h"
#import "MNBaseResponseProcessor.h"
#import "MNBaseResponseProcessorsStore.h"

@interface MNBaseResponseProcessorsManager ()
@property (atomic) NSDictionary *response;
@property (atomic) MNBaseResponseValuesFromRequest *responseExtras;
@end

@implementation MNBaseResponseProcessorsManager

+ (instancetype)getInstanceWithResponse:(NSDictionary *)response
                     withResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    MNBaseResponseProcessorsManager *instance = [[[self class] alloc] init];
    instance.response                         = response;
    instance.responseExtras                   = responseExtras;

    return instance;
}

- (void)processResponse {
    NSArray<id<MNBaseResponseProcessor>> *processorsList =
        [[MNBaseResponseProcessorsStore getSharedInstance] getProcessors];

    for (id<MNBaseResponseProcessor> processor in processorsList) {
        [processor processResponse:self.response withResponseExtras:self.responseExtras];
    }
}

@end
