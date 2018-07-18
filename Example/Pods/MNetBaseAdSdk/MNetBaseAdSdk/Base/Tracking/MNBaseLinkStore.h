//
//  MNBaseLinkStore.h
//  Pods
//
//  Created by nithin.g on 29/05/17.
//
//

#import <Foundation/Foundation.h>

/// Whenever a link is created, it's stored here
@interface MNBaseLinkStore : NSObject

+ (instancetype)getSharedInstance;
- (void)setLink:(NSString *)link;
- (NSString *)getLink;

@end
