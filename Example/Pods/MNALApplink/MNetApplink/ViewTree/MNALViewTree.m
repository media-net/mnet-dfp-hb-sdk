//
//  MNALViewTree.m
//  Pods
//
//  Created by kunal.ch on 11/05/17.
//
//

#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#import "MNALAppLink+Internal.h"
#import "MNALConstants.h"
#import "MNALLog.h"
#import "MNALSegment.h"
#import "MNALUtils.h"
#import "MNALViewInfo.h"
#import "MNALViewTree.h"
#import "MNALWKWebViewURLStore.h"
#import "NSString+MNALStringCrypto.h"

@interface MNALViewTree ()

@property (nonatomic) int idCounter;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSString *> *fontTextMap;
@property (nonatomic) UIViewController *shadowViewController;
@property (nonatomic) NSString *plainText;
@property (nonatomic) BOOL shouldFetchContent;
@property (nonatomic) NSArray *intentSkipList;
@property (nonatomic) NSInteger contentLimit;
@property (nonatomic) BOOL isTitleEnabled;
@end

@implementation MNALViewTree

static const CGFloat kAreaMajorityPercentage = 0.7;
static const char *kAssociatedObjectKey;

- (instancetype)initWithViewController:(UIViewController *)controller
                    withContentEnabled:(BOOL)shouldFetchContent
                    withIntentSkipList:(NSArray *)skipList
                          contentLimit:(NSInteger)contentLimit
                          titleEnabled:(BOOL)titleEnabled {

    self                 = [super init];
    kAssociatedObjectKey = [UNIQUE_VALUE_KEY_NAME UTF8String];

    if (self) {
        _shouldFetchContent = shouldFetchContent;
        _uniqueSegmentLink  = @"";
        _content            = @"";
        _plainText          = @"";
        _isDominantWebview  = NO;
        self.screenName     = NSStringFromClass([controller class]);
        self.versionCode    = [MNALUtils getAppVersionStr];

        [self appendHTMLHeadersInContent:controller];

        _fontTextMap = [[NSMutableDictionary alloc] init];

        _nodeMap = [[NSMutableDictionary alloc] init];

        _jsonViewTree = [[NSMutableDictionary alloc] init];

        _shadowViewController = controller;

        _clickables            = [[NSMutableArray alloc] init];
        _nonListViewClickables = [[NSMutableArray alloc] init];
        _listViewClickables    = [[NSMutableArray alloc] init];

        _webContents = [[NSMutableArray alloc] init];

        _secondaryLinks = [[NSMutableArray alloc] init];

        _intentSkipList = skipList;

        _contentLimit = contentLimit;

        _isTitleEnabled = titleEnabled;

        NSMutableArray *children = [[NSMutableArray alloc] init];
        UIView *rootView         = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
        if (rootView != nil) {
            MNALViewInfo *rootViewInfo = [[MNALViewClone create:rootView viewController:controller] viewInfo];
            _idCounter                 = 0;
            rootViewInfo.viewId        = _idCounter;

            [self addTabBarToTree];
            [self generateTree:controller.view viewInfo:rootViewInfo viewController:controller children:children];
            [_jsonViewTree setObject:[rootViewInfo getJSON] forKey:MNAL_PARENT];
            [_jsonViewTree setObject:children forKey:MNAL_CHILD];

            NSMutableArray *segmentsList = [self getSegments];
            if (segmentsList != nil && [segmentsList count] > 0) {
                [_jsonViewTree setObject:segmentsList forKey:MNAL_SEGMENTS];
            }

            NSError *error;
            NSData *jsonData =
                [NSJSONSerialization dataWithJSONObject:_jsonViewTree options:NSJSONWritingPrettyPrinted error:&error];
            if (error != nil) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                MNALLinkLog(@"the parsed dictionary for viewController : %@ is %@", NSStringFromClass(controller.class),
                            jsonString);
            }
        }
    }
    [self processContent];
    return self;
}

- (void)addTabBarToTree {
    if (self.shadowViewController.tabBarController) {
        MNALViewClone *viewClone    = [MNALViewClone create:self.shadowViewController.tabBarController.tabBar
                                          viewController:self.shadowViewController.tabBarController];
        _idCounter                  = _idCounter + 1;
        [viewClone viewInfo].viewId = _idCounter;

        [_nodeMap setObject:viewClone forKey:[NSString stringWithFormat:@"%d", [viewClone viewInfo].viewId]];

        // NOTE: Adding tabbar as a clickable only if the current index is 0
        // Why? If the tabbar is on every page, then it repetition problems
        if ([self.shadowViewController.tabBarController selectedIndex] == 0 &&
            [self isVCOnTabBarTop:self.shadowViewController]) {
            [self addClickable:viewClone];
        }
    }
}

- (void)updateContentForViewClone:(MNALViewClone *)viewClone forView:(UIView *)view {
    if (view == nil || viewClone == nil) {
        return;
    }

    Class viewType = [view class];

    // Getting the plain text all the time, irrespective of content-enabled or not.
    // It's used in link-generation.
    if (viewType == [UITextView class]) {
        UITextView *textView = (UITextView *) view;
        if (![textView.text isEqualToString:@""]) {
            _plainText =
                [_plainText stringByAppendingString:[NSString stringWithFormat:@"textview:%@;", textView.text]];
        }
    } else if (viewType == [UILabel class]) {
        UILabel *label = (UILabel *) view;
        if (![label.text isEqualToString:@""]) {
            _plainText = [_plainText stringByAppendingString:[NSString stringWithFormat:@"label:%@;", label.text]];
        }
    }

    if (self.shouldFetchContent == NO) {
        // Just getting the content for the webview
        if (viewType == [UIWebView class] || viewType == [WKWebView class]) {
            // This is just for figuring out if the webview is the dominant view, in the link-generation logic
            [self generateContentForWebView:view];
        }
        return;
    }

    // Fetching content should only happen if the flag is YES
    [self appendViewContent:viewClone];
}

- (void)generateTree:(UIView *)view
            viewInfo:(MNALViewInfo *)parentViewInfo
      viewController:(UIViewController *)controller
            children:(NSMutableArray *)children {
    if ([MNALUtils isClassStrOfAdType:NSStringFromClass([view class])]) {
        return;
    }

    if ([view isKindOfClass:[UIButton class]]) {
        MNALViewClone *viewClone = [MNALViewClone create:view viewController:controller];
        MNALViewInfo *viewInfo   = [viewClone viewInfo];

        if (parentViewInfo != nil) {
            [viewInfo setParent:parentViewInfo];
        }
        _idCounter      = _idCounter + 1;
        viewInfo.viewId = _idCounter;

        [self updateContentForViewClone:viewClone forView:view];
        [self addClickable:viewClone];
        [children addObject:[viewInfo getJSON]];

    } else if ([view isKindOfClass:[UITextView class]]) {

        MNALViewClone *viewClone = [MNALViewClone create:view viewController:controller];
        MNALViewInfo *viewInfo   = [viewClone viewInfo];

        if (parentViewInfo != nil) {
            [viewInfo setParent:parentViewInfo];
        }
        _idCounter      = _idCounter + 1;
        viewInfo.viewId = _idCounter;

        [self updateContentForViewClone:viewClone forView:view];
        [self addClickable:viewClone];
        [children addObject:[viewInfo getJSON]];

    } else if ([view isKindOfClass:[UILabel class]]) {

        MNALViewClone *viewClone = [MNALViewClone create:view viewController:controller];
        MNALViewInfo *viewInfo   = [viewClone viewInfo];

        if (parentViewInfo != nil) {
            [viewInfo setParent:parentViewInfo];
        }
        _idCounter      = _idCounter + 1;
        viewInfo.viewId = _idCounter;

        [self updateContentForViewClone:viewClone forView:view];
        [self addClickable:viewClone];
        [children addObject:[viewInfo getJSON]];

    } else if ([view isKindOfClass:[UITableView class]] || [view isKindOfClass:[UICollectionView class]] ||
               [view isKindOfClass:[UITabBar class]]) {

        MNALViewClone *viewClone = [MNALViewClone create:view viewController:controller];
        MNALViewInfo *viewInfo   = [viewClone viewInfo];

        if (parentViewInfo != nil) {
            [viewInfo setParent:parentViewInfo];
        }
        _idCounter      = _idCounter + 1;
        viewInfo.viewId = _idCounter;

        [self addClickable:viewClone];
        [self updateContentForViewClone:viewClone forView:view];

        [_nodeMap setObject:viewClone forKey:[NSString stringWithFormat:@"%d", [viewInfo viewId]]];

    } else if ([view isKindOfClass:[UIWebView class]] || [view isKindOfClass:[WKWebView class]]) {
        MNALViewClone *viewClone = [MNALViewClone create:view viewController:controller];
        MNALViewInfo *viewInfo   = [viewClone viewInfo];

        if (parentViewInfo != nil) {
            [viewInfo setParent:parentViewInfo];
        }
        _idCounter      = _idCounter + 1;
        viewInfo.viewId = _idCounter;

        [self updateContentForViewClone:viewClone forView:view];

    } else {
        for (UIView *subview in view.subviews) {
            if ([MNALUtils isClassStrOfAdType:NSStringFromClass([view class])]) {
                continue;
            }

            MNALViewClone *viewClone = [MNALViewClone create:subview viewController:controller];
            MNALViewInfo *viewInfo   = [viewClone viewInfo];

            if (parentViewInfo != nil) {
                [viewInfo setParent:parentViewInfo];
            }
            _idCounter      = _idCounter + 1;
            viewInfo.viewId = _idCounter;

            if ([subview isKindOfClass:[UITableView class]] || [subview isKindOfClass:[UICollectionView class]] ||
                [subview isKindOfClass:[UITabBar class]]) {

                [self addClickable:viewClone];
                [self updateContentForViewClone:viewClone forView:subview];

                [_nodeMap setObject:viewClone forKey:[NSString stringWithFormat:@"%d", [viewInfo viewId]]];

            } else {

                if ([subview isKindOfClass:[UIButton class]]) {

                    [self updateContentForViewClone:viewClone forView:subview];
                    [self addClickable:viewClone];
                    [children addObject:[viewInfo getJSON]];

                } else if ([subview isKindOfClass:[WKWebView class]] || [subview isKindOfClass:[UIWebView class]]) {

                    [self updateContentForViewClone:viewClone forView:subview];

                } else if ([subview.subviews count] > 0) {
                    NSMutableDictionary *parentJson = [viewInfo getJSON];
                    NSMutableArray *childJson       = [[NSMutableArray alloc] init];

                    for (UIView *innerView in subview.subviews) {

                        [self generateTree:innerView viewInfo:viewInfo viewController:controller children:childJson];
                        [parentJson setObject:childJson forKey:MNAL_CHILD];
                    }
                    [children addObject:parentJson];

                } else {
                    [self updateContentForViewClone:viewClone forView:subview];
                    [self addClickable:viewClone];
                    [children addObject:[viewInfo getJSON]];
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"recursiveDescription"]) {

        MNALLinkLog(@"recursive description %@", [_shadowViewController.view valueForKey:@"recursiveDescription"]);
    }
}

- (NSMutableArray *)getSegments {
    _uniqueSegmentLink       = @"";
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    int i                    = 0;
    int count                = (int) [_nodeMap count];

    for (NSString *key in _nodeMap) {
        MNALViewClone *viewClone = [_nodeMap valueForKey:key];
        MNALSegment *segment     = [[MNALSegment alloc] initWithViewInfo:[viewClone viewInfo]];
        [segments addObject:[segment contentMap]];

        NSString *segmentLink = @"";

        if (i != (count - 1)) {
            segmentLink = [NSString stringWithFormat:@"%@&", [segment getContentsForSegmentAtIndex:i]];
        } else {
            segmentLink = [NSString stringWithFormat:@"%@", [segment getContentsForSegmentAtIndex:i]];
        }

        _uniqueSegmentLink = [_uniqueSegmentLink stringByAppendingString:segmentLink];
        i++;
    }
    return segments;
}

- (void)processContent {
    if (!self.content || [self.content isEqualToString:@""]) {
        return;
    }

    NSString *endTags = @"</body></html>";

    if ([self.content length] > [endTags length]) {
        NSString *endString =
            [self.content substringWithRange:NSMakeRange([self.content length] - [endTags length], [endTags length])];

        if (![endString isEqualToString:endTags]) {
            self.content = [self.content stringByAppendingString:endTags];
        }
    } else {
        self.content = [self.content stringByAppendingString:endTags];
    }

    MNALLinkLog(@"PROCESS_CONTENT: %@", self.content);

    self.contentHash = [self.content MD5];
}

- (NSString *)generateContentForWebView:(id)view {
    NSString *webViewHtmlContents = @"";
    __block NSString *webViewUrl;
    __block NSString *webViewContents;

    if ([view isKindOfClass:[WKWebView class]]) {
        WKWebView *wkWebView = (WKWebView *) view;
        webViewUrl           = [[MNALWKWebViewURLStore getSharedInstance] getPrimaryUrlForWebView:wkWebView];
        if (webViewUrl == nil) {
            webViewUrl = [[wkWebView URL] absoluteString];
        }
        if ([[MNALWKWebViewURLStore getSharedInstance] getURLCountForWebView:wkWebView] > 1) {
            [self.secondaryLinks
                addObjectsFromArray:[[MNALWKWebViewURLStore getSharedInstance] getRedirectedLinksForWebView:wkWebView]];
        }
        BOOL isLocalhost = (webViewUrl != nil && [webViewUrl hasPrefix:@"http://localhost"]);

        if (isLocalhost || (webViewUrl == nil) || ([webViewUrl isEqualToString:@""])) {
            // TODO: This is async. Doesn't work
            // Get the html contents
            //
            __block BOOL finished = NO;
            [wkWebView evaluateJavaScript:@"document.body.innerHTML"
                        completionHandler:^(id result, NSError *error) {
                          if (error == nil) {
                              if (result != nil) {
                                  webViewContents = [NSString stringWithFormat:@"%@", result];
                              }
                          } else {
                              MNALLinkLog(@"evaluateJavaScript error : %@", error.localizedDescription);
                          }
                          finished = YES;
                        }];

            if ([MNALAppLink isAggressiveViewContentFetch]) {
                while (!finished) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
            }
            MNALLinkLog(@"Webview contents - %@", webViewContents);
        }
    } else if ([view isKindOfClass:[UIWebView class]]) {
        void (^checkForWebView)(void) = ^{
          UIWebView *webView = (UIWebView *) view;
          webViewUrl =
              ([webView request] != nil && [[webView request] URL]) ? [[[webView request] URL] absoluteString] : nil;
          if (webViewUrl == nil || [webViewUrl isEqualToString:@""]) {
              // Get the html contents
              if (![webView isLoading]) {
                  webViewContents = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
              }
          }
        };

        if ([NSThread isMainThread]) {
            checkForWebView();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
              checkForWebView();
            });
        }
    }

    if (webViewUrl || (webViewContents && ![webViewContents isEqualToString:@""])) {
        NSString *attrPlaceholder             = @"<attrPlaceholder>";
        NSString *htmlStartTagWithPlaceholder = [NSString stringWithFormat:@"<iframe %@>", attrPlaceholder];
        NSString *htmlEndTag                  = @"</iframe>";

        // Building the attributes right now.
        CGRect frame    = [view frame];
        UIView *viewObj = (UIView *) view;

        CGPoint originWrtWindow = [viewObj convertPoint:viewObj.frame.origin toView:nil];

        NSNumber *x1 = [MNALUtils getNormalizedDimension:originWrtWindow.x isWidth:YES];
        NSNumber *y1 = [MNALUtils getNormalizedDimension:originWrtWindow.y isWidth:NO];
        NSNumber *x2 = [MNALUtils getNormalizedDimension:([x1 floatValue] + frame.size.width) isWidth:YES];
        NSNumber *y2 = [MNALUtils getNormalizedDimension:([y1 floatValue] + frame.size.height) isWidth:NO];

        NSMutableDictionary<NSString *, NSString *> *attrsDict = [@{
            @"data-top" : [y1 stringValue],
            @"data-bottom" : [y2 stringValue],
            @"data-left" : [x1 stringValue],
            @"data-right" : [x2 stringValue],
        } mutableCopy];
        NSArray<NSString *> *posKeysList                       = [attrsDict allKeys];

        if (webViewContents == nil) {
            webViewContents = @"";
        }

        if ((!webViewContents || [webViewContents isEqualToString:@""]) && webViewUrl) {
            [attrsDict setObject:webViewUrl forKey:@"src"];

            if ([self determineIfWebviewIsDominant:view]) {
                self.isDominantWebview  = YES;
                self.dominantWebviewUrl = webViewUrl;
            }
        }

        NSString *valueSuffix     = @"%";
        NSMutableArray *attrsList = [[NSMutableArray alloc] init];
        for (NSString *key in attrsDict) {
            NSString *value = [attrsDict valueForKey:key];
            NSString *entry;
            if ([posKeysList containsObject:key]) {
                entry = [NSString stringWithFormat:@"%@=\"%@%@\"", key, value, valueSuffix];
            } else {
                entry = [NSString stringWithFormat:@"%@=\"%@\"", key, value];
            }

            [attrsList addObject:entry];
        }
        NSString *attrs = [attrsList componentsJoinedByString:@" "];

        NSString *htmlStartTag =
            [htmlStartTagWithPlaceholder stringByReplacingOccurrencesOfString:attrPlaceholder withString:attrs];

        NSArray *htmlContentsList = @[ htmlStartTag, webViewContents, htmlEndTag ];
        webViewHtmlContents       = [htmlContentsList componentsJoinedByString:@""];
    }

    return webViewHtmlContents;
}

- (BOOL)determineIfWebviewIsDominant:(id)view {
    BOOL isWebview = ([view isKindOfClass:[WKWebView class]] || [view isKindOfClass:[UIWebView class]]);
    if (!isWebview) {
        return NO;
    }
    UIView *viewObj   = (UIView *) view;
    CGSize viewSize   = viewObj.frame.size;
    CGSize deviceSize = [[UIScreen mainScreen] bounds].size;

    CGFloat viewArea   = viewSize.width * viewSize.height;
    CGFloat deviceArea = deviceSize.width * deviceSize.height;

    CGFloat relativeViewArea = viewArea / deviceArea;
    return relativeViewArea > kAreaMajorityPercentage;
}

- (void)appendViewContent:(MNALViewClone *)viewClone {
    UIView *view = [[viewClone viewInfo] view];

    if ([[viewClone properties] objectForKey:MNAL_TEXT]) {
        _content = [_content stringByAppendingString:[self getHTMLContentFromText:view]];
    } else if ([view isKindOfClass:[UITableView class]]) {

        UITableView *tableView = (UITableView *) view;
        NSString *visibility   = [tableView isHidden] ? @"false" : @"true";
        _content = [_content stringByAppendingString:[NSString stringWithFormat:@"<ul id=\'%d\' visibility=\'%@\'>",
                                                                                viewClone.viewInfo.viewId, visibility]];
        [self getHTMLContentFromTableView:tableView viewClone:viewClone];

        _content = [_content stringByAppendingString:@"</ul>"];

    } else if ([view isKindOfClass:[UICollectionView class]]) {

        UICollectionView *collectionView = (UICollectionView *) view;
        NSString *visibility             = [collectionView isHidden] ? @"false" : @"true";
        _content = [_content stringByAppendingString:[NSString stringWithFormat:@"<ul id=\'%d\' visibility=\'%@\'>",
                                                                                viewClone.viewInfo.viewId, visibility]];
        [self getHTMLContentFromCollectionView:collectionView];
        _content = [_content stringByAppendingString:@"</ul>"];
    } else if ([view isKindOfClass:[WKWebView class]] || [view isKindOfClass:[UIWebView class]]) {
        NSString *webviewContent = [self generateContentForWebView:view];
        if (webviewContent && ![webviewContent isEqualToString:@""]) {
            self.content = [self.content stringByAppendingString:webviewContent];
        }
    }
}

- (NSString *)getHTMLContentFromText:(UIView *)view {

    NSString *htmlConvertedText = @"";

    if ([view isKindOfClass:[UITextView class]]) {

        UITextView *textView = (UITextView *) view;
        NSString *visibility = [textView isHidden] ? @"false" : @"true";
        int fontSize         = [self getFontSize:view];
        htmlConvertedText = [NSString stringWithFormat:@"<p visibility=\'%@\' font-size=\'%d\'>", visibility, fontSize];
        if (textView.text != nil && ![textView.text isEqualToString:@""]) {
            htmlConvertedText = [htmlConvertedText stringByAppendingString:textView.text];
            self.plainText =
                [self.plainText stringByAppendingString:[NSString stringWithFormat:@"listTextView:%@;", textView.text]];
        }

    } else if ([view isKindOfClass:[UILabel class]]) {

        UILabel *label       = (UILabel *) view;
        NSString *visibility = [label isHidden] ? @"false" : @"true";
        int fontSize         = [self getFontSize:view];
        htmlConvertedText = [NSString stringWithFormat:@"<p visibility=\'%@\' font-size=\'%d\'>", visibility, fontSize];
        if (label.text != nil && ![label.text isEqualToString:@""]) {
            htmlConvertedText = [htmlConvertedText stringByAppendingString:label.text];
            self.plainText =
                [self.plainText stringByAppendingString:[NSString stringWithFormat:@"listLabel:%@;", label.text]];
        }
    }

    if (![htmlConvertedText isEqualToString:@""]) {
        htmlConvertedText = [htmlConvertedText stringByAppendingString:@"</p>"];
    }

    return htmlConvertedText;
}

- (void)getHTMLContentFromTableView:(UITableView *)tableView viewClone:(MNALViewClone *)clone {
    if (NO == [MNALAppLink isAggressiveViewContentFetch]) {
        // Vanilla table-view fetch without any modification on the view-tree
        for (UITableViewCell *visibleCell in [tableView visibleCells]) {
            UIView *contentView = [visibleCell contentView];
            _content            = [_content stringByAppendingString:@"<li>"];
            [self getListText:contentView];
            _content = [_content stringByAppendingString:@"</li>"];
        }
    } else {
        // Aggressive table-view fetch
        int startOffset = [[clone viewInfo] startOffset];
        int pageCount   = [[clone viewInfo] pageCount];

        NSArray *indexPath = [tableView indexPathsForVisibleRows];

        if (!indexPath || [indexPath count] == 0) {
            return;
        }
        NSIndexPath *currentTopView = [indexPath objectAtIndex:0];

        // NOTE: This is a hack. A better way would be to find the number of elements in each section
        // But it's more laborious that way. This is better. Do change if exception is found.
        NSUInteger tensMul  = 100;
        NSUInteger unitsMul = 10;

        NSUInteger topViewIndex = currentTopView.section * tensMul + currentTopView.row * unitsMul;

        for (int i = startOffset; i < pageCount; i++) {
            NSIndexPath *indexPath      = [MNALUtils getIndexPathForView:tableView forIndex:[NSNumber numberWithInt:i]];
            NSUInteger currentViewIndex = (indexPath.section * tensMul) + (indexPath.row * unitsMul);
            if (currentViewIndex < topViewIndex) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                UIView *contentView = [cell contentView];
                _content            = [_content stringByAppendingString:@"<li>"];
                [self getListText:contentView];
                _content = [_content stringByAppendingString:@"</li>"];
            }
        }
    }
}

- (void)getListText:(UIView *)view {

    for (UIView *subview in [view subviews]) {
        if ([subview isKindOfClass:[UITextView class]] || [subview isKindOfClass:[UILabel class]]) {
            _content = [_content stringByAppendingString:[self getHTMLContentFromText:subview]];
        } else if ([[subview subviews] count] > 0) {
            [self getListText:subview];
        }
    }
}

- (void)getHTMLContentFromCollectionView:(UICollectionView *)collectionView {
    for (UICollectionViewCell *visibleCell in [collectionView visibleCells]) {
        UIView *contentView = [visibleCell contentView];
        _content            = [_content stringByAppendingString:@"<li>"];
        [self getListText:contentView];
        _content = [_content stringByAppendingString:@"</li>"];
    }
}

- (int)getFontSize:(UIView *)view {
    int fontSize = 0;
    if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *) view;
        fontSize             = (int) [[textView font] pointSize];
    } else if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *) view;
        fontSize       = (int) [[label font] pointSize];
    }
    return fontSize;
}

- (void)appendHTMLHeadersInContent:(UIViewController *)controller {
    if (self.shouldFetchContent == NO) {
        return;
    }

    NSString *title = @"";
    if (![[MNALUtils getMainBundleId] isEqualToString:MNAL_WIKIPEDIA_BUNDLE]) {
        title = [MNALUtils getTitleForController:controller];
    }

    NSString *headers = [NSString stringWithFormat:@"<html><head><title>%@</title></head><body>", title];
    _content          = [_content stringByAppendingString:headers];
}

- (void)addClickable:(MNALViewClone *)viewClone {

    if ([viewClone viewInfo] == nil) {
        return;
    }

    if ([self shouldAddClickable:viewClone]) {
        MNALViewInfo *viewInfo = [viewClone viewInfo];
        [_clickables addObject:viewInfo];

        Class viewType = [viewInfo.view class];
        BOOL isListView =
            (viewType == [UITableView class] || viewType == [UICollectionView class] || viewType == [UITabBar class]);

        if (isListView) {
            [self.listViewClickables addObject:viewInfo];
        } else {
            [self.nonListViewClickables addObject:viewInfo];
        }
    }
}

- (BOOL)shouldAddClickable:(MNALViewClone *)viewClone {
    UIView *view                    = [[viewClone viewInfo] view];
    NSArray<Class> *acceptableTypes = @[
        [UIButton class],
        [UITableView class],
        [UICollectionView class],
        [UITabBarController class],
        [UITabBar class],
        [UITabBarItem class],
    ];
    for (Class type in acceptableTypes) {
        if (type == [view class]) {
            return YES;
        }
    }

    NSArray *gesturesOnView = [view gestureRecognizers];
    for (UIGestureRecognizer *recognizer in gesturesOnView) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            return YES;
        }
    }
    return NO;
}

- (UIViewController *)getViewController {
    return self.shadowViewController;
}

- (NSString *)getViewTreeLink {
    /**
     * View tree link format :
     * https://{reverse_bundle_id}.imnapp/version_id/{view_controller_name}/intent/{parameters_json_format}/segment/{segment_hash}/title/{title}
     * If webview is dominant :
     * https://{reverse_bundle_id}.imnapp/version_id/{view_controller_name}/url/{webview_url}
     **/

    NSString *classname = [NSStringFromClass(self.shadowViewController.class) lowercaseString];
    NSString *link      = [MNALUtils getURIForControllerName:classname];
    if (link == nil) {
        return @"";
    }

    BOOL isDominant = (self.isDominantWebview && self.dominantWebviewUrl != nil);

    if (isDominant) {
        NSString *encodedUrl = [MNALUtils getEncodedLink:self.dominantWebviewUrl];
        link                 = [link stringByAppendingString:[NSString stringWithFormat:@"/%@/%@", @"url", encodedUrl]];
        return [[self appendTitleToLink:link] lowercaseString];
    }

    // Create link with intent string
    NSString *intentStr = [self getUniqueIdStrForCurrentVC];
    if (intentStr && [intentStr isEqualToString:@""] == NO) {
        link = [link stringByAppendingString:[NSString stringWithFormat:@"/%@/%@", @"intent",
                                                                        [MNALUtils getEncodedLink:intentStr]]];
    }

    if (self.uniqueSegmentLink && [self.uniqueSegmentLink isEqualToString:@""] == NO) {
        link = [link
            stringByAppendingString:[NSString
                                        stringWithFormat:@"/%@/%@", @"segment",
                                                         [MNALUtils getEncodedLink:[self.uniqueSegmentLink MD5]]]];
    }

    link = [[self appendTitleToLink:link] lowercaseString];
    MNALLinkLog(@"LINK: %@", link);
    return link;
}

- (NSString *)appendTitleToLink:(NSString *)link {
    if (self.isTitleEnabled && self.shadowViewController.title != nil &&
        [self.shadowViewController.title isEqualToString:@""] == NO) {
        link = [link
            stringByAppendingString:[NSString
                                        stringWithFormat:@"/%@/%@", @"title",
                                                         [MNALUtils getEncodedLink:self.shadowViewController.title]]];
    }
    return link;
}

- (NSString *)getUniqueIdStrForCurrentVC {
    NSString *intentJsonString;

    // Can possibly check for respondsToSelector here as well.
    // Going with the pythonic way :)
    @try {
        intentJsonString = objc_getAssociatedObject(self.shadowViewController, kAssociatedObjectKey);
    } @catch (NSException *exception) {
        MNALLinkLog(@"Exception when getting the associated object");
        MNALLinkLog(@"%@", exception);
    }

    if (intentJsonString && ![intentJsonString isEqualToString:@""]) {
        return intentJsonString;
    }

    // check if current vc has the property.
    intentJsonString = [MNALUtils getJsonStringOfPropertiesForViewController:self.shadowViewController
                                                                    skipList:self.intentSkipList
                                                                     content:self.plainText
                                                                contentLimit:self.contentLimit];

    @try {
        objc_setAssociatedObject(self.shadowViewController, kAssociatedObjectKey, intentJsonString,
                                 OBJC_ASSOCIATION_COPY_NONATOMIC);
    } @catch (NSException *exception) {
        MNALLinkLog(@"Exception when setting the associated object");
        MNALLinkLog(@"%@", exception);
    }

    return intentJsonString;
}

/// Method to check if the VC is inside a tabBarController and is the immediate child of it
- (BOOL)isVCOnTabBarTop:(UIViewController *)vc {
    if (vc == nil || vc.tabBarController == nil) {
        return NO;
    }

    UIViewController *parent = [vc parentViewController];
    if ([parent isKindOfClass:[UITabBarController class]]) {
        return YES;
    }

    if ([parent isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *) parent;
        if ([[navVC viewControllers] count] == 1) {
            return YES;
        }
    }
    return NO;
}

@end
