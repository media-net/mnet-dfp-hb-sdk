//
//  MNBaseURL+Internal.h
//  Pods
//
//  Created by nithin.g on 26/07/17.
//
//

#ifndef MNBaseURL_Internal_h
#define MNBaseURL_Internal_h

#import "MNBaseNotificationManager.h"
#import "MNBaseURL.h"

@interface MNBaseURL ()
@property (nonnull) NSString *urlProtocol;
@property (atomic) BOOL httpAllowed;
@property (atomic) BOOL isDebug;
@property (nonnull, atomic) MNBaseNotificationManager *sdkConfigNotificationObj;

+ (BOOL)checkIfHttpAllowed;

/// Tries to allow http for all the urls. Will return no if http cannot be allowed.
- (BOOL)allowHttp;

@end

#endif /* MNBaseURL_Internal_h */
