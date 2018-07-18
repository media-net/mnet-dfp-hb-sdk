#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CMPConsentToolAPI.h"
#import "CMPConsentToolUtil.h"
#import "CMPTypes.h"
#import "CMPConsentConstant.h"
#import "CMPConsentParser.h"
#import "CMPActivityIndicatorView.h"
#import "CMPConsentToolViewController.h"
#import "CMPDataStorageProtocol.h"
#import "CMPDataStorageUserDefaults.h"

FOUNDATION_EXPORT double MNetCMPConsentToolVersionNumber;
FOUNDATION_EXPORT const unsigned char MNetCMPConsentToolVersionString[];

