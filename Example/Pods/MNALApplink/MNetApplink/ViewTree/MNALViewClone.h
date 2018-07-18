//
//  MNALViewClone.h
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import "MNALViewInfo.h"
#import <Foundation/Foundation.h>

@interface MNALViewClone : NSObject

@property (nonatomic) MNALViewInfo *viewInfo;

@property (nonatomic) NSMutableDictionary<NSString *, NSObject *> *properties;

+ (MNALViewClone *)create:(UIView *)view viewController:(UIViewController *)controller;

@end
