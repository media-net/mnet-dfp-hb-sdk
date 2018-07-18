//
//  MNALViewClone.m
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import "MNALViewClone.h"
#import "MNALLog.h"
#import "MNALUtils.h"

static NSString *TEXT             = @"text";
static NSString *IS_ADAPTER_CHILD = @"is_adapter_child";

@implementation MNALViewClone

+ (MNALViewClone *)create:(UIView *)view viewController:(UIViewController *)controller {

    MNALViewClone *clone = [[MNALViewClone alloc] init];
    clone.properties     = [[NSMutableDictionary alloc] init];

    [clone setViewInfo:[[MNALViewInfo alloc] initWithView:view viewController:controller]];

    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *) controller;
        [clone.viewInfo setPageCount:(int) [[tabBarVC viewControllers] count]];
        [clone.viewInfo setStartOffset:(int) [tabBarVC selectedIndex]];
    }

    if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *) view;
        if (textView.text != nil) {
            [clone.properties setObject:textView.text forKey:TEXT];
        }
    } else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *) view;
        if (button && button.titleLabel.text != nil) {
            [clone.properties setObject:button.titleLabel.text forKey:TEXT];
        }
    } else if ([view isKindOfClass:[UILabel class]]) {

        UILabel *label = (UILabel *) view;
        if (label.text != nil) {
            [clone.properties setObject:label.text forKey:TEXT];
        }

    } else if ([view isKindOfClass:[UITabBar class]]) {

        UITabBar *tabBar           = (UITabBar *) view;
        [clone viewInfo].pageCount = (int) [[tabBar items] count];

    } else if ([view isKindOfClass:[UITableView class]]) {

        int totalCount         = 0;
        int pageCount          = 0;
        UITableView *tableView = (UITableView *) view;
        totalCount             = (int) [MNALUtils getTotalRowsForView:tableView];

        if (totalCount != 0) {
            [tableView setTag:totalCount];
            pageCount = (int) [tableView tag];
        }

        /*
         Will retun array of NSIndexPath of visible cells
         */
        NSArray *indexPathsForVisibleRows = [tableView indexPathsForVisibleRows];
        NSIndexPath *firstVisibleIndexPath;
        if (indexPathsForVisibleRows && [indexPathsForVisibleRows count] > 0) {
            firstVisibleIndexPath = indexPathsForVisibleRows[0];
            NSInteger startOffset = [MNALUtils getTotalRowsForView:tableView
                                                        forSection:[firstVisibleIndexPath section]
                                                            andRow:[firstVisibleIndexPath row]];
            MNALLinkLog(@"START_OFFSET: interim  : %ld", (long) startOffset);
            if (pageCount != 0) {
                [clone viewInfo].startOffset = (int) ((startOffset / pageCount) * pageCount);
            } else {
                [clone viewInfo].startOffset = 0;
            }
        } else {
            [clone viewInfo].startOffset = 0;
        }

        [clone viewInfo].pageCount = pageCount;

        MNALLinkLog(@"START_OFFSET: startOffset : %d", [clone viewInfo].startOffset);
        MNALLinkLog(@"START_OFFSET: pageOffset  : %d", [clone viewInfo].pageCount);

    } else if ([view isKindOfClass:[UICollectionView class]]) {

        int totalCount                   = 0;
        int pageCount                    = 0;
        UICollectionView *collectionView = (UICollectionView *) view;

        totalCount = (int) [MNALUtils getTotalRowsForView:collectionView];

        if (totalCount != 0) {
            [collectionView setTag:totalCount];
            pageCount = (int) [collectionView tag];
        }

        /*
         will return array of NSIndexPath of visible cells
         */
        NSArray *indexPathsForVisibleRows = [collectionView indexPathsForVisibleItems];
        NSIndexPath *firstVisibleIndexPath;
        if (indexPathsForVisibleRows && [indexPathsForVisibleRows count] > 0) {
            firstVisibleIndexPath = indexPathsForVisibleRows[0];
            NSInteger startOffset = [MNALUtils getTotalRowsForView:collectionView
                                                        forSection:[firstVisibleIndexPath section]
                                                            andRow:[firstVisibleIndexPath row]];
            MNALLinkLog(@"START_OFFSET: interim  : %ld", (long) startOffset);
            if (pageCount != 0) {
                [clone viewInfo].startOffset = (int) ((startOffset / pageCount) * pageCount);
            } else {
                [clone viewInfo].startOffset = 0;
            }
        } else {
            [clone viewInfo].startOffset = 0;
        }

        [clone viewInfo].pageCount = pageCount;

        MNALLinkLog(@"START_OFFSET: startOffset : %d", [clone viewInfo].startOffset);
        MNALLinkLog(@"START_OFFSET: pageOffset  : %d", [clone viewInfo].pageCount);
    }

    [clone.properties setObject:[NSNumber numberWithBool:[MNALUtils isAdapterChild:view viewController:controller]]
                         forKey:IS_ADAPTER_CHILD];

    [[clone viewInfo] setProperties:[clone properties]];

    return clone;
}

@end
