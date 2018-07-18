//
//  MNBaseHostAppInfo.m
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNBaseHostAppInfo.h"
#import "MNBase.h"
#import "MNBaseLogger.h"
#import "MNBaseUtil.h"

@implementation MNBaseHostAppInfo

+ (MNBaseHostAppInfo *)newInstance {
    MNBaseHostAppInfo *hostInfo = [[MNBaseHostAppInfo alloc] init];
    return hostInfo;
}

+ (MNBaseHostAppInfo *)getAppHostInfoWithExtUrl:(NSString *)extUrl {
    MNBaseHostAppInfo *appInfo = [[self class] newInstance];

    appInfo.appExt = [MNBaseAppExternalData new];

    NSBundle *bundle = [NSBundle mainBundle];
    if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
        // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
        bundle =
            [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
    }

    MNLogD(@"logging %@ %@", [MNBaseUtil getMainPackageName],
           [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleVersionKey]);
    [appInfo setPackageName:[MNBaseUtil getMainPackageName]];
    [appInfo setAppVersion:[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    MNBaseIntentData *intentData = [[MNBaseIntentData alloc] initWithExtUrl:extUrl];

    // fetching the url scheme from the mainbundle
    // TODO: Right now, only setting the zeroth element. Ideally needs to be an array
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes && [urlTypes count] > 0) {
        NSDictionary *schemeUriDict = [urlTypes objectAtIndex:0];
        NSString *schemeUri         = [schemeUriDict objectForKey:@"CFBundleURLName"];
        [intentData setUri:schemeUri];
    }
    [appInfo setIntentData:intentData];

    // adding the publisher
    [appInfo setPublisher:[[MNBasePublisher alloc] init]];
    [appInfo.publisher setId:[[MNBase getInstance] customerId]];

    return appInfo;
}

- (NSDictionary *)propertyKeyMap {
    return @{
        @"packageName" : @"bundle",
        @"appVersion" : @"ver",
        @"intentData" : @"content",
        @"appExt" : @"ext",
    };
}
@end
