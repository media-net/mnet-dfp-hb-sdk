//
//  MNALViewTree.h
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import "MNALViewClone.h"
#import "MNALViewInfo.h"
#import <Foundation/Foundation.h>

@interface MNALViewTree : NSObject

@property (nonatomic) NSMutableDictionary<NSString *, MNALViewClone *> *nodeMap;

/// All the clickables in the VC
@property (nonatomic) NSMutableArray<MNALViewInfo *> *clickables;

/// Only the clickables which pertain to list views (tableView, collectionView)
@property (nonatomic) NSMutableArray<MNALViewInfo *> *listViewClickables;

/// Only the clickables which are not part of the list view
@property (nonatomic) NSMutableArray<MNALViewInfo *> *nonListViewClickables;

@property (nonatomic) NSMutableDictionary *jsonViewTree;
@property (nonatomic) NSString *uniqueSegmentLink;
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *contentHash;
@property (nonatomic) NSString *screenName;
@property (nonatomic) NSMutableArray *webContents;
@property (nonatomic) NSString *screenshotLink;
@property (nonatomic) NSArray *dominantColors;
@property (nonatomic) NSString *versionCode;
@property (nonatomic) BOOL isDominantWebview;
@property (nonatomic) NSString *dominantWebviewUrl;
@property (nonatomic) NSMutableArray *secondaryLinks;
@property (nonatomic) BOOL isFirstScreen;

- (instancetype)initWithViewController:(UIViewController *)controller withContentEnabled:(BOOL)shouldFetchContent;
- (NSMutableArray *)getSegments;
- (UIViewController *)getViewController;
- (NSString *)getViewTreeLink;

@end
