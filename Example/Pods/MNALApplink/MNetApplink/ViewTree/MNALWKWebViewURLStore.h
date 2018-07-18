//
//  MNALWKWebViewURLStore.h
//  Pods
//
//  Created by kunal.ch on 02/08/17.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MNALWKWebViewURLStore : NSObject
+ (MNALWKWebViewURLStore *)getSharedInstance;
- (NSArray *)getWebViewUrlsForWebView:(WKWebView *)webView;
- (void)addWebView:(WKWebView *)webView withURL:(NSURL *)url;
- (NSString *)getPrimaryUrlForWebView:(WKWebView *)webView;
- (NSUInteger)getURLCountForWebView:(WKWebView *)webView;
- (NSArray *)getRedirectedLinksForWebView:(WKWebView *)webView;
@end
