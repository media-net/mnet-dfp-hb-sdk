//
//  MNetGridPositioning.h
//  Pods
//
//  Created by nithin.g on 17/07/17.
//
//

#import <Foundation/Foundation.h>
#define GRID_LEFT @"left"
#define GRID_RIGHT @"right"
#define GRID_TOP @"top"
#define GRID_BOTTOM @"bottom"
#define GRID_CENTER @"center"

@interface MNetGridPositioning : NSObject
+ (NSString *)getGridPositionForView:(UIView *)view;

@end
