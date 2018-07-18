//
//  MNALSegment.h
//  Pods
//
//  Created by kunal.ch on 15/05/17.
//
//

#import "MNALViewInfo.h"
#import <Foundation/Foundation.h>

@interface MNALSegment : NSObject

@property (nonatomic) NSString *resourceName;
@property (nonatomic) int offset;
@property (nonatomic) int viewId;
@property (nonatomic) int pageCount;
@property (nonatomic) NSMutableDictionary *contentMap;

- (instancetype)initWithViewInfo:(MNALViewInfo *)viewInfo;
- (NSString *)getContentsForSegmentAtIndex:(int)index;

@end
