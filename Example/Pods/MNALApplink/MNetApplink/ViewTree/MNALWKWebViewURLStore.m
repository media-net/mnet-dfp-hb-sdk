//
//  MNALWKWebViewURLStore.m
//  Pods
//
//  Created by kunal.ch on 02/08/17.
//
//

#import "MNALWKWebViewURLStore.h"

@interface MNALWKWebViewURLStore ()
// NSDictionary keys should conform to NSCopying protocol.
// It is a basic requirement specified here https://developer.apple.com/documentation/foundation/nsdictionary
// That is why we cannot use WKWebView object as key. It does not conforms to NSCopying protocol.
// Instead using NSValue which is a simple container for a single Objective-C data item.
@property (nonatomic) NSMutableDictionary<NSValue *, NSArray<NSString *> *> *webviewMap;
@end

@implementation MNALWKWebViewURLStore
static MNALWKWebViewURLStore *instance;

+ (MNALWKWebViewURLStore *)getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webviewMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)getPrimaryUrlForWebView:(WKWebView *)webView {
    NSArray *arrayOfURL = [self getWebViewUrlsForWebView:webView];
    if (arrayOfURL) {
        return arrayOfURL[0];
    }
    return nil;
}

- (NSArray *)getWebViewUrlsForWebView:(WKWebView *)webView {
    NSValue *webViewKey = [NSValue valueWithNonretainedObject:webView];
    if ([self.webviewMap objectForKey:webViewKey] != nil) {
        return [self.webviewMap objectForKey:webViewKey];
    }
    return nil;
}

- (NSUInteger)getURLCountForWebView:(WKWebView *)webView {
    NSValue *webViewKey = [NSValue valueWithNonretainedObject:webView];
    if ([self.webviewMap objectForKey:webViewKey] != nil) {
        return [[self.webviewMap objectForKey:webViewKey] count];
    }
    return 0;
}

- (NSArray *)getRedirectedLinksForWebView:(WKWebView *)webView {
    NSValue *webViewKey = [NSValue valueWithNonretainedObject:webView];
    if ([self.webviewMap objectForKey:webViewKey] == nil) {
        return nil;
    }
    NSMutableArray *urls = [[self.webviewMap objectForKey:webViewKey] mutableCopy];
    [urls removeObjectAtIndex:0];
    return [NSArray arrayWithArray:urls];
}

- (void)addWebView:(WKWebView *)webView withURL:(NSURL *)url {
    NSValue *webViewKey = [NSValue valueWithNonretainedObject:webView];
    if ([self.webviewMap objectForKey:webViewKey] != nil) {
        NSArray *urlArray               = [self.webviewMap objectForKey:webViewKey];
        NSMutableArray *mutableUrlArray = [urlArray mutableCopy];
        [mutableUrlArray addObject:[url absoluteString]];
        [self.webviewMap setObject:[NSArray arrayWithArray:mutableUrlArray] forKey:webViewKey];
        return;
    }
    [self.webviewMap setObject:[NSArray arrayWithObject:[url absoluteString]] forKey:webViewKey];
}
@end
