//
//  MNBaseResponseTransformerManager.m
//  Pods
//
//  Created by nithin.g on 17/09/17.
//
//

#import "MNBaseResponseTransformerManager.h"
#import "MNBaseResponseTransformerStore.h"

@interface MNBaseResponseTransformerManager ()
@property (atomic) NSMutableArray<MNBaseBidResponse *> *bidResponseArr;
@property (atomic) NSDictionary *originalResponseDict;
@property (atomic) MNBaseResponseValuesFromRequest *responseExtras;
@end

@implementation MNBaseResponseTransformerManager

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [[MNBaseResponseTransformerStore getSharedInstance] intializeTransformers];
    });
}

+ (instancetype)getInstanceWithBidResponseArr:(NSMutableArray<MNBaseBidResponse *> *)bidResponseArr
                         withOriginalResponse:(NSDictionary *)originalResponseDict
                            andResponseExtras:(MNBaseResponseValuesFromRequest *)responseExtras {
    if (bidResponseArr == nil || originalResponseDict == nil) {
        return nil;
    }

    MNBaseResponseTransformerManager *instance = [[MNBaseResponseTransformerManager alloc] init];
    instance.bidResponseArr                    = bidResponseArr;
    instance.originalResponseDict              = originalResponseDict;
    instance.responseExtras                    = responseExtras;

    return instance;
}

- (NSMutableArray<MNBaseBidResponse *> *)transformResponse {
    NSArray<id<MNBaseResponseTransformer>> *transformersList =
        [[MNBaseResponseTransformerStore getSharedInstance] getTransformers];

    for (id transformer in transformersList) {
        self.bidResponseArr = [transformer transformBidResponseArr:self.bidResponseArr
                                              withOriginalResponse:self.originalResponseDict
                                                 andResponseExtras:self.responseExtras];
    }
    return self.bidResponseArr;
}

@end
