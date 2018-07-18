//
//  MNALSegment.m
//  Pods
//
//  Created by kunal.ch on 15/05/17.
//
//

#import "MNALSegment.h"
#import "MNALConstants.h"

@implementation MNALSegment

- (instancetype)initWithViewInfo:(MNALViewInfo *)viewInfo {
    self = [super init];
    if (self) {
        _resourceName = viewInfo.resourceName;
        _offset       = viewInfo.startOffset;
        _viewId       = viewInfo.viewId;
        _pageCount    = viewInfo.pageCount;
    }
    return self;
}

- (NSMutableDictionary *)contentMap {
    NSMutableDictionary *contentObj = [[NSMutableDictionary alloc] init];
    if (_resourceName != nil) {
        [contentObj setObject:_resourceName forKey:MNAL_RESOURCE_NAME];
    }
    [contentObj setObject:[NSNumber numberWithInt:_offset] forKey:MNAL_START_OFFSET];
    [contentObj setObject:[NSNumber numberWithInt:_pageCount] forKey:MNAL_PAGE_COUNT];
    [contentObj setObject:[NSNumber numberWithInt:_viewId] forKey:MNAL_VIEW_ID];
    return contentObj;
}

- (NSString *)getContentsForSegmentAtIndex:(int)index {

    NSString *base          = [NSString stringWithFormat:@"s[%d]", index];
    NSString *stringBuilder = @"";
    stringBuilder           = [stringBuilder stringByAppendingString:base];
    stringBuilder           = [stringBuilder stringByAppendingString:@".r="];
    stringBuilder           = [stringBuilder stringByAppendingString:_resourceName];
    stringBuilder           = [stringBuilder stringByAppendingString:@"&"];
    stringBuilder           = [stringBuilder stringByAppendingString:base];
    stringBuilder           = [stringBuilder stringByAppendingString:@".id="];
    stringBuilder           = [stringBuilder stringByAppendingString:[NSString stringWithFormat:@"%d", _viewId]];
    stringBuilder           = [stringBuilder stringByAppendingString:@"&"];
    stringBuilder           = [stringBuilder stringByAppendingString:base];
    stringBuilder           = [stringBuilder stringByAppendingString:@".of="];
    stringBuilder           = [stringBuilder stringByAppendingString:[NSString stringWithFormat:@"%d", _offset]];
    return stringBuilder;
}
@end
