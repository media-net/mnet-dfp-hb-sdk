//
//  MNALViewInfo.h
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MNALViewInfo : NSObject

@property (nonatomic) int viewId;

@property (nonatomic) NSString *resourceName;

@property (nonatomic) NSString *viewClass;

@property (nonatomic) NSString *viewType;

@property (nonatomic) BOOL isScrollable;

@property (nonatomic) BOOL isClickable;

@property (nonatomic) MNALViewInfo *parent;

@property (nonatomic) int startOffset;

@property (nonatomic) int pageCount;

@property (nonatomic) UIView *view;

@property (nonatomic) NSMutableDictionary<NSString *, NSObject *> *properties;

@property (nonatomic) int childOffset;

@property (nonatomic) NSString *viewRectNormalized;

- (NSMutableDictionary *)getJSON;

- (instancetype)initWithView:(UIView *)view viewController:(UIViewController *)controller;

- (UIViewController *)getShadowViewController;

@end
