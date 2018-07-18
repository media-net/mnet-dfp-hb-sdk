//
//  MNALViewInfo.m
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import "MNALViewInfo.h"
#import "MNALConstants.h"
#import "MNALUtils.h"

@interface MNALViewInfo ()
@property (nonatomic) UIViewController *viewController;
@end

@implementation MNALViewInfo

- (instancetype)initWithView:(UIView *)view viewController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.view           = [[UIView alloc] init];
        self.view           = view;
        self.viewController = controller;
        self.viewClass      = NSStringFromClass(view.class);

        [self processViewForDetails:view];
    }
    return self;
}

- (UIViewController *)getShadowViewController {
    return self.viewController;
}

- (void)processViewForDetails:(UIView *)view {
    self.childOffset = -1;
    if ([view isKindOfClass:[UITabBar class]]) {
        self.childOffset = 0;
    }

    // Get the position of the view as compared to the screen
    CGRect viewPosInWindow = [view convertRect:view.bounds toView:nil];
    NSNumber *x            = [MNALUtils getNormalizedDimension:viewPosInWindow.origin.x isWidth:YES];
    NSNumber *y            = [MNALUtils getNormalizedDimension:viewPosInWindow.origin.y isWidth:NO];
    NSNumber *w            = [MNALUtils getNormalizedDimension:view.bounds.size.width isWidth:NO];
    NSNumber *h            = [MNALUtils getNormalizedDimension:view.bounds.size.height isWidth:NO];

    NSString *fmtSizeStr =
        [NSString stringWithFormat:@"x:%d,y:%d,w:%d,h:%d", [x intValue], [y intValue], [w intValue], [h intValue]];
    self.viewRectNormalized = fmtSizeStr;

    if ([view isKindOfClass:[UITableView class]] ||

        [view isKindOfClass:[UICollectionView class]] ||

        [view isKindOfClass:[UIScrollView class]]) {

        self.isScrollable = YES;
        self.childOffset  = 0;
    }

    if ([view isKindOfClass:[UIScrollView class]]) {
        self.isClickable = NO;
    }

    if ([view isKindOfClass:[UIButton class]]) {
        self.isClickable = YES;
    }

    NSArray *gestures = [view gestureRecognizers];

    for (UIGestureRecognizer *gesture in gestures) {

        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            self.isClickable = YES;
        }
    }

    self.viewClass    = NSStringFromClass(view.class);
    self.viewType     = NSStringFromClass(view.class);
    self.resourceName = [MNALUtils getResourceNameForView:view withId:(int) _viewId];
}

- (NSMutableDictionary *)getJSON {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];

    [jsonObject setObject:[NSNumber numberWithInt:_viewId] forKey:MNAL_VIEW_ID];
    [jsonObject setObject:self.viewClass forKey:MNAL_VIEW_CLASS];
    [jsonObject setObject:self.viewType forKey:MNAL_VIEW_TYPE];
    [jsonObject setObject:[NSNumber numberWithBool:_isScrollable] forKey:MNAL_SCROLLABLE];
    [jsonObject setObject:[NSNumber numberWithBool:self.isClickable] forKey:MNAL_CLICKABLE];
    [jsonObject setObject:self.properties forKey:MNAL_PROPERTIES];
    [jsonObject setObject:self.resourceName forKey:MNAL_RESOURCE_NAME];
    [jsonObject setObject:[NSNumber numberWithInt:self.childOffset] forKey:MNAL_CHILD_OFFSET];

    if (self.parent != nil) {
        NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
        [parent setObject:self.viewClass forKey:MNAL_VIEW_CLASS];
        // Not a typo, setting viewClass to view_type.
        [parent setObject:self.viewClass forKey:MNAL_VIEW_TYPE];
        [parent setObject:[NSNumber numberWithInt:[self.parent viewId]] forKey:MNAL_VIEW_ID];
        [parent setObject:self.resourceName forKey:MNAL_RESOURCE_NAME];
        [jsonObject setObject:parent forKey:MNAL_PARENT];
    }
    [jsonObject setObject:[NSNumber numberWithInt:self.pageCount] forKey:MNAL_PAGE_COUNT];
    [jsonObject setObject:[NSNumber numberWithInt:self.startOffset] forKey:MNAL_START_OFFSET];
    [jsonObject setObject:self.self.viewRectNormalized forKey:MNAL_VIEW_RECT_NORMALIZED];

    return jsonObject;
}

@end
