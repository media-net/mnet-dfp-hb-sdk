//
//  MNBaseAdViewStore.h
//  Pods
//
//  Created by nithin.g on 10/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MNBaseAdViewStore : NSObject

@property (atomic) NSNumber *defaultTtl;

+ (id)getsharedInstance;

- (instancetype)init __attribute__((unavailable("init not available")));
- (BOOL)addViewToStore:(UIView *)adView withKey:(NSString *)key;
- (UIView *)getViewForKey:(NSString *)key;
- (UIView *)popViewForKey:(NSString *)key;

@end

@interface MNBaseAdViewStoreEntry : NSObject
- (instancetype)initWithAdView:(UIView *)adView;
- (UIView *)getView;

@end
