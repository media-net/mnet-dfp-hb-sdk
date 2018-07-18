//
//  MNBaseLinkStore.m
//  Pods
//
//  Created by nithin.g on 29/05/17.
//
//

#import "MNBaseLinkStore.h"

@interface MNBaseLinkStore ()
@property (atomic) NSString *appLink;
@end

@implementation MNBaseLinkStore
static MNBaseLinkStore *instance;

+ (instancetype)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
      instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)setLink:(NSString *)link {
    if (link != nil) {
        self.appLink = link;
    }
}

- (NSString *)getLink {
    return self.appLink;
}
@end
